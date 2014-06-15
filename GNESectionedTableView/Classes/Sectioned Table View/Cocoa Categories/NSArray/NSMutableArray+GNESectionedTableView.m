//
//  NSMutableArray+GNESectionedTableView.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 6/15/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

#import "NSMutableArray+GNESectionedTableView.h"

@implementation NSMutableArray (GNESectionedTableView)


- (NSUInteger)gne_insertObject:(id)anObject atIndex:(NSUInteger)index
{
    NSUInteger count = [self count];
    if (index < count)
    {
        [self insertObject:anObject atIndex:index];
        
        return index;
    }
    
    [self addObject:anObject];
        
    return count;
}


@end
