//
//  VerticalWaterfallViewController.m
//  BHFormViewDemo
//
//  Created by bighiung on 2020/5/25.
//  Copyright © 2020 熊伟. All rights reserved.
//

#import "VerticalWaterfallViewController.h"
#import "PhotoFormViewCell.h"
@interface VerticalWaterfallViewController ()

@end

@implementation VerticalWaterfallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    _imgsUrl = @[@"http://dpic.tiankong.com/81/sx/QJ6950945217.jpg",@"https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3796327428,3996447711&fm=26&gp=0.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1590432574346&di=a39c7179901370af9cccc378ef9be8e6&imgtype=0&src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fitem%2F201804%2F15%2F20180415095021_dwmdc.jpg"
    ];
    
    _imgsMemCache = [[NSCache alloc]init];
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
    [_formView reloadData];
}

-(NSInteger)formView:(BHFormView *)formView numberOfItemsInLine:(NSInteger)row
{
    return 20;
}

-(NSInteger)formViewItemsInLine:(BHFormView *)formView
{
    return 20;
}

-(NSInteger)numberOfLinesInFormView:(BHFormView *)formView
{
    return 2;
}

-(BHFormViewCell *)formView:(BHFormView *)formView cellForRow:(NSInteger)row column:(NSInteger)column
{
    static NSString *reuseId = @"aaa";
    PhotoFormViewCell *cell = (PhotoFormViewCell *)[formView cellForReuseId:reuseId];
    if (cell == nil) {
        cell = [PhotoFormViewCell cellFromXIB];
        cell.reuseIdentifier = reuseId;
    }
    
    NSString *urlString = _imgsUrl[column % 3];
    
    if ([_imgsMemCache objectForKey:urlString]) {
        cell.imageView.image = [_imgsMemCache objectForKey:urlString];
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            //加载图片
            NSURL *url = [NSURL URLWithString:urlString];
            NSData *imgData = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:imgData];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_imgsMemCache setObject:image forKey:urlString];
                    cell.imageView.image = image;
                });
            }
        });
    }
    
    cell.backgroundColor = (row % 2) ? (column %2 ? [UIColor grayColor] : [UIColor greenColor]) : (column %2 ? [UIColor darkGrayColor] : [UIColor blueColor]);
    return cell;
}

-(BHFormViewLayoutMode)formViewLayoutMode:(BHFormView *)formView
{
    return BHColumnFirstMode;
}

-(CGFloat)formView:(BHFormView *)formView sizeForLine:(NSInteger)row
{
   return formView.frame.size.height / 3;
}

-(CGFloat)formView:(BHFormView *)formView widthForColumn:(NSInteger)column
{
    CGFloat width = formView.frame.size.width / 2;
    return width;
}


@end
