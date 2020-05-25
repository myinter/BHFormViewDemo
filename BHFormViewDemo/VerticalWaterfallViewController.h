//
//  VerticalWaterfallViewController.h
//  BHFormViewDemo
//
//  Created by bighiung on 2020/5/25.
//  Copyright © 2020 熊伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BHFormView.h"

NS_ASSUME_NONNULL_BEGIN

@interface VerticalWaterfallViewController : UIViewController<BHFormViewDataSource,BHFormViewDelegate>
{
    __weak IBOutlet BHFormView *_formView;
    
    NSArray *_imgsUrl;
    
    NSCache *_imgsMemCache;
}
@end

NS_ASSUME_NONNULL_END
