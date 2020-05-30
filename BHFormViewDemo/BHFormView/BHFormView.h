//
//  BHFormView.h
//  BHFormViewDemo
//
//  Created by 熊韦华 on 2016/5/16.
//  Copyright © 2016年 熊韦华. All rights reserved.
//  Version 2.0 @2018.7
//
#import <UIKit/UIKit.h>
#import "BHFormViewLine.h"
#import "BHFormViewCell.h"
#import "BHFormViewComponent.h"
typedef NS_ENUM(NSUInteger, BHFormViewLayoutMode) {
    BHRowFirstMode = 0, //行优先模式
    BHColumnFirstMode, //列优先模式
};
@class BHFormView;

@protocol BHFormViewDataSource <NSObject>
/*获取函数*/
- (NSInteger)numberOfLinesInFormView:(BHFormView *)formView;
/*获取每一行的列数*/
- (NSInteger)formViewItemsInLine:(BHFormView *)formView;
/*指定某列/行的宽度/高度*/
- (CGFloat)formView:(BHFormView *)formView sizeForItemIndex:(NSInteger)item;
/*获取指定行的cell*/
-(BHFormViewCell *)formView:(BHFormView *)formView cellForLine:(NSInteger)lineIndex item:(NSInteger)itemIndex;
/*指定某行/列的基准高度/宽度*/
- (CGFloat)formView:(BHFormView *)formView sizeForLine:(NSInteger)line;
@optional
/*指定某行某列的单元格的高/宽度*/
- (CGFloat)formView:(BHFormView *)formView heightForItem:(NSInteger)item atLine:(NSInteger)line;
/*返回某一行的单元格数量，若没有实现这个方法，则使用- (NSInteger)formViewItemsInLine:(BHFormView *)formView 返回的全局统一的行列内单元格数*/
- (NSInteger)formView:(BHFormView *)formView numberOfItemsInLine:(NSInteger)line;
/*返回某行某列的，若没有实现这个方法，则使用 - (CGFloat)formView:(BHFormView *)formView widthForColumn:(NSInteger)column 返回的全局宽度*/
- (CGFloat)formView:(BHFormView *)formView widthForItem:(NSInteger)column atLine:(NSInteger)row;
/*
 获取当前的布局模式，不返回则使用默认的布局模式
 */
- (BHFormViewLayoutMode)formViewLayoutMode:(BHFormView *)formView;

@end

@protocol BHFormViewDelegate <NSObject>
@optional
/*某个单元格被点击时间的代理方法*/
- (void)formView:(BHFormView *)formView didTapColumn:(NSInteger)column inRow:(NSInteger)row;

/*
 某个单元格即将被显示出来
*/
- (void)formView:(BHFormView *)formView willDisplayCell:(BHFormViewCell *)cell forItem:(NSInteger)column atLine:(NSInteger)row;
/*
 某个单元格将结束显示
*/
- (void)formView:(BHFormView *)formView willEndDisplayCell:(BHFormViewCell *)cell forItem:(NSInteger)column atLine:(NSInteger)row;

@end
//@class BHFormItem;
@interface BHFormView : UIScrollView<UIScrollViewDelegate>
{
    CGFloat margin;
    NSInteger lineCount;
    CGFloat maxWidth;
    CGFloat maxHeight;
    NSMutableArray<BHFormViewLine *> *_lines;
    NSMutableDictionary *_reusePoolDict;
    CGPoint _lastContentOffest;
    CGRect *_sizeOverflowCellsRects;
    NSInteger _sizeOverflowCellsCount;
    NSInteger _veryHighCellsContainerSize;
    NSInteger _midVisibleLineIndex;
    CGFloat _minCellSizeWidth;
    CGFloat _minCellSizeHeight;
    BHFormViewLayoutMode _currentLayoutMode;
}
@property (nonatomic, weak) IBOutlet id<BHFormViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<BHFormViewDelegate> delegate;
@property (nonatomic) BOOL  isReloading;
//默认为1，用于等比例缩放所有cell的位置的大小
@property (nonatomic, assign) CGFloat cellScale;
- (void)reloadData;
/*只重新加载当前单元格的信息，而不会重新加载布局信息*/
- (void)reloadDataWithoutNewItemsAndLayoutInfos;
-(BHFormViewCell *)cellForReuseId:(NSString *)reuseId;
/*
 单独重新加载某一个位置的单元格的数据
 */
-(void)reloadCellAtRow:(NSInteger)row column:(NSInteger)column;

@end
