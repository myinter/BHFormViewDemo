//
//  BHFormView.m
//  BHFormViewDemo
//
//  Created by 熊伟 on 2016/5/16.
//  Copyright © 2016年 熊伟. All rights reserved.
//

#import "BHFormView.h"

#ifdef DEBUG
#define NSLog(...) NSLog(__VA_ARGS__)
#define printf(...) printf(__VA_ARGS__)
#else
#define NSLog(...)
#define printf(...)
#endif


//单元格重用容器
static NSMutableSet *reuseCells = nil;
dispatch_queue_t SerialQueue = nil;

@implementation BHFormView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(BHFormView *)init{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self initialize];
}

-(void)initialize{
    if (SerialQueue == nil) {
        SerialQueue = dispatch_queue_create("BHFormViewSerial", DISPATCH_QUEUE_SERIAL);
    }
    _veryHighCellsContainerSize = 512;
    _veryHighCellsRects = (CGRect *)malloc(sizeof(CGRect) * 256);
    _veryHighCellsCount = 0;
    _minCellSizeHeight = 70.0;
    _minCellSizeWidth = 70.0;
    self.clipsToBounds = YES;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    //重新载入数据
    if (_dataSource) {
        [self reloadData];
    }
}

-(void)reloadData
{
    //所有行的单元格全部放入重用池 Put all the cells into reusepool
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (_isReloading) {
            return ;
        }
        _isReloading = YES;
        NSMutableArray *newRows = [NSMutableArray arrayWithCapacity:rowCount];
        NSInteger newRowCount = [_dataSource numberOfRowsInFormView:self];
        CGFloat newMaxHeight = 0.0;
        CGFloat newMaxWidth = 0.0;
        CGFloat newMinCellSizeWidth = 70.0;
        CGFloat newMinCellSizeHeight = 70.0;
        _veryHighCellsCount = 0;
        CGFloat baseY = 0.0;
        for (NSInteger rowIndex = 0; rowIndex != newRowCount; rowIndex++) {
            CGFloat baseX = 0;
            BHFormViewRow *row = [BHFormViewRow new];
            row.rowIndex = rowIndex;
            row.beginX = MAXFLOAT;
            row.beginY = MAXFLOAT;
            NSInteger columnCount = 0;
            if ([_dataSource respondsToSelector:@selector(formView:numberOfColumnsInRow:)]) {
                columnCount = [_dataSource formView:self numberOfColumnsInRow:rowIndex];
            }
            else{
                if ([_dataSource respondsToSelector:@selector(formViewColumnsInRow:)]) {
                    columnCount = [_dataSource formViewColumnsInRow:self];
                }
            }
            row.columnCount = columnCount;
            row.midVisibleColumn = columnCount / 2;
            CGFloat rowBaseHeight = [_dataSource formView:self heightForRow:rowCount];
            row.standardHeightForColumn = rowBaseHeight;
            row.hasVeryHighCell = NO;
            for (int columnIndex = 0; columnIndex!= columnCount; columnIndex++) {
                CGFloat columnHeight = rowBaseHeight;
                CGFloat columnWidth = 0.0;
                if ([_dataSource respondsToSelector:@selector(formView:widthForColumn:atRow:)]) {
                    columnWidth = [_dataSource formView:self widthForColumn:columnIndex atRow:row.rowIndex];
                }
                else{
                    if ([_dataSource respondsToSelector:@selector(formView:widthForColumn:)]) {
                        columnWidth = [_dataSource formView:self widthForColumn:columnIndex];
                    }
                }
                if ([_dataSource respondsToSelector:@selector(formView:heightForColumn:atRow:)]) {
                    columnHeight = [_dataSource formView:self heightForColumn:columnIndex atRow:rowIndex];
                }
                
                newMinCellSizeWidth = MIN(columnWidth, newMinCellSizeWidth);
                newMinCellSizeHeight = MIN(columnHeight, newMinCellSizeHeight);
                
                CGRect rectForColumCell = CGRectMake(baseX, baseY, columnWidth, columnHeight);
                rectForColumCell = CheckCollisionWithRectsInFormerRows(_veryHighCellsRects,_veryHighCellsCount, rectForColumCell);
                if (columnHeight > rowBaseHeight) {
                    row.hasVeryHighCell = YES;
                    if (_veryHighCellsCount == _veryHighCellsContainerSize) {
                        CGRect *newRectContainingPointer = (CGRect *)malloc(sizeof(CGRect) * (_veryHighCellsContainerSize*=2));
                        memcpy(newRectContainingPointer, _veryHighCellsRects, _veryHighCellsCount * sizeof(CGRect));
                        free(_veryHighCellsRects);
                        _veryHighCellsRects = newRectContainingPointer;
                    }
                    _veryHighCellsRects[_veryHighCellsCount] = rectForColumCell;
                    _veryHighCellsCount++;
                }
                row.rectsForCells[columnIndex] = rectForColumCell;
                if (rectForColumCell.origin.y < row.beginY) {
                    row.beginY = rectForColumCell.origin.y;
                }
                if (rectForColumCell.origin.x < row.beginX) {
                    row.beginX = rectForColumCell.origin.x;
                }
                CGFloat maxX = CGRectGetMaxX(rectForColumCell);
                baseX = maxX;
                if (row.maxX < maxX) {
                    row.maxX = maxX;
                }
                if (newMaxWidth < maxX) {
                    newMaxWidth = maxX;
                }
                CGFloat maxY = CGRectGetMaxY(rectForColumCell);
                if (row.maxY < maxY) {
                    row.maxY = maxY;
                }
                if (newMaxHeight < maxY) {
                    newMaxHeight = maxY;
                }
            }
            [newRows addObject:row];
            baseY += rowBaseHeight;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            for (BHFormViewRow *row in _Rows) {
                for (BHFormViewCell *cell in row.currentCells) {
                    if ((NSNull *)cell != [NSNull null]) {
                        [cell removeFromSuperview];
                        [self addCellToReusePool:cell];
                    }
                }
            }
            rowCount = newRowCount;
            _Rows = newRows;
            maxHeight = newMaxHeight;
            maxWidth = newMaxWidth;
            _minCellSizeWidth = newMinCellSizeWidth / 4;
            _minCellSizeHeight = newMinCellSizeHeight / 4;
            _midVisibleRowIndex = rowCount / 2;
            self.contentSize = CGSizeMake(maxWidth, maxHeight);
            [self refreshCells];
            _isReloading = NO;
        });
    });
}

