//
//  PhotoFormViewCell.h
//  BHFormViewDemo
//
//  Created by bighiung on 2020/5/25.
//  Copyright © 2020 熊伟. All rights reserved.
//

#import "FormViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotoFormViewCell : FormViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;


+(PhotoFormViewCell *)cellFromXIB;
@end

NS_ASSUME_NONNULL_END
