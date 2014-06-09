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
- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert(indexPath.gne_row == NSNotFound);
    
    if (self = [super initWithIndexPath:indexPath parentItem:nil])
    {
        
    }
    
    return self;
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
- (void)setIndexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert(indexPath.gne_row == NSNotFound);
    
    [super setIndexPath:indexPath];
}


- (void)setParentItem:(GNEOutlineViewParentItem * __unused)parentItem
{
    NSAssert(NO, @"Outline view parent items cannot themselves have parent items.");
}


@end