-(CGRect)checkCollisionWithFormerRects:(CGRect)objRect{
    for (BHFormViewRow *row in _Rows) {
        if (!row.hasVeryHighCell) {
            continue;
        }
        CGRect *rects = row.rectsForCells;
        for (int i = 0; i != row.columnCount; i++) {
            CGRect rect = rects[i];
            if (CGRectIntersectsRect(rect, objRect)) {
                objRect = CGRectMake(rect.origin.x + rect.size.width, objRect.origin.y, objRect.size.width, objRect.size.height);
            }
        }
    }
    return objRect;
}

-(void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    _lastContentOffest = contentOffset;
    [self refreshCells];
    if (ABS(_lastContentOffest.x - contentOffset.x) > _minCellSizeWidth || ABS(_lastContentOffest.y - contentOffset.y) > _minCellSizeHeight) {
    }
}

- (void)reloadDataWithoutNewItemsAndLayoutInfos{
    NSInteger count = _Rows.count;
    if (count!=0) {
        for (NSInteger index = 0; index != count; index++) {
            BHFormViewRow *row = _Rows[index];
            NSInteger columnCount  = row.columnCount;
            NSArray *cells = row.currentCells;
                if (row.visible && columnCount) {
                        BOOL *visibles = row.columnsVisible;
                        for (NSInteger columnIndex = 0; columnIndex != columnCount; columnIndex++) {
                            if (visibles[columnIndex]) {
                                BHFormViewCell *cell = cells[columnIndex];
                                if (cell != (BHFormViewCell *)[NSNull null]) {
                                    [cell removeFromSuperview];
                                    [self addCellToReusePool:cell];
                                }
                                cell = [_dataSource formView:self cellForRow:row.rowIndex column:columnIndex];
                                row.currentCells[columnIndex] = cell;
                                [self addSubview:cell];
                                cell.frame = row.rectsForCells[columnIndex];
                            }
                        }
                }
        }
    }
}

