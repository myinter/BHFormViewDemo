BHFormView
==

</br>
 
 
 iOS,Android,FromView,TableView.单元格尺寸高度灵活的表格视图
 同样的设计模式和使用方法，横跨iOS与安卓两大平台。
 使用到的项目:
 <韵典>iOS版，<韵典>Android版。

使用方式类似UITableView/UICollectionView，通过delegate同datasource同宿主功能模块交互，带有单元格回收与重用机制。呈现200行X200列的表格内存占用低，无丝毫卡顿。。可以作为UICollectionView和UITableView的高性能替代产品。

```Objective-C
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
