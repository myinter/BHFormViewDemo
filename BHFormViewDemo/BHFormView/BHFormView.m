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
    _veryHighCellsContainerSize = 256;
    _sizeOverflowCellsRects = (CGRect *)malloc(sizeof(CGRect) * 256);
    _sizeOverflowCellsCount = 0;
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
    //所有行的单元格全部放入重用池 Put all the cells into reusePool
        NSMutableArray *newRows = [NSMutableArray arrayWithCapacity:lineCount];
        NSInteger newLineCount = [_dataSource numberOfLinesInFormView:self];
        CGFloat newMaxHeight = 0.0;
        CGFloat newMaxWidth = 0.0;
        CGFloat newMinCellSizeWidth = 70.0;
        CGFloat newMinCellSizeHeight = 70.0;
        _sizeOverflowCellsCount = 0;
        CGFloat baseY = 0.0;
        CGFloat baseX = 0;
        
        //获取当前的布局模式，行优先，还是列优先
        if ([_dataSource respondsToSelector:@selector(formViewLayoutMode:)]) {
            _currentLayoutMode = [_dataSource formViewLayoutMode:self];
        }
        else
        {
            //默认使用行优先模式
            _currentLayoutMode = BHRowFirstMode;
        }
        
        for (NSInteger lineIndex = 0; lineIndex != newLineCount; lineIndex++) {
            switch (_currentLayoutMode) {
                case BHColumnFirstMode:
                {
                    //列优先模式，每一列Y重新计算
                    baseY = 0.0;
                }
                    break;
                case BHRowFirstMode:
                {
                    //行优先模式,每一行X值重新计算
                    baseX = 0.0;
                }
                    break;
                default:
                    break;
            }
            
            BHFormViewLine *line = [BHFormViewLine new];
            line.lineIndex = lineIndex;
            line.beginX = MAXFLOAT;
            line.beginY = MAXFLOAT;
            NSInteger itemCount = 0;
            if ([_dataSource respondsToSelector:@selector(formView:numberOfItemsInLine:)]) {
                itemCount = [_dataSource formView:self numberOfItemsInLine:lineIndex];
            }
            else{
                if ([_dataSource respondsToSelector:@selector(formViewItemsInLine:)]) {
                    itemCount = [_dataSource formViewItemsInLine:self];
                }
            }
            
            line.itemCount = itemCount;
            line.midVisibleItemIndex = itemCount / 2;
            CGFloat lineBaseSize = [_dataSource formView:self sizeForLine:lineIndex];
            line.standardSizeForItem = lineBaseSize;
            line.hasCrossLineCell = NO;
            for (int itemIndex = 0; itemIndex!= itemCount; itemIndex++) {
                CGFloat itemSize = lineBaseSize;
                CGFloat itemWidth = 0.0;
                CGFloat itemHeight = 0.0;
                
                if ([_dataSource respondsToSelector:@selector(formView:sizeForItemIndex:)]) {
                    itemSize = [_dataSource formView:self sizeForItemIndex:itemIndex];
                    switch (_currentLayoutMode) {
                        case BHColumnFirstMode:
                        {
                            //列优先模式
                            itemWidth = itemSize;
                        }
                            break;
                        case BHRowFirstMode:
                        {
                            //行优先模式
                            itemHeight = itemSize;
                        }
                            break;
                        default:
                            break;
                    }
                }

                if ([_dataSource respondsToSelector:@selector(formView:widthForItem:atLine:)]) {
                    itemWidth = [_dataSource formView:self widthForItem:itemIndex atLine:line.lineIndex];
                }
                else
                {
                    switch (_currentLayoutMode) {
                        case BHColumnFirstMode:
                        {
                            //列优先模式
                            itemWidth = lineBaseSize;
                        }
                            break;
                        case BHRowFirstMode:
                        {
                            //行优先模式
                            itemWidth = [_dataSource formView:self sizeForItemIndex:itemIndex];
                        }
                            break;
                        default:
                            break;
                    }
                }
                
                if ([_dataSource respondsToSelector:@selector(formView:heightForItem:atLine:)]) {
                    itemHeight = [_dataSource formView:self heightForItem:itemIndex atLine:lineIndex];
                }
                else
                {
                    switch (_currentLayoutMode) {
                        case BHColumnFirstMode:
                        {
                            //列优先模式
                            itemHeight = [_dataSource formView:self sizeForItemIndex:itemIndex];
                        }
                            break;
                        case BHRowFirstMode:
                        {
                            //行优先模式
                            itemHeight = lineBaseSize;
                        }
                            break;
                        default:
                            break;
                    }
                }
                                
                _minCellSizeWidth = MIN(itemWidth, newMinCellSizeWidth);
                _minCellSizeHeight = MIN(itemHeight, newMinCellSizeHeight);
                
                CGRect rectForItemCell = CGRectMake(baseX, baseY, itemWidth, itemHeight);
                rectForItemCell = CheckCollisionWithRectsInLines(_sizeOverflowCellsRects,_sizeOverflowCellsCount, rectForItemCell);
                
                switch (_currentLayoutMode) {
                    case BHColumnFirstMode:
                    {
                        //列优先模式
                        itemSize = itemWidth;
                    }
                        break;
                    case BHRowFirstMode:
                    {
                        //行优先模式
                        itemSize = itemHeight;
                    }
                        break;
                    default:
                        break;
                }
                
                if (itemSize > lineBaseSize) {
                    line.hasCrossLineCell = YES;
                    if (_sizeOverflowCellsCount == _veryHighCellsContainerSize) {
                        CGRect *newRectContainingPointer = (CGRect *)malloc(sizeof(CGRect) * (_veryHighCellsContainerSize*=2));
                        memcpy(newRectContainingPointer, _sizeOverflowCellsRects, _sizeOverflowCellsCount * sizeof(CGRect));
                        free(_sizeOverflowCellsRects);
                        _sizeOverflowCellsRects = newRectContainingPointer;
                    }
                    _sizeOverflowCellsRects[_sizeOverflowCellsCount] = rectForItemCell;
                    _sizeOverflowCellsCount++;
                }
                line.rectsForCells[itemIndex] = rectForItemCell;
                if (rectForItemCell.origin.y < line.beginY) {
                    line.beginY = rectForItemCell.origin.y;
                }
                if (rectForItemCell.origin.x < line.beginX) {
                    line.beginX = rectForItemCell.origin.x;
                }
                CGFloat maxX = CGRectGetMaxX(rectForItemCell);
                CGFloat maxY = CGRectGetMaxY(rectForItemCell);
                switch (_currentLayoutMode) {
                    case BHColumnFirstMode:
                    {
                        //列优先模式
                        baseY = maxY;
                    }
                        break;
                    case BHRowFirstMode:
                    {
                        //行优先模式
                        baseX = maxX;
                    }
                        break;
                    default:
                        break;
                }

                if (line.maxX < maxX) {
                    line.maxX = maxX;
                }
                if (newMaxWidth < maxX) {
                    newMaxWidth = maxX;
                }
                if (line.maxY < maxY) {
                    line.maxY = maxY;
                }
                if (newMaxHeight < maxY) {
                    newMaxHeight = maxY;
                }
            }
            [newRows addObject:line];
            
            switch (_currentLayoutMode) {
                case BHColumnFirstMode:
                {
                    //列优先模式，每一列Y重新计算
                    baseX += lineBaseSize;
                }
                    break;
                case BHRowFirstMode:
                {
                    //行优先模式,每一行X值重新计算
                    baseY += lineBaseSize;
                }
                    break;
                default:
                    break;
            }

        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //原有单元格全部回收到重用池
            for (BHFormViewLine *line in _lines) {
                for (BHFormViewCell *cell in line.currentCells) {
                    if ((NSNull *)cell != [NSNull null]) {
                        [cell removeFromSuperview];
                        [self addCellToReusePool:cell];
                    }
                }
            }
            lineCount = newLineCount;
            _lines = newRows;
            maxHeight = newMaxHeight;
            maxWidth = newMaxWidth;
            _minCellSizeWidth = newMinCellSizeWidth / 4;
            _minCellSizeHeight = newMinCellSizeHeight / 4;
            _midVisibleLineIndex = lineCount / 2;
            self.contentSize = CGSizeMake(maxWidth, maxHeight);
            [self refreshCells];
            _isReloading = NO;
        });
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
    NSInteger count = _lines.count;
    if (count!=0) {
        for (NSInteger index = 0; index != count; index++) {
            BHFormViewLine *row = _lines[index];
            NSInteger columnCount  = row.itemCount;
            NSArray *cells = row.currentCells;
                if (row.visible && columnCount) {
                        BOOL *visibles = row.itemsVisibilities;
                        for (NSInteger columnIndex = 0; columnIndex != columnCount; columnIndex++) {
                            if (visibles[columnIndex]) {
                                BHFormViewCell *cell = cells[columnIndex];
                                if (cell != (BHFormViewCell *)[NSNull null]) {
                                    if ([self.delegate respondsToSelector:@selector(formView:willEndDisplayCell:forItem:atLine:)]) {
                                        [self.delegate formView:self willEndDisplayCell:cell forItem:columnIndex atLine:row.lineIndex];
                                    }
                                    [cell removeFromSuperview];
                                    [self addCellToReusePool:cell];
                                }
                                cell = [_dataSource formView:self cellForLine:row.lineIndex item:columnIndex];
                                if ([self.delegate respondsToSelector:@selector(formView:willDisplayCell:forItem:atLine:)]) {
                                    [self.delegate formView:self willEndDisplayCell:cell forItem:columnIndex atLine:row.lineIndex];
                                }
                                row.currentCells[columnIndex] = cell;
                                [self addSubview:cell];
                                cell.frame = row.rectsForCells[columnIndex];
                            }
                        }
                }
        }
    }
}

