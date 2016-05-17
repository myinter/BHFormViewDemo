//
//  ViewController.m
//  BHFormViewDemo
//
//  Created by 熊伟 on 2016/5/16.
//  Copyright © 2016年 熊伟. All rights reserved.
//

#import "ViewController.h"
#import "ViewController2.h"


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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [mFormView reloadData];
}


-(NSInteger)formViewColumnsInRow:(BHFormView *)formView
{
    return 5;
}

-(NSInteger)numberOfRowsInFormView:(BHFormView *)formView
{
    return 3;
}

-(NSString *)formView:(BHFormView *)formView textForColumn:(NSInteger)column inRow:(NSInteger)row
{
    return [NSString stringWithFormat:@"%ld行%ld列",(long)row,(long)column];
}

-(CGFloat)formView:(BHFormView *)formView heightForRow:(NSInteger)row
{
   return formView.frame.size.height / 3;
}


-(CGFloat)formView:(BHFormView *)formView widthForColumn:(NSInteger)column
{
    CGFloat width = 0.0f;
    switch (column) {
        case 0:
        {
           width = formView.frame.size.width / 5;
        }
            break;
        case 1:
        {
            width = (formView.frame.size.width / 5) * 2;
        }
            break;
        case 2:{
            width = (formView.frame.size.width / 5) * 2;
        }
        default:
            break;
    }
    
    return width;
}


- (IBAction)next:(id)sender {
    [self.navigationController pushViewController:[ViewController2 new] animated:YES];
}


@end
