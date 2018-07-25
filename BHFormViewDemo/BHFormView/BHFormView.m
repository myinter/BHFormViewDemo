//
//  BHFormView.m
//  BHFormViewDemo
//
//  Created by 熊伟 on 2016/5/16.
//  Copyright © 2016年 熊伟. All rights reserved.
//

#import "BHFormView.h"
#import "UIImage+FuntionExtention.h"

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
	_veryHighCellsRects = (CGRect *)malloc(sizeof(CGRect) * 512);
	_veryHighCellsCount = 0;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    //重新载入数据
    if (_dataSource) {
        [self reloadData];
    }
}

-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    contentScrollView.frame = self.bounds;
}

-(void)reloadData
{
	static BOOL isReloading;
    if (contentScrollView == nil) {
        contentScrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        contentScrollView.delegate = self;
		[self addSubview:contentScrollView];
    }
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		while (isReloading) {
			usleep(16*1000);
		}
		isReloading = YES;
		
		NSMutableArray *newRows = [NSMutableArray arrayWithCapacity:rowCount];
		NSInteger newRowCount = [_dataSource numberOfRowsInFormView:self];
		CGFloat newMaxHeight = 0.0f;
		CGFloat newMaxWidth = 0.0f;
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
			rowCount = newRowCount;
			_Rows = newRows;
			maxHeight = newMaxHeight;
			maxWidth = newMaxWidth;
			contentScrollView.contentSize = CGSizeMake(maxWidth, maxHeight);
			[self refreshCells];
		});
		isReloading = NO;
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    contentScrollView.contentSize = CGSizeMake(maxWidth, maxHeight);
	if (ABS(_lastContentOffest.x - scrollView.contentOffset.x) + ABS(_lastContentOffest.y - scrollView.contentOffset.y) > 15.0) {
		_lastContentOffest = scrollView.contentOffset;
		[self refreshCells];
	}
}

/*刷新当前的Cell*/
-(void)refreshCells
{
	CGFloat visibleMinX = contentScrollView.contentOffset.x;
	CGFloat visibleMinY = contentScrollView.contentOffset.y;
	CGFloat visibleMaxX = visibleMinX + contentScrollView.bounds.size.width;
	CGFloat visibleMaxY = visibleMinY + contentScrollView.bounds.size.height;
		for (BHFormViewRow *row in _Rows) {
			if ((row.beginX > visibleMaxX || row.maxX < visibleMinX) || (row.beginY > visibleMaxY || row.maxY < visibleMinY)) {
				row.visible = NO;
			}
			else{
				row.visible = YES;
			}
		}
		for (BHFormViewRow *row in _Rows) {
			NSInteger visibleMinIndex = NSNotFound;
			NSInteger visibleMaxIndex = 0;
			if (row.visible) {
				CGRect *rects = row.rectsForCells;
				BOOL *columnVisibles = row.columnsVisible;
				NSInteger columnCount = row.columnCount;
				NSInteger lowerIndex = row.midVisibleColumn,upperIndex = lowerIndex + 1;
				BOOL hasLowerVisible = NO,hasUpperVisible = NO;
				while (1) {
					BOOL visible = NO;
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
								[contentScrollView addSubview:cell];
							}
						}
						else if (hasLowerVisible){
							for (int columnIndex = lowerIndex; columnIndex != -1; columnIndex--) {
								BHFormViewCell *cell = (BHFormViewCell *)row.currentCells[columnIndex];
								if (cell != [NSNull null]) {
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
							if (cell != [NSNull null]) {
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
								visibleMinIndex = upperIndex;
							}
							if (upperIndex > visibleMaxIndex) {
								visibleMaxIndex = upperIndex;
							}
							//获取一个新的cell
							if (row.currentCells[upperIndex] == [NSNull null]) {
								BHFormViewCell *cell = [_dataSource formView:self cellForRow:row.rowIndex column:upperIndex];
								cell.frame = row.rectsForCells[upperIndex];
								row.currentCells[upperIndex] = cell;
								[contentScrollView addSubview:cell];
							}
						}else if (hasUpperVisible){
							for (NSInteger columnIndex = upperIndex; columnIndex != columnCount; columnIndex++) {
								BHFormViewCell *cell = (BHFormViewCell *)row.currentCells[columnIndex];
								if (cell != [NSNull null]) {
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
								if (cell != [NSNull null]) {
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
			}
			else{
				//移除全部cell
					NSInteger count = row.currentCells.count;
					NSMutableArray *array = row.currentCells;
					BOOL *columnVisibles = row.columnsVisible;
					for (NSInteger columnIndex = 0; columnIndex != count; columnIndex++) {
						BHFormViewCell *cell = array[columnIndex];
						columnVisibles[columnIndex] = NO;
						if (cell != [NSNull null]) {
								[cell removeFromSuperview];
								[self addCellToReusePool:cell];
							array[columnIndex] = [NSNull null];
						}
					}
				visibleMinIndex = 0;
				visibleMaxIndex = 0;
			}
			row.minVisibleColumn = visibleMinIndex;
			row.maxVisibleColumn = visibleMaxIndex;
			row.midVisibleColumn = (visibleMinIndex + visibleMaxIndex) / 2;
		}
	//根据当前可视的cell重新填写内容。
}

-(void)reloadCell{
	for (BHFormViewRow *row in _Rows) {
		NSInteger columnCount = row.columnCount;
		NSMutableArray *array = row.currentCells;
		BOOL *columnVisibles = row.columnsVisible;
		CGRect *rectsForCells = row.rectsForCells;
		if (row.visible) {
			for (NSInteger columnIndex = 0; columnIndex!=columnCount; columnIndex++) {
				if (columnVisibles[columnIndex]) {
					//获取一个新的cell
					if (array[columnIndex] == [NSNull null]) {
						BHFormViewCell *cell = [_dataSource formView:self cellForRow:row.rowIndex column:columnIndex];
						cell.frame = rectsForCells[columnIndex];
						row.currentCells[columnIndex] = cell;
						[contentScrollView addSubview:cell];
					}
				}else if (array[columnIndex] != [NSNull null]){
					BHFormViewCell *cell = array[columnIndex];
					[cell removeFromSuperview];
					[self addCellToReusePool:cell];
				}
			}
		}
		else{
			for (NSInteger columnIndex = 0; columnIndex!=columnCount; columnIndex++) {
				if (array[columnIndex] != [NSNull null]) {
					BHFormViewCell *cell = array[columnIndex];
					[cell removeFromSuperview];
					[self addCellToReusePool:cell];
					array[columnIndex] = [NSNull null];
				}
			}
		}
	}
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
	if (poolForIdentifier.count < 1024) {
		[cell cellWillBeRecycled];
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
	if ([_delegate respondsToSelector:@selector(formView:didTapColumn:inRow:)]){
		UITouch *touch = [touches anyObject];
		CGPoint point =  [touch locationInView:contentScrollView];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
			for (BHFormViewRow *row in _Rows) {
				if (row.visible) {
					NSInteger count = row.columnCount;
					CGRect *rect = row.rectsForCells;
					for (NSInteger i = 0; i != count; i++) {
						if (CGRectContainsPoint(rect[i], point)) {
							dispatch_async(dispatch_get_main_queue(), ^{
								[_delegate formView:self didTapColumn:i inRow:row.rowIndex];
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

- (void)itemClicked:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(formView:didTapColumn:inRow:)]) {
        NSInteger row = (sender.tag - 10000) / 100;
        NSInteger col = (sender.tag - 10000) - row * 100;
        [_delegate formView:self didTapColumn:col inRow:row];
    }
}

@end
