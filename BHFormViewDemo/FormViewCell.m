//
//  FormViewCell.m
//  BHFormViewDemo
//
//  Created by bighiung on 2018/7/22.
//  Copyright © 2018年 熊伟. All rights reserved.
//

#import "FormViewCell.h"

@implementation FormViewCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+(FormViewCell *)cellFromXIB{
	return [[NSBundle mainBundle]loadNibNamed:@"FormViewCell" owner:nil options:nil][0];
}

@end
