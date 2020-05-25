//
//  PhotoFormViewCell.m
//  BHFormViewDemo
//
//  Created by bighiung on 2020/5/25.
//  Copyright © 2020 熊伟. All rights reserved.
//

#import "PhotoFormViewCell.h"

@implementation PhotoFormViewCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+(PhotoFormViewCell *)cellFromXIB{
    return [[NSBundle mainBundle]loadNibNamed:@"PhotoFormViewCell" owner:nil options:nil][0];
}

@end
