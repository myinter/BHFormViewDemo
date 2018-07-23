//
//  BHFormViewComponent.h
//  BHFormViewDemo
//
//  Created by bighiung on 2018/7/22.
//  Copyright © 2018年 熊伟. All rights reserved.
//

#ifndef BHFormViewComponent_h
#define BHFormViewComponent_h

#include <stdio.h>
#include "BHFormViewRow.h"
#include <CoreGraphics/CoreGraphics.h>
BOOL valueBetween(CGFloat value,CGFloat begin,CGFloat end);
BOOL isVisibleRect(CGRect rect,CGFloat beginX,CGFloat beginY,CGFloat endX,CGFloat endY);
CGRect CheckCollisionWithRectsInFormerRows(NSArray<BHFormViewRow *> *rows,CGRect objRect);
#endif /* BHFormViewComponent_h */
