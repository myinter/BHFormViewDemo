//
//  BHFormViewRow.m
//  BHFormViewDemo
//
//  Created by bighiung on 2018/7/21.
//  Copyright © 2018年 熊伟. All rights reserved.
//

#import "BHFormViewRow.h"

@implementation BHFormViewRow

-(void)dealloc{
	if (_rectsForCells) {
		free(_rectsForCells);
	}
	if (_columnsVisible) {
		free(_columnsVisible);
	}
}

-(void)setColumnCount:(NSInteger)columnCount{
	if (columnCount > _rectsArraySize) {
		_rectsArraySize = columnCount + 10;
		if (_rectsForCells) {
			free(_rectsForCells);
		}
		if (_columnsVisible) {
			free(_columnsVisible);
		}
		if (_currentCells) {
			[_currentCells removeAllObjects];
		}
		else{
			_currentCells = [NSMutableArray arrayWithCapacity:_rectsArraySize];
		}
		_rectsForCells = (CGRect *)malloc(sizeof(CGRect) * _rectsArraySize);
		_columnsVisible = (BOOL *)malloc(sizeof(BOOL) * _rectsArraySize);
		memset(_columnsVisible, 0, _rectsArraySize);
		for (int i = 0; i != _rectsArraySize; i++) {
			[_currentCells addObject:[NSNull null]];
		}
	}
	_columnCount = columnCount;
}
@end
