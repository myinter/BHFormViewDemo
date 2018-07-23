//
//  BHFormViewComponent.c
//  BHFormViewDemo
//
//  Created by bighiung on 2018/7/22.
//  Copyright © 2018年 熊伟. All rights reserved.
//

#include "BHFormViewComponent.h"
inline BOOL valueBetween(CGFloat value,CGFloat begin,CGFloat end){
	return value >= begin && value <= end;
}

inline BOOL isVisibleRect(CGRect rect,CGFloat beginX,CGFloat beginY,CGFloat endX,CGFloat endY){
	CGFloat maxY = CGRectGetMaxY(rect),maxX = CGRectGetMaxX(rect);
//	return !((rect.origin.x > endX || maxX < beginX) || (rect.origin.y > endY || maxY < beginY));
//	printf("\n beginX =%f beginY = %f endX = %f endY = %f",beginX,beginY,endX,endY);
//	if (rect.origin.x > maxX) {
//		return NO;
//	}
//
//	if (rect.origin.y > maxY) {
//		return NO;
//	}
//
//	if (maxX < beginX) {
//		return NO;
//	}
//
//	if (maxY < beginY) {
//		return NO;
//	}
	return ((rect.origin.x >= beginX && rect.origin.x <= endX) && (rect.origin.y >= beginY && rect.origin.y <= endY))
	|| ((rect.origin.x >= beginX && rect.origin.x <= endX) && (maxY >= beginY && maxY <= endY))
	|| ((maxX >= beginX && maxX <= endX) && (maxY >= beginY && maxY <= endY))
	|| ((maxX >= beginX && maxX <= endX) && (rect.origin.y >= beginY && rect.origin.y <= endY));
}

inline CGRect CheckCollisionWithRectsInFormerRows(NSArray<BHFormViewRow *> *rows,CGRect objRect){
	for (BHFormViewRow *row in rows) {
		if (!row.hasVeryHighCell) {
			continue;
		}
		CGRect *rects = row.rectsForCells;
		for (int i = 0; i != row.columnCount; i++) {
			CGRect rect = rects[i];
			if (CGRectIntersectsRect(rect, objRect)) {
				objRect = CGRectMake(rect.origin.x + rect.size.width, objRect.origin.y, objRect.size.width, objRect.size.height);
			}
		}
	}
	return objRect;
}
