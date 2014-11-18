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


NSString * const GNEOutlineViewItemPasteboardType = @"com.goneeast.GNEOutlineViewItemPasteboardType";

NSString * const GNEOutlineViewItemParentItemKey = @"GNEOutlineViewItemParentItem";
static NSString * const GNEOutlineViewItemDraggedRowKey = @"GNEOutlineViewItemDraggedRowKey";


// ------------------------------------------------------------------------------------------


@implementation GNEOutlineViewItem


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
- (instancetype)initWithParentItem:(GNEOutlineViewParentItem *)parentItem
{
    if ((self = [super init]))
    {
        _parentItem = parentItem; // Don't use accessor here because it may be nil (GNEOutlineViewParentItem).
        _draggedRow = -1;
    }
    
    return self;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Dealloc
// ------------------------------------------------------------------------------------------
- (void)dealloc
{
    _pasteboardWritingDelegate = nil;
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSCoding
// ------------------------------------------------------------------------------------------
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init]))
    {
        _parentItem = [aDecoder decodeObjectForKey:GNEOutlineViewItemParentItemKey];
        NSNumber *rowNumber = [aDecoder decodeObjectForKey:GNEOutlineViewItemDraggedRowKey];
        _draggedRow = (rowNumber) ? [rowNumber integerValue] : -1;
    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.parentItem forKey:GNEOutlineViewItemParentItemKey];
    id <GNEOutlineViewItemPasteboardWritingDelegate> delegate = self.pasteboardWritingDelegate;
    if ([delegate respondsToSelector:@selector(rowForOutlineViewItem:)])
    {
        NSInteger row = [delegate rowForOutlineViewItem:self];
        [aCoder encodeObject:@(row) forKey:GNEOutlineViewItemDraggedRowKey];
    }
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


+ (NSArray *)readableTypesForPasteboard:(NSPasteboard * __unused)pasteboard
{
    return @[GNEOutlineViewItemPasteboardType];
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSPasteboardWriter
// ------------------------------------------------------------------------------------------
- (NSArray *)writableTypesForPasteboard:(NSPasteboard * __unused)pasteboard
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
    return [NSString
            stringWithFormat:@"<%@: %p> Parent: %@", [self className], self, self.parentItem];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Equality
// ------------------------------------------------------------------------------------------
- (BOOL)isEqual:(id)object
{
    return (self == object);
}


- (NSUInteger)hash
{
    return (NSUInteger)self;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Accessors
// ------------------------------------------------------------------------------------------
- (void)setParentItem:(GNEOutlineViewParentItem *)parentItem
{
    NSParameterAssert(parentItem);
    
    if (_parentItem != parentItem)
    {
        _parentItem = parentItem;
    }
}


@end
