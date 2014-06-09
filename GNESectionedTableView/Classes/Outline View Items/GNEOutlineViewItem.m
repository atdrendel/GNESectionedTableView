//
//  GNEOutlineViewItem.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 5/27/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

#import "GNEOutlineViewItem.h"
#import "GNEOutlineViewParentItem.h"


// ------------------------------------------------------------------------------------------


NSString * const GNEOutlineViewItemPasteboardType = @"GNEOutlineViewItemPasteboardType";

NSString * const GNEOutlineViewItemIndexPathKey = @"GNEOutlineViewItemIndexPath";
NSString * const GNEOutlineViewItemParentItemKey = @"GNEOutlineViewItemParentItem";


// ------------------------------------------------------------------------------------------


@implementation GNEOutlineViewItem


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath parentItem:(GNEOutlineViewParentItem *)parentItem
{
    if ((self = [super init]))
    {
        _indexPath = indexPath;
        _parentItem = parentItem; // Don't use accessor here because it may be nil (GNEOutlineViewParentItem).
    }
    
    return self;
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSCoding
// ------------------------------------------------------------------------------------------
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init]))
    {
        _indexPath = [aDecoder decodeObjectForKey:GNEOutlineViewItemIndexPathKey];
        _parentItem = [aDecoder decodeObjectForKey:GNEOutlineViewItemParentItemKey];
    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.indexPath forKey:GNEOutlineViewItemIndexPathKey];
    [aCoder encodeObject:self.parentItem forKey:GNEOutlineViewItemParentItemKey];
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSPasteboardReader
// ------------------------------------------------------------------------------------------
- (instancetype)initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)type
{
    if ([type isEqualToString:GNEOutlineViewItemPasteboardType])
    {
        return [NSKeyedUnarchiver unarchiveObjectWithData:propertyList];
    }
    
    return nil;
}


+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return @[GNEOutlineViewItemPasteboardType];
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSPasteboardWriter
// ------------------------------------------------------------------------------------------
- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return @[GNEOutlineViewItemPasteboardType];
}


- (id)pasteboardPropertyListForType:(NSString *)type
{
    if ([type isEqualToString:GNEOutlineViewItemPasteboardType])
    {
        NSData *plistData = [NSKeyedArchiver archivedDataWithRootObject:self];
        
        return plistData;
    }
    
    return nil;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Description
// ------------------------------------------------------------------------------------------
- (NSString *)description
{
    NSInteger row = (self.indexPath) ? self.indexPath.gne_row : -1;
    NSInteger section = (self.indexPath) ? self.indexPath.gne_section : -1;
    
    return [NSString
            stringWithFormat:@"<%@: %p, row:%ld section:%ld>", [self className], self, (long)row, (long)section];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Accessors
// ------------------------------------------------------------------------------------------
- (void)setIndexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert(indexPath != nil);
    
    if (_indexPath != indexPath)
    {
        _indexPath = indexPath;
    }
}


- (void)setParentItem:(GNEOutlineViewParentItem *)parentItem
{
    NSParameterAssert(parentItem != nil);
    
    if (_parentItem != parentItem)
    {
        _parentItem = parentItem;
    }
}


@end
