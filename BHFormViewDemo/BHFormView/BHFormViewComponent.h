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
extern inline BOOL valueBetween(CGFloat value,CGFloat begin,CGFloat end);
extern inline BOOL isVisibleRect(CGRect rect,CGFloat beginX,CGFloat beginY,CGFloat endX,CGFloat endY);
extern inline CGRect CheckCollisionWithRectsInFormerRows(CGRect *veryHighCellsRects,NSInteger veryHighCellsCount,CGRect objRect);
#endif /* BHFormViewComponent_h */
