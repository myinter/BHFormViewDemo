//
//  BHFormView.h
//  BHFormViewDemo
//
//  Created by 熊伟 on 2016/5/16.
//  Copyright © 2016年 熊伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BHFormView;

//typedef NS_ENUM(NSInteger, BHFormViewMode)
//{
//    BHFormViewModeDefault,
//    BHFormViewModeLeft,
//    BHFormViewModeRight,
//    BHFormViewModeMiddle,
//};

@protocol BHFormViewDataSource <NSObject>
/*获取函数*/
- (NSInteger)numberOfRowsInFormView:(BHFormView *)formView;
/*获取每一行的列数*/
- (NSInteger)formViewColumnsInRow:(BHFormView *)formView;
/*指定某行某列的宽度*/
- (CGFloat)formView:(BHFormView *)formView widthForColumn:(NSInteger)column;
/*指定行的內容*/
- (NSString *)formView:(BHFormView *)formView textForColumn:(NSInteger)column inRow:(NSInteger)row;
/*指定某行的基准高度*/
- (CGFloat)formView:(BHFormView *)formView heightForRow:(NSInteger)row;
@optional
/*指定某行某列的单元格的高度*/
- (CGFloat)formView:(BHFormView *)formView heightForColumn:(NSInteger)column atRow:(NSInteger)row;
/*指定某一单元格的背景颜色，若返回nil，则按默认规则指定单元格颜色*/
- (UIColor *)formView:(BHFormView *)formView backgroundColorOfColumn:(NSInteger)column inRow:(NSInteger)row;
/*返回某一单元格文本颜色*/
- (UIColor *)formView:(BHFormView *)formView textColorOfColumn:(NSInteger)column inRow:(NSInteger)row;
/*返回边框的颜色*/
- (UIColor *)formViewBorderColor:(BHFormView *)formView;
/*返回内容文本的字体*/
- (UIFont *)formViewFontOfContent:(BHFormView *)formView;
/*指定某一行内容的字体，若返回空，则使用全局字体*/
- (UIFont *)formViewFontOfContent:(BHFormView *)formView forColumn:(NSInteger)column inRow:(NSInteger)row;
/*是否需要为某一行侦听点击事件*/
- (BOOL)formView:(BHFormView *)formView addActionForColumn:(NSInteger)column inRow:(NSInteger)row;
/*返回某一行的单元格数量，弱没有实现这个方法，则使用- (NSInteger)formViewColumnsInRow:(BHFormView *)formView 返回的全局同一的列数*/
- (NSInteger)formView:(BHFormView *)formView numberOfColumnsInRow:(NSInteger)row;
/*返回某行某列的宽度，若没有实现这个方法，则使用 - (CGFloat)formView:(BHFormView *)formView widthForColumn:(NSInteger)column 返回的全局宽度*/
- (CGFloat)formView:(BHFormView *)formView widthForColumn:(NSInteger)column atRow:(NSInteger)row;
@end

@protocol BHFormViewDelegate <NSObject>
@optional
/*某个单元格被点击时间的代理方法*/
- (void)formView:(BHFormView *)formView didTapColumn:(NSInteger)column inRow:(NSInteger)row;
@end

@interface BHFormView : UIView
{
    NSMutableArray *currentCellBtns;
    CGFloat margin;
}
@property (nonatomic, weak) id<BHFormViewDataSource> dataSource;
@property (nonatomic, weak) id<BHFormViewDelegate> delegate;
@property (nonatomic, assign) BOOL thickBorder;
//@property (nonatomic, assign ,readonly) BHFormViewMode mode;
//- (void)setMode:(BHFormViewMode)mode withMargin:(CGFloat)margin;
/*获得某一行某一列的单元格（单元格是一个UIButton）*/
- (UIButton *)itemAtColumn:(NSInteger)column inRow:(NSInteger)row;
- (void)reloadData;
@end