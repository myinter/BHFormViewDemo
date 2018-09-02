//
//  ViewController.h
//  BHFormViewDemo
//
//  Created by 熊伟 on 2016/5/16.
//  Copyright © 2016年 熊伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BHFormView.h"
@interface ViewController : UIViewController<BHFormViewDataSource,BHFormViewDelegate>
{
  IBOutlet  BHFormView *mFormView;
    NSInteger count;
}

@end

