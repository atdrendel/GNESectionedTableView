//
//  GNETableRowView.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 11/7/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

#import "GNETableRowView.h"

@implementation GNETableRowView


- (id)viewAtColumn:(NSInteger)column
{
    NSInteger columnCount = self.numberOfColumns;
    
    if (column < columnCount)
    {
        return [super viewAtColumn:column];
    }
    else if (columnCount > 0)
    {
        return [super viewAtColumn:0];
    }
    
    return nil;
}

@end
