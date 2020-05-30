//
//  ViewController2.m
//  BHFormViewDemo
//
//  Created by 熊伟 on 2016/5/16.
//  Copyright © 2016年 熊伟. All rights reserved.
//

#import "ViewController2.h"
#import "FormViewCell.h"

@interface ViewController2 ()

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    mFromView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [mFromView reloadData];
}


-(NSInteger)formView:(BHFormView *)formView numberOfItemsInLine:(NSInteger)row
{
    switch (row) {
        case 0:
            return 4;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 4;
            break;
        case 3:
        case 4:
            return 3;
            break;
        default:
            break;
    }
    return 0;
}

-(NSInteger)numberOfLinesInFormView:(BHFormView *)formView
{
    return 5;
}

-(BHFormViewCell *)formView:(BHFormView *)formView cellForLine:(NSInteger)row item:(NSInteger)column
{
	static NSString *reuseId = @"aaa";
	FormViewCell *cell = [formView cellForReuseId:reuseId];
	if (cell == nil) {
		cell = [FormViewCell cellFromXIB];
		cell.reuseIdentifier = reuseId;
	}
	cell.titleLabel.text = [NSString stringWithFormat:@"%d %d",row,column];
	cell.titleLabel.backgroundColor = (row % 2) ? (column %2 ? [UIColor grayColor] : [UIColor greenColor]) : (column %2 ? [UIColor darkGrayColor] : [UIColor blueColor]);
	
	return cell;
}



-(CGFloat)formView:(BHFormView *)formView sizeForItem:(NSInteger)column atLine:(NSInteger)row
{
    if (column == 0) {
        switch (row) {
            case 0:
                return (formView.frame.size.height / 5) * 2;
            case 2:
            {
                return (formView.frame.size.height / 5) * 3;

            }
                break;
            default:
                return formView.frame.size.height / 5;
                break;
        }
    }
    return formView.frame.size.height / 5;
}


//返回每一行的基准高度（即改行单元格高度值的最典型值）
-(CGFloat)formView:(BHFormView *)formView sizeForLine:(NSInteger)row
{
    return formView.frame.size.height / 5;
}

-(CGFloat)formView:(BHFormView *)formView widthForItem:(NSInteger)column atLine:(NSInteger)row
{
    CGFloat width = 0.0f;
    if (column == 0 && (row == 0 || row == 2)) {
        width = formView.frame.size.width / 7.0f;
    }
    else
    {
        width = (formView.frame.size.width / 7.0f) * 2;
    }
    return width;
}


-(UIColor *)formView:(BHFormView *)formView backgroundColorOfColumn:(NSInteger)column inRow:(NSInteger)row
{
    CGFloat R = column * 25;
    CGFloat G = row * 20;
    CGFloat B = (column * row * 10) % 255;
    return [UIColor colorWithRed:R/255.0f green:G/255.0F blue:B/255.0f alpha:(20 * (row+1)) / 255.0f];
}

@end
