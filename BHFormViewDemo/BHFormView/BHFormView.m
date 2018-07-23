//
//  BHFormView.m
//  BHFormViewDemo
//
//  Created by 熊伟 on 2016/5/16.
//  Copyright © 2016年 熊伟. All rights reserved.
//

#import "BHFormView.h"
#import "UIImage+FuntionExtention.h"


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
		rowCount = [_dataSource numberOfRowsInFormView:self];
		_Rows = [NSMutableArray arrayWithCapacity:rowCount];
		maxHeight = 0.0f;
		maxWidth = 0.0f;
		
		CGFloat baseY = 0.0;
		for (NSInteger rowIndex = 0; rowIndex < rowCount; rowIndex++) {
			CGFloat baseX = 0;
			BHFormViewRow *row = [BHFormViewRow new];
			row.rowIndex = rowIndex;
			row.beginX = MAXFLOAT;
			row.beginY = MAXFLOAT;
			NSInteger columnCount = [_dataSource formViewColumnsInRow:self];
			if ([_dataSource respondsToSelector:@selector(formView:numberOfColumnsInRow:)]) {
				columnCount = [_dataSource formView:self numberOfColumnsInRow:rowIndex];
			}
			else{
				if ([_dataSource respondsToSelector:@selector(formViewColumnsInRow:)]) {
					columnCount = [_dataSource formViewColumnsInRow:self];
				}
			}
			row.columnCount = columnCount;
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
					if (columnHeight > rowBaseHeight) {
						row.hasVeryHighCell = YES;
					}
				}
				CGRect rectForColumCell = CGRectMake(baseX, baseY, columnWidth, columnHeight);
				rectForColumCell = CheckCollisionWithRectsInFormerRows(_Rows, rectForColumCell);
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
				if (maxWidth < maxX) {
					maxWidth = maxX;
				}
				CGFloat maxY = CGRectGetMaxY(rectForColumCell);
				if (row.maxY < maxY) {
					row.maxY = maxY;
				}
				if (maxHeight < maxY) {
					maxHeight = maxY;
				}
			}
			[_Rows addObject:row];
			baseY += rowBaseHeight;
		}
		dispatch_async(dispatch_get_main_queue(), ^{
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
	if (ABS(_lastContentOffest.x - scrollView.contentOffset.x) + ABS(_lastContentOffest.y - scrollView.contentOffset.y) > 10.0) {
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
			if (row.visible) {
				BOOL hasVisibleCell = NO;
				CGRect *rects = row.rectsForCells;
				BOOL *columnVisibles = row.columnsVisible;
				NSInteger columnCount = row.columnCount;
				for (int i = 0; i != columnCount; i++) {
					//			rects[i].origin.;
					BOOL visible = isVisibleRect(rects[i], visibleMinX, visibleMinY, visibleMaxX, visibleMaxY);
					if (visible) {
						row.visible = YES;
						hasVisibleCell = YES;
					}
					columnVisibles[i] = visible;
					if (visible) {
						//获取一个新的cell
						if (row.currentCells[i] == [NSNull null]) {
								BHFormViewCell *cell = [_dataSource formView:self cellForRow:row.rowIndex column:i];
								cell.frame = row.rectsForCells[i];
								CGRect rectForColumCell = row.rectsForCells[i];
								row.currentCells[i] = cell;
								[contentScrollView addSubview:cell];
						}
					}else if (hasVisibleCell){
							for (int columnIndex = i; columnIndex != columnCount; columnIndex++) {
								BHFormViewCell *cell = (BHFormViewCell *)row.currentCells[columnIndex];
								if (cell != [NSNull null]) {
									[cell removeFromSuperview];
									[self addCellToReusePool:cell];
									row.currentCells[columnIndex] = [NSNull null];
								}
								columnVisibles[columnIndex] = NO;
							}
						//隐藏的cell移入重用池
						break;
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
			}
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
		[poolForIdentifier addObject:cell];
	}
}

-(BHFormViewCell *)cellForReuseId:(NSString *)reuseId{
	if (_reusePoolDict == nil) {
		return nil;
	}
	NSMutableArray *poolForIdentifier = _reusePoolDict[reuseId];
	if ([poolForIdentifier count]) {
		NSLog(@"单元格重用 _reusePoolDict");
		BHFormViewCell *cell = [poolForIdentifier lastObject];
		[poolForIdentifier removeLastObject];
		return cell;
	}
	return nil;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
	[super touchesBegan:touches withEvent:event];
	if ([_delegate respondsToSelector:@selector(formView:didTapColumn:inRow:)]) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
			UITouch *touch = [touches anyObject];
			CGPoint point =  [touch locationInView:contentScrollView];
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

- (void)itemClicked:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(formView:didTapColumn:inRow:)]) {
        NSInteger row = (sender.tag - 10000) / 100;
        NSInteger col = (sender.tag - 10000) - row * 100;
        [_delegate formView:self didTapColumn:col inRow:row];
    }
}

@end
