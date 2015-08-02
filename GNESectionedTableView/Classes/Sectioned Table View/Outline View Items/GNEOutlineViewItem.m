//
//  GNEOutlineViewItem.m
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

#import "GNEOutlineViewItem.h"
#import "GNEOutlineViewParentItem.h"
#import "NSIndexPath+GNESectionedTableView.h"


// ------------------------------------------------------------------------------------------


NSString * const GNEOutlineViewItemPasteboardType = @"com.goneeast.GNEOutlineViewItemPasteboardType";

NSString * const GNEOutlineViewItemParentItemKey = @"GNEOutlineViewItemParentItem";
static NSString * const GNEOutlineViewItemDraggedIndexPathKey = @"GNEOutlineViewItemDraggedIndexPathKey";


// ------------------------------------------------------------------------------------------


@implementation GNEOutlineViewItem


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
- (instancetype)initWithParentItem:(GNEOutlineViewParentItem *)parentItem
{
    if ((self = [super init]))
    {
        _parentItem = parentItem;
        _draggedIndexPath = nil;
    }
    
    return self;
}


- (instancetype)init
{
    return [self initWithParentItem:nil];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Dealloc
// ------------------------------------------------------------------------------------------
- (void)dealloc
{
    _pasteboardWritingDelegate = nil;
    _draggedIndexPath = nil;
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSSecureCoding
// ------------------------------------------------------------------------------------------
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init]))
    {
        _parentItem = [aDecoder decodeObjectOfClass:[GNEOutlineViewParentItem class]
                                             forKey:GNEOutlineViewItemParentItemKey];
        _draggedIndexPath = [aDecoder decodeObjectOfClass:[NSIndexPath class]
                                                   forKey:GNEOutlineViewItemDraggedIndexPathKey];
    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.parentItem forKey:GNEOutlineViewItemParentItemKey];
    id <GNEOutlineViewItemPasteboardWritingDelegate> delegate = self.pasteboardWritingDelegate;
    if ([delegate respondsToSelector:@selector(draggedIndexPathForOutlineViewItem:)])
    {
        NSIndexPath *indexPath = [delegate draggedIndexPathForOutlineViewItem:self];
        [aCoder encodeObject:indexPath forKey:GNEOutlineViewItemDraggedIndexPathKey];
    }
}


+ (BOOL)supportsSecureCoding
{
    return YES;
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSPasteboardReader
// ------------------------------------------------------------------------------------------
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)type
{
    if ([type isEqualToString:GNEOutlineViewItemPasteboardType])
    {
        return [NSKeyedUnarchiver unarchiveObjectWithData:propertyList];
    }
    
    return nil;
}
#pragma clang diagnostic pop


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
    NSString *indexPathString = @"";
    id <GNEOutlineViewItemPasteboardWritingDelegate> theDelegate = self.pasteboardWritingDelegate;
    SEL selector = NSSelectorFromString(@"draggedIndexPathForOutlineViewItem:");
    if ([theDelegate respondsToSelector:selector])
    {
        NSIndexPath *indexPath = [theDelegate draggedIndexPathForOutlineViewItem:self];
        unsigned long section = indexPath.gne_section;
        unsigned long row = indexPath.gne_row;
        indexPathString = [NSString stringWithFormat:@" Index Path: {%lu, %lu}", section, row];
    }
    
    return [NSString stringWithFormat:@"<%@: %p>%@ Parent: %@",
            [self className], self, indexPathString, self.parentItem];
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


@end
