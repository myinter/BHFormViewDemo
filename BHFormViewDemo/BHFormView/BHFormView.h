//
//  BHFormView.h
//  BHFormViewDemo
//
//  Created by 熊韦华 on 2016/5/16.
//  Copyright © 2016年 熊韦华. All rights reserved.
//  Version 2.0 @2018.7
//

#import <UIKit/UIKit.h>
#import "BHFormViewRow.h"
#import "BHFormViewCell.h"
#import "BHFormViewComponent.h"

@class BHFormView;

@protocol BHFormViewDataSource <NSObject>
/*获取函数*/
- (NSInteger)numberOfRowsInFormView:(BHFormView *)formView;
/*获取每一行的列数*/
- (NSInteger)formViewColumnsInRow:(BHFormView *)formView;
/*指定某列的宽度*/
- (CGFloat)formView:(BHFormView *)formView widthForColumn:(NSInteger)column;
/*获取指定行的cell*/
-(BHFormViewCell *)formView:(BHFormView *)formView cellForRow:(NSInteger)row column:(NSInteger)column;
/*指定某行的基准高度*/
- (CGFloat)formView:(BHFormView *)formView heightForRow:(NSInteger)row;
@optional
/*指定某行某列的单元格的高度*/
- (CGFloat)formView:(BHFormView *)formView heightForColumn:(NSInteger)column atRow:(NSInteger)row;
/*返回某一行的单元格数量，若没有实现这个方法，则使用- (NSInteger)formViewColumnsInRow:(BHFormView *)formView 返回的全局同一的列数*/
- (NSInteger)formView:(BHFormView *)formView numberOfColumnsInRow:(NSInteger)row;
/*返回某行某列的宽度，若没有实现这个方法，则使用 - (CGFloat)formView:(BHFormView *)formView widthForColumn:(NSInteger)column 返回的全局宽度*/
- (CGFloat)formView:(BHFormView *)formView widthForColumn:(NSInteger)column atRow:(NSInteger)row;
@end

@protocol BHFormViewDelegate <NSObject>
@optional
/*某个单元格被点击时间的代理方法*/
- (void)formView:(BHFormView *)formView didTapColumn:(NSInteger)column inRow:(NSInteger)row;
@end
@class BHFormItem;
@interface BHFormView : UIView<UIScrollViewDelegate>
{
    UIScrollView *contentScrollView;
    CGFloat margin;
    NSInteger rowCount;
    CGFloat maxWidth;
    CGFloat maxHeight;
	NSMutableArray<BHFormViewRow *> *_Rows;
	NSMutableDictionary *_reusePoolDict;
	CGPoint _lastContentOffest;
	CGRect *_veryHighCellsRects;
	NSInteger _veryHighCellsCount;
	NSInteger _veryHighCellsContainerSize;
}
@property (nonatomic, weak) id<BHFormViewDataSource> dataSource;
@property (nonatomic, weak) id<BHFormViewDelegate> delegate;
@property (nonatomic, assign) BOOL thickBorder;
- (void)reloadData;
-(BHFormViewCell *)cellForReuseId:(NSString *)reuseId;
@end
