//
//  GNEOutlineViewParentItem.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 5/27/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

#import "GNEOutlineViewParentItem.h"


// ------------------------------------------------------------------------------------------


static NSString * const kOutlineViewParentItemVisibleKey = @"visible";


// ------------------------------------------------------------------------------------------


@implementation GNEOutlineViewParentItem


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
- (instancetype)init
{
    if (self = [super initWithParentItem:nil])
    {
        
    }
    
    return self;
}


- (instancetype)initWithParentItem:(GNEOutlineViewParentItem * __unused)parentItem
{
    NSAssert1(parentItem == nil, @"Instances of GNEOutlineViewParentItem can not have parents: %@", parentItem);
    
    return [self init];
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSCoding
// ------------------------------------------------------------------------------------------
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        _visible = [aDecoder decodeBoolForKey:kOutlineViewParentItemVisibleKey];
    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeBool:self.visible forKey:kOutlineViewParentItemVisibleKey];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Accessors
// ------------------------------------------------------------------------------------------
- (void)setParentItem:(GNEOutlineViewParentItem * __unused)parentItem
{
    NSAssert(NO, @"Outline view parent items cannot themselves have parent items.");
}


@end
