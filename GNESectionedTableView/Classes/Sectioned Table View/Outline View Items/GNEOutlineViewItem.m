//
//  GNEOutlineViewItem.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 8/9/15.
//  Copyright © 2015 Gone East LLC. All rights reserved.
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
#import "GNESectionedTableView.h"


// ------------------------------------------------------------------------------------------


NSString * const GNEOutlineViewRowItemPasteboardType = @"com.goneeast.GNEOutlineViewItemPasteboardType";

static NSString * const kIsSelectedKey = @"GNEOutlineViewRowItemIsSelected";


// ------------------------------------------------------------------------------------------


@implementation GNEOutlineViewItem


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)init
{
    NSAssert3(NO, @"Instances of %@ should not be initialized with %@. Use %@ instead.",
              NSStringFromClass([self class]), NSStringFromSelector(_cmd),
              NSStringFromSelector(@selector(initWithTableView:dataSource:delegate:)));
    return nil;
}
#pragma clang diagnostic pop


- (instancetype)initWithTableView:(GNESectionedTableView *)tableView
                       dataSource:(id<GNESectionedTableViewDataSource>)dataSource
                         delegate:(id<GNESectionedTableViewDelegate>)delegate
{
    if ((self = [super init]))
    {
        _tableView = tableView;
        _tableViewDataSource = dataSource;
        _tableViewDelegate = delegate;
    }

    return self;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Dealloc
// ------------------------------------------------------------------------------------------
- (void)dealloc
{
    _tableView = nil;
    _tableViewDataSource = nil;
    _tableViewDelegate = nil;
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSSecureCoding
// ------------------------------------------------------------------------------------------
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    BOOL isSelected = [aDecoder decodeBoolForKey:kIsSelectedKey];
    if ((self = [super init]))
    {
        _isSelected = isSelected;
    }

    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:self.isSelected forKey:kIsSelectedKey];
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
#pragma mark - Type
// ------------------------------------------------------------------------------------------
- (GNEOutlineViewItemType)type
{
    NSAssert1(NO, @"Subclasses of GNEOutlineViewItem must implement %@", NSStringFromSelector(_cmd));
    return GNEOutlineViewItemTypeUnknown;
}


- (BOOL)isSection
{
    return (self.type == GNEOutlineViewItemTypeSection);
}


- (BOOL)isRow
{
    return (self.type == GNEOutlineViewItemTypeRow);
}


// ------------------------------------------------------------------------------------------
#pragma mark - Appearance
// ------------------------------------------------------------------------------------------
- (CGFloat)height
{
    NSAssert1(NO, @"Subclasses of GNEOutlineViewItem must implement %@", NSStringFromSelector(_cmd));
    return GNESectionedTableViewInvisibleRowHeight;
}


- (NSTableRowView *)rowView
{
    NSAssert1(NO, @"Subclasses of GNEOutlineViewItem must implement %@", NSStringFromSelector(_cmd));
    return [NSTableRowView new];
}


- (NSTableCellView *)cellView
{
    NSAssert1(NO, @"Subclasses of GNEOutlineViewItem must implement %@", NSStringFromSelector(_cmd));
    return nil;
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
