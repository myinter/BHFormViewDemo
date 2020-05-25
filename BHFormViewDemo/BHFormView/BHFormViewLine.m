//
//  BHFormViewRow.m
//  BHFormViewDemo
//
//  Created by bighiung on 2018/7/21.
//  Copyright © 2018年 熊伟. All rights reserved.
//

#import "BHFormViewLine.h"

@implementation BHFormViewLine

-(void)dealloc{
	if (_rectsForCells) {
		free(_rectsForCells);
	}
	if (_itemsVisibilities) {
		free(_itemsVisibilities);
	}
}

-(void)setItemCount:(NSInteger)columnCount{
	if (columnCount > _rectsArraySize) {
		_rectsArraySize = columnCount + 10;
		if (_rectsForCells) {
			free(_rectsForCells);
		}
		if (_itemsVisibilities) {
			free(_itemsVisibilities);
		}
		if (_currentCells) {
			[_currentCells removeAllObjects];
		}
		else{
			_currentCells = [NSMutableArray arrayWithCapacity:_rectsArraySize];
		}
		_rectsForCells = (CGRect *)malloc(sizeof(CGRect) * _rectsArraySize);
		_itemsVisibilities = (BOOL *)malloc(sizeof(BOOL) * _rectsArraySize);
		memset(_itemsVisibilities, 0, _rectsArraySize);
		for (int i = 0; i != _rectsArraySize; i++) {
			[_currentCells addObject:[NSNull null]];
		}
	}
	_maxVisibleItem = columnCount;
	_minVisibleItem = 0;
	_itemCount = columnCount;
}
@end