/*刷新当前的Cell*/
-(void)refreshCells
{
    CGPoint contentOffset = self.contentOffset;
    CGFloat visibleMinX = contentOffset.x;
    CGFloat visibleMinY = contentOffset.y;
    CGFloat visibleMaxX = visibleMinX + self.bounds.size.width;
    CGFloat visibleMaxY = visibleMinY + self.bounds.size.height;
    BOOL hasLowerRowVisible = NO,hasUpperRowVisible = NO;
    NSInteger upperIndex = MIN(_midVisibleRowIndex, rowCount),lowerIndex = _midVisibleRowIndex + 1;
    NSInteger maxVisibleRowIndex  = 0,minVisibleIndex = rowCount - 1;
    
    while (1) {
        if (upperIndex != rowCount) {
            BHFormViewRow *row = _Rows[upperIndex];
            if ((row.beginX >= visibleMaxX || row.maxX <= visibleMinX) || (row.beginY >= visibleMaxY || row.maxY <= visibleMinY)) {
                row.visible = NO;
                if (hasUpperRowVisible) {
                    for (NSInteger rc = upperIndex; rc != rowCount; rc++) {
                        BHFormViewRow *currentRow = _Rows[rc];
                        if (currentRow.hasVisibleCell) {
                            NSInteger count = currentRow.currentCells.count;
                            NSMutableArray *array = currentRow.currentCells;
                            CGRect *rectForCells = row.rectsForCells;
                            BOOL *columnVisibles = currentRow.columnsVisible;
                            for (NSInteger columnIndex = 0; columnIndex != count; columnIndex++) {
                                BHFormViewCell *cell = array[columnIndex];
                                //超长的cell需要单独判断
                                CGRect rectForCell = rectForCells[columnIndex];
                                if (rectForCell.size.height > currentRow.standardHeightForColumn && isVisibleRect(rectForCell, visibleMinX, visibleMinY, visibleMaxX, visibleMaxY)) {
                                    //可见的超长cell
                                }
                                else
                                {
                                    columnVisibles[columnIndex] = NO;
                                    if ((NSNull *)cell != [NSNull null]) {
                                        [cell removeFromSuperview];
                                        [self addCellToReusePool:cell];
                                        array[columnIndex] = [NSNull null];
                                    }
                                }
                            }
                        }
                        currentRow.visible = NO;
                    }
                    if (!_veryHighCellsCount) {
                        upperIndex = rowCount - 1;
                    }
                }
                else
                {
                    //移除全部cell
                    NSInteger count = row.currentCells.count;
                    NSMutableArray *array = row.currentCells;
                    BOOL *columnVisibles = row.columnsVisible;
                    for (NSInteger columnIndex = 0; columnIndex != count; columnIndex++) {
                        BHFormViewCell *cell = array[columnIndex];
                        columnVisibles[columnIndex] = NO;
                        if ((NSNull *)cell != [NSNull null]) {
                            [cell removeFromSuperview];
                            [self addCellToReusePool:cell];
                            array[columnIndex] = [NSNull null];
                        }
                    }
                }
                row.hasVisibleCell = NO;
            }
            else
            {
                if (upperIndex  < minVisibleIndex) {
                    minVisibleIndex = upperIndex;
                }
                if (upperIndex > maxVisibleRowIndex) {
                    maxVisibleRowIndex = upperIndex;
                }
                hasUpperRowVisible = YES;
                //                printf("\n upper visible rowIndex = %d hasVeryHighCell %d",row.rowIndex,row.hasVeryHighCell);
                row.visible = YES;
            }
            upperIndex++;
        }
        
        
        if (lowerIndex != -1) {
            BHFormViewRow *row = _Rows[lowerIndex];
            if ((row.beginX >= visibleMaxX || row.maxX <= visibleMinX) || (row.beginY >= visibleMaxY || row.maxY <= visibleMinY)) {
                row.visible = NO;
                if (hasLowerRowVisible) {
                    for (NSInteger rc = lowerIndex; rc >= 0; rc--) {
                        BHFormViewRow *currentRow = _Rows[rc];
                        if (currentRow.hasVisibleCell && !currentRow.hasVeryHighCell) {
                            NSInteger count = currentRow.currentCells.count;
                            NSMutableArray *array = currentRow.currentCells;
                            BOOL *columnVisibles = currentRow.columnsVisible;
                            CGRect *rectForCells = row.rectsForCells;
                            for (NSInteger columnIndex = 0; columnIndex != count; columnIndex++) {
                                BHFormViewCell *cell = array[columnIndex];
                                CGRect rectForCell = rectForCells[columnIndex];
                                if (rectForCell.size.height > currentRow.standardHeightForColumn && isVisibleRect(rectForCell, visibleMinX, visibleMinY, visibleMaxX, visibleMaxY)) {
                                    //可见的超长cell
                                }
                                else
                                {
                                    columnVisibles[columnIndex] = NO;
                                    if ((NSNull *)cell != [NSNull null]) {
                                        [cell removeFromSuperview];
                                        [self addCellToReusePool:cell];
                                        array[columnIndex] = [NSNull null];
                                    }
                                }
                            }
                        }
                        currentRow.visible = NO;
                    }
                    if (!_veryHighCellsCount) {
                        lowerIndex = 0;
                    }
                }
                else{
                    //移除全部cell
                    NSInteger count = row.currentCells.count;
                    NSMutableArray *array = row.currentCells;
                    BOOL *columnVisibles = row.columnsVisible;
                    for (NSInteger columnIndex = 0; columnIndex != count; columnIndex++) {
                        BHFormViewCell *cell = array[columnIndex];
                        columnVisibles[columnIndex] = NO;
                        if ((NSNull *)cell != [NSNull null]) {
                            [cell removeFromSuperview];
                            [self addCellToReusePool:cell];
                            array[columnIndex] = [NSNull null];
                        }
                    }
                }
                row.hasVisibleCell = NO;
            }
            else
            {
                if (lowerIndex  < minVisibleIndex) {
                    minVisibleIndex = lowerIndex;
                }
                if (lowerIndex > maxVisibleRowIndex) {
                    maxVisibleRowIndex = lowerIndex;
                }
                hasLowerRowVisible = YES;
                row.visible = YES;
                //                printf("\n lower visible rowIndex = %d hasVeryHighCell %d",row.rowIndex,row.hasVeryHighCell);
            }
            lowerIndex--;
        }
        
        if (upperIndex == rowCount && lowerIndex == -1) {
            break;
        }
    }
    _midVisibleRowIndex = (minVisibleIndex + maxVisibleRowIndex) / 2;
    for (BHFormViewRow *row in _Rows) {
        NSInteger visibleMinIndex = 0;
        NSInteger visibleMaxIndex = row.columnCount - 1;
        NSInteger columnCount = row.columnCount;
        if (row.visible) {
            CGRect *rects = row.rectsForCells;
            BOOL *columnVisibles = row.columnsVisible;
            NSInteger lowerIndex = row.midVisibleColumn,upperIndex = MIN(lowerIndex + 1, columnCount -1);
//            printf("\n row.midVisibleColumn %d",row.midVisibleColumn);
            BOOL hasLowerVisible = NO,hasUpperVisible = NO;
            while (1) {
                BOOL visible = NO;
                //                    printf("\n row.hasVeryHighCell %d row.index %d",row.hasVeryHighCell,row.rowIndex);
                if (lowerIndex >= 0) {
                    visible = isVisibleRect(rects[lowerIndex], visibleMinX, visibleMinY, visibleMaxX, visibleMaxY);
                    columnVisibles[lowerIndex] = visible;
                    if (visible) {
                        row.visible = YES;
                        hasLowerVisible = YES;
                        if (lowerIndex < visibleMinIndex) {
                            visibleMinIndex = lowerIndex;
                        }
                        if (lowerIndex > visibleMaxIndex) {
                            visibleMaxIndex = lowerIndex;
                        }
                        //获取一个新的cell
                        if (row.currentCells[lowerIndex] == [NSNull null]) {
                            BHFormViewCell *cell = [_dataSource formView:self cellForRow:row.rowIndex column:lowerIndex];
                            cell.frame = row.rectsForCells[lowerIndex];
                            row.currentCells[lowerIndex] = cell;
                            [self addSubview:cell];
                            row.hasVisibleCell = YES;
                        }
                    }
                    else if (hasLowerVisible && !row.hasVeryHighCell){
                        for (NSInteger columnIndex = lowerIndex; columnIndex != -1; columnIndex--) {
                            BHFormViewCell *cell = (BHFormViewCell *)row.currentCells[columnIndex];
                            if ((NSNull *)cell != [NSNull null]) {
                                [cell removeFromSuperview];
                                [self addCellToReusePool:cell];
                                row.currentCells[columnIndex] = [NSNull null];
                            }
                            columnVisibles[columnIndex] = NO;
                        }
                        //隐藏的cell移入重用池
                        lowerIndex = 0;
                    }
                    else if (row.currentCells[lowerIndex] != [NSNull null])
                    {
                        BHFormViewCell *cell = (BHFormViewCell *)row.currentCells[lowerIndex];
                        if ((NSNull *)cell != [NSNull null]) {
                            [cell removeFromSuperview];
                            [self addCellToReusePool:cell];
                            row.currentCells[lowerIndex] = [NSNull null];
                        }
                    }
                }
                if (upperIndex != columnCount) {
                    visible = isVisibleRect(rects[upperIndex], visibleMinX, visibleMinY, visibleMaxX, visibleMaxY);
                    if (visible) {
                        row.visible = YES;
                        hasUpperVisible = YES;
                        if (upperIndex < visibleMinIndex) {
                            visibleMinIndex = lowerIndex;
                        }
                        if (upperIndex > visibleMaxIndex) {
                            visibleMaxIndex = upperIndex;
                        }
                        //获取一个新的cell
                        if (row.currentCells[upperIndex] == [NSNull null]) {
                            BHFormViewCell *cell = [_dataSource formView:self cellForRow:row.rowIndex column:upperIndex];
                            cell.frame = row.rectsForCells[upperIndex];
                            row.currentCells[upperIndex] = cell;
                            [self addSubview:cell];
                            row.hasVisibleCell = YES;
                        }
                    }else if (hasUpperVisible && !row.hasVeryHighCell){
                        for (NSInteger columnIndex = upperIndex; columnIndex != columnCount; columnIndex++) {
                            BHFormViewCell *cell = (BHFormViewCell *)row.currentCells[columnIndex];
                            if ((NSNull *)cell != [NSNull null]) {
                                [cell removeFromSuperview];
                                [self addCellToReusePool:cell];
                                row.currentCells[columnIndex] = [NSNull null];
                            }
                            columnVisibles[columnIndex] = NO;
                        }
                        //隐藏的cell移入重用池
                        upperIndex = columnCount;
                    }else if (row.currentCells[upperIndex] != [NSNull null])
                    {
                        BHFormViewCell *cell = (BHFormViewCell *)row.currentCells[upperIndex];
                        if ((NSNull *)cell != [NSNull null]) {
                            [cell removeFromSuperview];
                            [self addCellToReusePool:cell];
                            row.currentCells[upperIndex] = [NSNull null];
                        }
                    }
                }
                if (lowerIndex == 0 && (upperIndex == columnCount)) {
                    break;
                }
                if (lowerIndex != 0) {
                    lowerIndex--;
                }
                if (upperIndex != columnCount) {
                    upperIndex++;
                }
            }
            row.minVisibleColumn = MAX(visibleMinIndex, 0);
            row.maxVisibleColumn = MAX(visibleMaxIndex, 0);
//            printf("\n visibleMinIndex = %d visibleMaxIndex = %d",visibleMinIndex,visibleMaxIndex);
            row.midVisibleColumn = (visibleMinIndex + visibleMaxIndex) / 2;
        }
        else{
            visibleMinIndex = columnCount / 2;
            visibleMaxIndex = columnCount / 2;
            row.midVisibleColumn = columnCount / 2;
        }
    }
    //根据当前可视的cell重新填写内容。
}