/*刷新当前的Cell，将当前可见的cell填写上来*/
-(void)refreshCells
{
    CGPoint contentOffset = self.contentOffset;
    CGFloat visibleMinX = contentOffset.x;
    CGFloat visibleMinY = contentOffset.y;
    CGFloat visibleMaxX = visibleMinX + self.bounds.size.width;
    CGFloat visibleMaxY = visibleMinY + self.bounds.size.height;
//    BOOL hasLowerLineVisible = NO,hasUpperLineVisible = NO;
//    NSInteger upperIndex = MIN(_midVisibleLineIndex, lineCount),lowerIndex = _midVisibleLineIndex + 1;
    NSInteger maxVisibleRowIndex  = 0,minVisibleIndex = lineCount - 1;
    
    NSUInteger lineCount = _lines.count;
    
    //统计当前情况下，可见的line
    for (NSUInteger lineIndex = 0; lineIndex != lineCount; lineIndex++) {
        BHFormViewLine *line = _lines[lineIndex];
        if ((line.beginX >= visibleMaxX || line.maxX <= visibleMinX) || (line.beginY >= visibleMaxY || line.maxY <= visibleMinY)) {
            line.visible = NO;
                //移除全部cell
                NSInteger count = line.currentCells.count;
                NSMutableArray *array = line.currentCells;
                BOOL *columnVisibles = line.itemsVisibilities;
                for (NSInteger itemIndex = 0; itemIndex != count; itemIndex++) {
                    BHFormViewCell *cell = array[itemIndex];
                    columnVisibles[itemIndex] = NO;
                    if ((NSNull *)cell != [NSNull null]) {
                        if ([self.delegate respondsToSelector:@selector(formView:willEndDisplayCell:forItem:atLine:)]) {
                            [self.delegate formView:self willEndDisplayCell:cell forItem:itemIndex atLine:line.lineIndex];
                        }
                        [cell removeFromSuperview];
                        [self addCellToReusePool:cell];
                        array[itemIndex] = [NSNull null];
                    }
                }
            line.hasVisibleCell = NO;
        }
        else
        {
            //printf("\n upper visible rowIndex = %d hasVeryHighCell %d",row.rowIndex,row.hasVeryHighCell);
            line.visible = YES;
        }
    }
    
    _midVisibleLineIndex = (minVisibleIndex + maxVisibleRowIndex) / 2;
    for (BHFormViewLine *line in _lines) {
        NSInteger visibleMinIndex = 0;
        NSInteger visibleMaxIndex = line.itemCount - 1;
        NSInteger columnCount = line.itemCount;
        if (line.visible) {
            CGRect *rects = line.rectsForCells;
            BOOL *columnVisibles = line.itemsVisibilities;
            NSInteger lowerIndex = line.midVisibleItemIndex,upperIndex = MIN(lowerIndex + 1, columnCount -1);
//            printf("\n row.midVisibleColumn %d",row.midVisibleColumn);
            BOOL hasLowerVisible = NO,hasUpperVisible = NO;
            while (1) {
                BOOL visible = NO;
                //printf("\n row.hasVeryHighCell %d row.index %d",row.hasVeryHighCell,row.rowIndex);
                if (lowerIndex >= 0) {
                    visible = isVisibleRect(rects[lowerIndex], visibleMinX, visibleMinY, visibleMaxX, visibleMaxY);
                    columnVisibles[lowerIndex] = visible;
                    if (visible) {
                        line.visible = YES;
                        hasLowerVisible = YES;
                        if (lowerIndex < visibleMinIndex) {
                            visibleMinIndex = lowerIndex;
                        }
                        if (lowerIndex > visibleMaxIndex) {
                            visibleMaxIndex = lowerIndex;
                        }
                        //获取一个新的cell
                        if (line.currentCells[lowerIndex] == [NSNull null]) {
                            BHFormViewCell *cell = [_dataSource formView:self cellForLine:line.lineIndex item:lowerIndex];
                            cell.frame = line.rectsForCells[lowerIndex];
                            line.currentCells[lowerIndex] = cell;
                            if ([self.delegate respondsToSelector:@selector(formView:willDisplayCell:forItem:atLine:)]) {
                                [self.delegate formView:self willDisplayCell:cell forItem:lowerIndex atLine:line.lineIndex];
                            }
                            [self addSubview:cell];
                            line.hasVisibleCell = YES;
                        }
                    }
                    else if (hasLowerVisible && !line.hasCrossLineCell){
                        for (NSInteger columnIndex = lowerIndex; columnIndex != -1; columnIndex--) {
                            BHFormViewCell *cell = (BHFormViewCell *)line.currentCells[columnIndex];
                            if ((NSNull *)cell != [NSNull null]) {
                                [cell removeFromSuperview];
                                [self addCellToReusePool:cell];
                                line.currentCells[columnIndex] = [NSNull null];
                            }
                            columnVisibles[columnIndex] = NO;
                        }
                        //隐藏的cell移入重用池
                        lowerIndex = 0;
                    }
                    else if (line.currentCells[lowerIndex] != [NSNull null])
                    {
                        BHFormViewCell *cell = (BHFormViewCell *)line.currentCells[lowerIndex];
                        if ((NSNull *)cell != [NSNull null]) {
                            [cell removeFromSuperview];
                            [self addCellToReusePool:cell];
                            line.currentCells[lowerIndex] = [NSNull null];
                        }
                    }
                }
                if (upperIndex != columnCount) {
                    visible = isVisibleRect(rects[upperIndex], visibleMinX, visibleMinY, visibleMaxX, visibleMaxY);
                    if (visible) {
                        line.visible = YES;
                        hasUpperVisible = YES;
                        if (upperIndex < visibleMinIndex) {
                            visibleMinIndex = lowerIndex;
                        }
                        if (upperIndex > visibleMaxIndex) {
                            visibleMaxIndex = upperIndex;
                        }
                        //获取一个新的cell
                        if (line.currentCells[upperIndex] == [NSNull null]) {
                            BHFormViewCell *cell = [_dataSource formView:self cellForLine:line.lineIndex item:upperIndex];
                            cell.frame = line.rectsForCells[upperIndex];
                            line.currentCells[upperIndex] = cell;
                            [self addSubview:cell];
                            line.hasVisibleCell = YES;
                        }
                    }else if (hasUpperVisible && !line.hasCrossLineCell){
                        for (NSInteger columnIndex = upperIndex; columnIndex != columnCount; columnIndex++) {
                            BHFormViewCell *cell = (BHFormViewCell *)line.currentCells[columnIndex];
                            if ((NSNull *)cell != [NSNull null]) {
                                if ([self.delegate respondsToSelector:@selector(formView:willEndDisplayCell:forItem:atLine:)]) {
                                    [self.delegate formView:self willEndDisplayCell:cell forItem:columnIndex atLine:line.lineIndex];
                                }
                                [cell removeFromSuperview];
                                [self addCellToReusePool:cell];
                                line.currentCells[columnIndex] = [NSNull null];
                            }
                            columnVisibles[columnIndex] = NO;
                        }
                        //隐藏的cell移入重用池
                        upperIndex = columnCount;
                    }else if (line.currentCells[upperIndex] != [NSNull null])
                    {
                        BHFormViewCell *cell = (BHFormViewCell *)line.currentCells[upperIndex];
                        if ((NSNull *)cell != [NSNull null]) {
                            if ([self.delegate respondsToSelector:@selector(formView:willEndDisplayCell:forItem:atLine:)]) {
                                [self.delegate formView:self willEndDisplayCell:cell forItem:upperIndex atLine:line.lineIndex];
                            }
                            [cell removeFromSuperview];
                            [self addCellToReusePool:cell];
                            line.currentCells[upperIndex] = [NSNull null];
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
            line.minVisibleItem = MAX(visibleMinIndex, 0);
            line.maxVisibleItem = MAX(visibleMaxIndex, 0);
//            printf("\n visibleMinIndex = %d visibleMaxIndex = %d",visibleMinIndex,visibleMaxIndex);
            line.midVisibleItemIndex = (visibleMinIndex + visibleMaxIndex) / 2;
        }
        else{
            visibleMinIndex = columnCount / 2;
            visibleMaxIndex = columnCount / 2;
            line.midVisibleItemIndex = columnCount / 2;
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
    [cell removeFromSuperview];
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
            for (BHFormViewLine *row in _lines) {
                if (row.visible) {
                    NSInteger count = row.itemCount;
                    CGRect *rect = row.rectsForCells;
                    for (NSInteger i = 0; i != count; i++) {
                        if (CGRectContainsPoint(rect[i], point)) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.delegate formView:self didTapColumn:i inRow:row.lineIndex];
                            });
                            break;
                        }
                    }
                }
            }
        });
    }
}


-(void)reloadCellAtRow:(NSInteger)row column:(NSInteger)column
{
    NSInteger objIndex = 0;
    
    BHFormViewLine *objLine = nil;
    
    switch (_currentLayoutMode) {
        case BHRowFirstMode:
        {
            objLine = _lines[row];
            objIndex = column;
        }
            break;
        case BHColumnFirstMode:
        {
            objLine = _lines[column];
            objIndex = row;
        }
            break;
        default:
            break;
    }
    if (objLine) {
        if (objLine.currentCells.count > objIndex) {
            BHFormViewCell *cell = objLine.currentCells[objIndex];
            //讲这个单元格回收，并再对应的位置重新加载。
            if ([cell isKindOfClass:[BHFormViewCell class]]) {
                [self addCellToReusePool:cell];
                BHFormViewCell *cell = [_dataSource formView:self cellForLine:row item:column];
                cell.frame = objLine.rectsForCells[objIndex];
                objLine.currentCells[objIndex] = cell;
            }
        }
    }
}

-(void)dealloc{
    if (_sizeOverflowCellsRects) {
        free(_sizeOverflowCellsRects);
    }
}

@end
