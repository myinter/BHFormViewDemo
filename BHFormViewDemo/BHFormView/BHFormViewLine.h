//
//  BHFormViewRow.h
//  BHFormViewDemo
//
//  Created by bighiung on 2018/7/21.
//  Copyright © 2018年 熊伟. All rights reserved.
//

#import "BHFormViewCell.h"

@interface BHFormViewLine : NSObject
{
	NSInteger _rectsArraySize;
}
@property(nonatomic) CGRect *rectsForCells;
@property(nonatomic,strong) NSMutableArray *currentCells;
@property(nonatomic) NSInteger lineIndex;
@property(nonatomic) NSInteger rectsForCellsSize;
@property(nonatomic) NSInteger itemCount;
@property(nonatomic) CGFloat beginX;
@property(nonatomic) CGFloat beginY;
@property(nonatomic) CGFloat maxX;
@property(nonatomic) CGFloat maxY;
@property(nonatomic) BOOL *itemsVisibilities;
@property(nonatomic) BOOL visible;
/*
    是否存在长款超过当前行列基准长款的cell
 */
@property(nonatomic) BOOL hasCrossLineCell;
@property(nonatomic) CGRect viewPotRect;
@property(nonatomic) NSInteger midVisibleItemIndex;
@property(nonatomic) NSInteger minVisibleItem;
@property(nonatomic) NSInteger maxVisibleItem;
@property(nonatomic) BOOL hasVisibleCell;
@property(nonatomic) CGFloat standardSizeForItem;

@end
