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

/*单元格被回收之前调用的方法,一般用于资源释放*/
-(void)cellWillBeRecycled;
@end
