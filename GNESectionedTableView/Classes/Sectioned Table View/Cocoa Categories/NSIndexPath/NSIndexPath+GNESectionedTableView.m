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
#pragma mark - Collection helpers
// ------------------------------------------------------------------------------------------
+ (NSArray *)gne_indexPathsForIndexes:(NSIndexSet *)indexSet inSection:(NSUInteger)section
{
    NSMutableArray *mutableIndexPaths = [NSMutableArray array];
    
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop __unused)
    {
        NSIndexPath *indexPath = [NSIndexPath gne_indexPathForRow:idx inSection:section];
        [mutableIndexPaths addObject:indexPath];
    }];
    
    return [NSArray arrayWithArray:mutableIndexPaths];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Comparison
// ------------------------------------------------------------------------------------------
- (NSComparisonResult)gne_compare:(NSIndexPath *)indexPath
{
    NSParameterAssert([indexPath respondsToSelector:@selector(gne_row)] &&
                      [indexPath respondsToSelector:@selector(gne_section)]);
    NSParameterAssert(self.length == 2);
    NSParameterAssert(indexPath.length == 2);
    
    if (self.gne_section == indexPath.gne_section)
    {
        if (self.gne_row == indexPath.gne_row)
        {
            return NSOrderedSame;
        }
        else if (self.gne_row < indexPath.gne_row)
        {
            return NSOrderedAscending;
        }
        else
        {
            return NSOrderedDescending;
        }
    }
    else if (self.gne_section < indexPath.gne_section)
    {
        return NSOrderedAscending;
    }

    return NSOrderedDescending;
}


- (NSComparisonResult)gne_reverseCompare:(NSIndexPath *)indexPath
{
    NSParameterAssert([indexPath respondsToSelector:@selector(gne_row)] &&
                      [indexPath respondsToSelector:@selector(gne_section)]);
    NSParameterAssert(self.length == 2);
    NSParameterAssert(indexPath.length == 2);
    
    if (self.gne_section == indexPath.gne_section)
    {
        if (self.gne_row == indexPath.gne_row)
        {
            return NSOrderedSame;
        }
        else if (self.gne_row < indexPath.gne_row)
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedAscending;
        }
    }
    else if (self.gne_section < indexPath.gne_section)
    {
        return NSOrderedDescending;
    }
    
    return NSOrderedAscending;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Convenience Accessors
// ------------------------------------------------------------------------------------------
- (NSUInteger)gne_row
{
    NSAssert1(self.length == 2, @"%@ must have only two indexes", self);
    
    return [self indexAtPosition:0];
}


- (NSUInteger)gne_section
{
    NSAssert1(self.length == 2, @"%@ must have only two indexes", self);
    
    return [self indexAtPosition:1];
}


@end
