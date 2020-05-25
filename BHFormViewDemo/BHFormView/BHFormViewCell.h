//
//  BHFormViewCell.h
//  BHFormViewDemo
//
//  Created by bighiung on 2018/7/22.
//  Copyright © 2018年 熊伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BHFormViewCell : UIView

@property(nonatomic,copy) NSString *reuseIdentifier;

/*
 当前单元格是否处于懒惰模式
 设置进入懒惰模式的单元格，在不调用reloadData方法的情况下，是不会被
 */
@property(nonatomic,assign) BOOL *isInLazyMode;


/*单元格被回收之前调用的方法,一般用于资源释放*/
-(void)cellWillBeRecycled;
@end