-(void)addCellToReusePool:(BHFormViewCell *)cell{
    if (_reusePoolDict == nil) {
        _reusePoolDict = [NSMutableDictionary new];
    }
    NSMutableArray *poolForIdentifier = _reusePoolDict[cell.reuseIdentifier];
    if (poolForIdentifier == nil) {
        poolForIdentifier = [NSMutableArray arrayWithCapacity:64];
        _reusePoolDict[cell.reuseIdentifier] = poolForIdentifier;
    }
    [cell cellWillBeRecycled];
    if (poolForIdentifier.count < 1024) {
        [poolForIdentifier addObject:cell];
                printf("\n 单元格被回收 _reusePoolDict %d",poolForIdentifier.count);
    }
}

-(BHFormViewCell *)cellForReuseId:(NSString *)reuseId{
    if (_reusePoolDict == nil) {
        return nil;
    }
    NSMutableArray *poolForIdentifier = _reusePoolDict[reuseId];
    if ([poolForIdentifier count]) {
        BHFormViewCell *cell = [poolForIdentifier lastObject];
        [poolForIdentifier removeLastObject];
                printf("\n 单元格被重用 _reusePoolDict %d",poolForIdentifier.count);
        return cell;
    }
    return nil;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    if (!_isReloading && [self.delegate respondsToSelector:@selector(formView:didTapColumn:inRow:)]){
        UITouch *touch = [touches anyObject];
        CGPoint point =  [touch locationInView:self];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            for (BHFormViewRow *row in _Rows) {
                if (row.visible) {
                    NSInteger count = row.columnCount;
                    CGRect *rect = row.rectsForCells;
                    for (NSInteger i = 0; i != count; i++) {
                        if (CGRectContainsPoint(rect[i], point)) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.delegate formView:self didTapColumn:i inRow:row.rowIndex];
                            });
                            break;
                        }
                    }
                }
            }
        });
    }
}

-(void)dealloc{
    if (_veryHighCellsRects) {
        free(_veryHighCellsRects);
    }
}

@end
