//
//  FormViewCell.h
//  BHFormViewDemo
//
//  Created by bighiung on 2018/7/22.
//  Copyright © 2018年 熊伟. All rights reserved.
//

#import "BHFormViewCell.h"

@interface FormViewCell : BHFormViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

+(FormViewCell *)cellFromXIB;
@end
