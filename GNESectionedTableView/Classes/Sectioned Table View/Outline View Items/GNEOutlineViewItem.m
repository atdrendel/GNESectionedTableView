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
#import "GNESectionedTableView.h"
#import "NSIndexPath+GNESectionedTableView.h"


// ------------------------------------------------------------------------------------------


NSString * const GNEOutlineViewItemPasteboardType = @"com.goneeast.GNEOutlineViewItemPasteboardType";

static NSString * const kIndexPathKey = @"GNEOutlineViewItemIndexPathKey";


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
              NSStringFromSelector(@selector(initWithIndexPath:parentItem:tableView:dataSource:delegate:)));
    return nil;
}
#pragma clang diagnostic pop


- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath
                       parentItem:(GNEOutlineViewParentItem *)parentItem
                        tableView:(GNESectionedTableView *)tableView
                       dataSource:(id<GNESectionedTableViewDataSource>)dataSource
                         delegate:(id<GNESectionedTableViewDelegate>)delegate
{
    if ((self = [super init]))
    {
        _indexPath = indexPath;
        _parentItem = parentItem;
        _tableView = tableView;
        _tableViewDataSource = dataSource;
        _tableViewDelegate = delegate;
    }
    
    return self;
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSSecureCoding
// ------------------------------------------------------------------------------------------
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSIndexPath *indexPath = [aDecoder decodeObjectOfClass:[NSIndexPath class]
                                                    forKey:kIndexPathKey];
    if ((self = [super init]))
    {
        _indexPath = indexPath;
        _parentItem = nil;
    }

    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.indexPath forKey:kIndexPathKey];
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
#pragma mark - Appearance
// ------------------------------------------------------------------------------------------
- (CGFloat)height
{
    return (self.isFooter) ? [self p_requestDelegateHeightOfFooter] : [self p_requestDelegateHeightOfCell];
}


- (NSTableRowView *)rowView
{
    return (self.isFooter) ? [self p_requestDelegateRowViewOfFooter] : [self p_requestDelegateRowViewOfCell];
}


- (NSTableCellView *)cellView
{
    return (self.isFooter) ? [self p_requestDelegateCellViewOfFooter] : [self p_requestDelegateCellViewOfCell];
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableViewDelegate
// ------------------------------------------------------------------------------------------
- (CGFloat)p_requestDelegateHeightOfCell
{
    id<GNESectionedTableViewDelegate> delegate = self.tableViewDelegate;
    if ([delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)])
    {
        return [delegate tableView:self.tableView heightForRowAtIndexPath:self.indexPath];
    }

    return GNESectionedTableViewInvisibleRowHeight;
}


- (CGFloat)p_requestDelegateHeightOfFooter
{
    id<GNESectionedTableViewDelegate> delegate = self.tableViewDelegate;
    if ([delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)])
    {
        return [delegate tableView:self.tableView heightForFooterInSection:self.indexPath.gne_section];
    }

    return GNESectionedTableViewInvisibleRowHeight;
}


- (NSTableRowView *)p_requestDelegateRowViewOfCell
{
    NSTableRowView *rowView = nil;
    id<GNESectionedTableViewDelegate> delegate = self.tableViewDelegate;
    if ([delegate respondsToSelector:@selector(tableView:rowViewForRowAtIndexPath:)])
    {
        rowView = [delegate tableView:self.tableView rowViewForRowAtIndexPath:self.indexPath];
    }

    return rowView ?: [NSTableRowView new];
}


- (NSTableRowView *)p_requestDelegateRowViewOfFooter
{
    NSTableRowView *rowView = nil;
    id<GNESectionedTableViewDelegate> delegate = self.tableViewDelegate;
    if ([delegate respondsToSelector:@selector(tableView:rowViewForFooterInSection:)])
    {
        rowView = [delegate tableView:self.tableView rowViewForFooterInSection:self.indexPath.gne_section];
    }

    return rowView ?: [NSTableRowView new];
}


- (NSTableCellView *)p_requestDelegateCellViewOfCell
{
    id<GNESectionedTableViewDelegate> delegate = self.tableViewDelegate;
    if ([delegate respondsToSelector:@selector(tableView:cellViewForRowAtIndexPath:)])
    {
        return [delegate tableView:self.tableView cellViewForRowAtIndexPath:self.indexPath];
    }

    return nil;
}


- (NSTableCellView *)p_requestDelegateCellViewOfFooter
{
    id<GNESectionedTableViewDelegate> delegate = self.tableViewDelegate;
    if ([delegate respondsToSelector:@selector(tableView:cellViewForFooterInSection:)])
    {
        return [delegate tableView:self.tableView cellViewForFooterInSection:self.indexPath.gne_section];
    }

    return nil;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Description
// ------------------------------------------------------------------------------------------
- (NSString *)description
{
    unsigned long section = self.indexPath.gne_section;
    unsigned long row = self.indexPath.gne_row;
    NSString *indexPathString = [NSString stringWithFormat:@"Index Path: {%lu, %lu}", section, row];
    
    return [NSString stringWithFormat:@"<%@: %p> %@",
            NSStringFromClass([self class]), self, indexPathString];
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
