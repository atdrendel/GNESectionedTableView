//
//  NSIndexPath+GNESectionedTableView.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 5/27/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 Gone East LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "NSIndexPath+GNESectionedTableView.h"

@implementation NSIndexPath (GNESectionedTableView)


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
+ (nonnull instancetype)gne_indexPathForRow:(NSUInteger)row inSection:(NSUInteger)section
{
    NSUInteger indexes[] = {row, section};
    
    return [NSIndexPath indexPathWithIndexes:indexes length:2];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Collection helpers
// ------------------------------------------------------------------------------------------
+ (NSArray * __nonnull)gne_indexPathsForIndexes:(NSIndexSet * __nonnull)indexSet inSection:(NSUInteger)section
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
- (NSComparisonResult)gne_compare:(NSIndexPath * __nonnull)indexPath
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


- (NSComparisonResult)gne_reverseCompare:(NSIndexPath * __nonnull)indexPath
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
