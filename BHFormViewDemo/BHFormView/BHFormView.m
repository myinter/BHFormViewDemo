//
//  BHFormView.m
//  BHFormViewDemo
//
//  Created by 熊伟 on 2016/5/16.
//  Copyright © 2016年 熊伟. All rights reserved.
//

#import "BHFormView.h"
#import "UIImage+FuntionExtention.h"


//单元格重用容器
static NSMutableSet *reuseCells = nil;

@implementation BHFormView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    //重新载入数据
    if (_dataSource) {
        [self reloadData];
    }
}

static UIImage *defaultBackImg = nil;
static UIImage *defaultBackImg2 = nil;
static UIImage *defaultBackImg3 = nil;

-(void)reloadData
{
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    if (reuseCells == nil) {
        reuseCells = [NSMutableSet new];
    }
    [reuseCells addObjectsFromArray:currentCellBtns];
    [currentCellBtns removeAllObjects];
    if (currentCellBtns == nil) {
        currentCellBtns = [NSMutableArray new];
    }
    
    
    NSInteger rowCount = [self.dataSource numberOfRowsInFormView:self];
    NSInteger columnCount = 0;
    
    if ([_dataSource respondsToSelector:@selector(formViewColumnsInRow:)]) {
        columnCount = [self.dataSource formViewColumnsInRow:self];
    }
    
    NSMutableArray *columnCounts = [NSMutableArray new];
    
    if ([_dataSource respondsToSelector:@selector(formView:numberOfColumnsInRow:)]) {
        for (NSInteger rowCounter = 0; rowCounter < rowCount; rowCounter++) {
            [columnCounts addObject:[NSNumber numberWithUnsignedInteger:[_dataSource formView:self numberOfColumnsInRow:rowCounter]]];
        }
    }
    
    CGFloat y = 0.f;
    CGFloat maxWidth = 0.f;
    CGFloat maxHeight = 0.f;
    UIColor *borderColor = nil;
    UIImage *backImage = nil;
    UIColor *titleColor = nil;
    UIFont *font = nil;
    
    for (NSInteger i = 0; i < rowCount; i++) {
        CGFloat height = 20;
        if ([self.dataSource respondsToSelector:@selector(formView:heightForRow:)]) {
            height = [self.dataSource formView:self heightForRow:i];
        }
        CGFloat x = 0.f;
        
        
        //若列数可变，则获取变动的列数。。。
        if (columnCounts.count) {
            columnCount = [columnCounts[i]integerValue];
        }
        
        for (NSInteger j = 0; j < columnCount; j++) {
            
            
            CGFloat width;
            
            
            if ([_dataSource respondsToSelector:@selector(formView:widthForColumn:atRow:)]) {
                //若宽度可变动，则调用可变宽度方法
                width = [self.dataSource formView:self widthForColumn:j atRow:i];
            }
            else
            {
                width = [self.dataSource formView:self widthForColumn:j];
            }
            
            CGFloat columnHeight;
            
            if ([_dataSource respondsToSelector:@selector(formView:heightForColumn:atRow:)]) {
                columnHeight = [_dataSource formView:self heightForColumn:j atRow:i];
            }
            else
            {
                columnHeight = height;
            }
            
            
            UIButton *btn = [reuseCells anyObject];
            
            if (btn) {
                [reuseCells removeObject:btn];
            }
            
            if (btn == nil) {
                btn = [[UIButton alloc]init];
                btn.titleLabel.adjustsFontSizeToFitWidth = YES;
            }
            
            btn.frame = CGRectMake(x,y,width,columnHeight);
            
            for (UIView *view in currentCellBtns) {
                //若x轴坐标有先前行的cell 延伸过来，则x轴坐标自动顺延
                if (CGRectIntersectsRect(view.frame, btn.frame)) {
                    //有其他视图被延伸至本行
                    //并且正好占用了本行预期的开始位置
                    //则自动向右顺延
                    btn.frame = CGRectMake(view.frame.size.width + view.frame.origin.x, btn.frame.origin.y, btn.frame.size.width, btn.frame.size.height);
                }
            }
            
            [currentCellBtns addObject:btn];
            
            
            if (defaultBackImg == nil) {
                defaultBackImg = [UIImage imageFromColor:[self colorWithHexString:@"dce6f3"]];
                defaultBackImg2 = [UIImage imageFromColor:[self colorWithHexString:@"f7fbff"]];
                defaultBackImg3 = [UIImage imageFromColor:[self colorWithHexString:@"f0f7fe"]];
            }
            
            
            if ([self.dataSource respondsToSelector:@selector(formView:backgroundColorOfColumn:inRow:)]) {
                UIColor *bgColor = [self.dataSource formView:self backgroundColorOfColumn:j inRow:i];
                if (bgColor == nil) {
                    if (i == 0) {
                        backImage = defaultBackImg;
                    }else if (i % 2) {
                        backImage = defaultBackImg2;
                    }else{
                        backImage = defaultBackImg3;
                    }
                }else{
                    backImage = [UIImage imageFromColor:bgColor];
                }
            }else{
                if (i == 0) {
                    backImage = defaultBackImg;
                }else if (i % 2) {
                    backImage = defaultBackImg2;
                }else{
                    backImage = defaultBackImg3;
                }
            }
            [btn setBackgroundImage:backImage forState:UIControlStateNormal];
            
            if ([self.dataSource respondsToSelector:@selector(formViewBorderColor:)]) {
                borderColor = [self.dataSource formViewBorderColor:self];
            }else{
                borderColor = [UIColor colorWithWhite:0.9 alpha:1.000];
            }
            [btn.layer setBorderColor:borderColor.CGColor];
            
            BOOL action = NO;
            if ([self.dataSource respondsToSelector:@selector(formView:addActionForColumn:inRow:)]) {
                action = [self.dataSource formView:self addActionForColumn:j inRow:i];
            }
            
            if ([self.dataSource respondsToSelector:@selector(formView:textColorOfColumn:inRow:)]) {
                titleColor = [self.dataSource formView:self textColorOfColumn:j inRow:i];
            }
            if (titleColor == nil)
            {
                if (action) {
                    titleColor = [self colorWithHexString:@"3e98b5"];
                }else{
                    titleColor = [UIColor colorWithRed:75/255.f green:55/255.f blue:39/255.f alpha:1.0];
                }
            }
            [btn setTitleColor:titleColor forState:UIControlStateNormal];
            [btn setTitleColor:[titleColor colorWithAlphaComponent:0.4f] forState:UIControlStateHighlighted];
            
            [btn setTitle:[self.dataSource formView:self textForColumn:j inRow:i] forState:UIControlStateNormal];
            
            if ([self.dataSource respondsToSelector:@selector(formViewFontOfContent:)]) {
                font = [self.dataSource formViewFontOfContent:self];
            }else{
                font = [UIFont systemFontOfSize:12];
            }
            [btn.titleLabel setFont:font];
//            CGFloat textWidth = [btn.currentTitle boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size.width;
//            if (self.mode == BHFormViewModeLeft) {
//                btn.titleEdgeInsets = UIEdgeInsetsMake(0, margin, 0, width - margin - textWidth);
//            }else if (self.mode == BHFormViewModeRight) {
//                btn.titleEdgeInsets = UIEdgeInsetsMake(0, width - margin - textWidth, 0, margin);
//            }
            
            [btn.layer setBorderWidth:0.5];
            btn.tag = 10000 + i * 100 + j;
            [self addSubview:btn];
            
            if (action) {
                [btn addTarget:self action:@selector(itemClicked:) forControlEvents:UIControlEventTouchUpInside];
            }else{
                btn.userInteractionEnabled = NO;
            }
            x += width;
            if (btn.frame.origin.x + width > maxWidth) {
                maxWidth = btn.frame.origin.x + width;
            }
            
            if (btn.frame.origin.y + columnHeight > maxHeight) {
                maxHeight = btn.frame.origin.y + columnHeight;
            }
        }
        y += height;
    }
    self.frame = (CGRect){self.frame.origin , CGSizeMake(maxWidth, maxHeight)};
    self.layer.borderColor = borderColor.CGColor;
    self.layer.borderWidth = 1.f;
}

- (void)itemClicked:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(formView:didTapColumn:inRow:)]) {
        NSInteger row = (sender.tag - 10000) / 100;
        NSInteger col = (sender.tag - 10000) - row * 100;
        [_delegate formView:self didTapColumn:col inRow:row];
    }
}


- (UIColor *)colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}


@end
