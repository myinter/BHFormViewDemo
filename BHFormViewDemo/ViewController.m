//
//  ViewController.m
//  BHFormViewDemo
//
//  Created by 熊伟 on 2016/5/16.
//  Copyright © 2016年 熊伟. All rights reserved.
//

#import "ViewController.h"
#import "ViewController2.h"
#import "FormViewCell.h"
#import "VerticalWaterfallViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if ([[UIDevice currentDevice].systemVersion floatValue]>=7.0)
    {
        self.edgesForExtendedLayout = UIRectEdgeBottom;
    }
    else
    {
        self.wantsFullScreenLayout = NO;
    }

    mFormView.dataSource = self;
    mFormView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)gotoVerticalWaterfall:(id)sender {
    
    [self.navigationController pushViewController:[VerticalWaterfallViewController new] animated:YES];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [mFormView reloadData];
}

-(NSInteger)formView:(BHFormView *)formView numberOfItemsInLine:(NSInteger)row
{
    return 200;
}

-(NSInteger)formViewItemsInLine:(BHFormView *)formView
{
    return 20;
}

-(NSInteger)numberOfLinesInFormView:(BHFormView *)formView
{
    return 200;
}

-(BHFormViewCell *)formView:(BHFormView *)formView cellForRow:(NSInteger)row column:(NSInteger)column
{
	static NSString *reuseId = @"aaa";
	FormViewCell *cell = (FormViewCell *)[formView cellForReuseId:reuseId];
	if (cell == nil) {
		cell = [FormViewCell cellFromXIB];
		cell.reuseIdentifier = reuseId;
	}
	cell.titleLabel.text = [NSString stringWithFormat:@"%d %d",row + count,column];
	cell.titleLabel.backgroundColor = (row % 2) ? (column %2 ? [UIColor grayColor] : [UIColor greenColor]) : (column %2 ? [UIColor darkGrayColor] : [UIColor blueColor]);
	return cell;
}

-(CGFloat)formView:(BHFormView *)formView sizeForLine:(NSInteger)row
{
   return formView.frame.size.height / 3;
}

-(CGFloat)formView:(BHFormView *)formView widthForColumn:(NSInteger)column
{
    CGFloat width = formView.frame.size.width / 6;
    switch (column) {
        case 0:
        {
           width = formView.frame.size.width / 6;
        }
            break;
        case 1:
        {
            width = (formView.frame.size.width / 6) * 2;
        }
            break;
        case 2:{
            width = (formView.frame.size.width / 6) * 2;
        }
        default:
            break;
    }
    
    return width;
}

- (IBAction)next:(id)sender {
//    [self.navigationController pushViewController:[ViewController2 new] animated:YES];
    count++;
    [mFormView reloadDataWithoutNewItemsAndLayoutInfos];
}


@end
