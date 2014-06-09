//
//  NSIndexPath+GNESectionedTableView.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 5/27/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

#import "NSIndexPath+GNESectionedTableView.h"

@implementation NSIndexPath (GNESectionedTableView)


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
+ (instancetype)gne_indexPathForRow:(NSUInteger)row inSection:(NSUInteger)section
{
    NSUInteger indexes[] = {row, section};
    
    return [NSIndexPath indexPathWithIndexes:indexes length:2];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Convenience Accessors
// ------------------------------------------------------------------------------------------
- (NSUInteger)gne_row
{
    NSAssert1([self length] == 2, @"%@ must have only two indexes", self);
    
    return [self indexAtPosition:0];
}


- (NSUInteger)gne_section
{
    NSAssert1([self length] == 2, @"%@ must have only two indexes", self);
    
    return [self indexAtPosition:1];
}


@end
