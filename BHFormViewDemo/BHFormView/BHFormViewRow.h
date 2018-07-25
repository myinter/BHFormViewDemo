//
//  BHFormViewRow.h
//  BHFormViewDemo
//
//  Created by bighiung on 2018/7/21.
//  Copyright © 2018年 熊伟. All rights reserved.
//

#import "BHFormViewCell.h"

@interface BHFormViewRow : NSObject
{
	NSInteger _rectsArraySize;
}
@property(nonatomic) CGRect *rectsForCells;
@property(nonatomic,strong) NSMutableArray *currentCells;
@property(nonatomic) NSInteger rowIndex;
@property(nonatomic) NSInteger rectsForCellsSize;
@property(nonatomic) NSInteger columnCount;
@property(nonatomic) CGFloat beginX;
@property(nonatomic) CGFloat beginY;
@property(nonatomic) CGFloat maxX;
@property(nonatomic) CGFloat maxY;
@property(nonatomic) BOOL *columnsVisible;
@property(nonatomic) BOOL visible;
@property(nonatomic) BOOL hasVeryHighCell;
@property(nonatomic) CGRect viewPotRect;
@property(nonatomic) NSInteger midVisibleColumn;
@property(nonatomic) NSInteger minVisibleColumn;
@property(nonatomic) NSInteger maxVisibleColumn;

@end
