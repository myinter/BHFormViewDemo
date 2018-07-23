//
//  BHFormViewCell.m
//  BHFormViewDemo
//
//  Created by bighiung on 2018/7/22.
//  Copyright © 2018年 熊伟. All rights reserved.
//

#import "BHFormViewCell.h"

@implementation BHFormViewCell
-(void)cellWillBeRecycled{
	
}
-(void)awakeFromNib{
	[super awakeFromNib];
	[self initialize];
}
-(void)initialize{
	_reuseIdentifier = @"";
}

-(BHFormViewCell *)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	self = [self init];
	if (self) {
		_reuseIdentifier = reuseIdentifier;
	}
	return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
