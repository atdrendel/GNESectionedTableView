//
//  GNEOutlineViewRowItem.m
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

#import "GNEOutlineViewRowItem.h"
#import "GNESectionedTableView.h"
#import "NSIndexPath+GNESectionedTableView.h"


// ------------------------------------------------------------------------------------------


static NSString * const kIndexPathKey = @"GNEOutlineViewRowItemIndexPath";


// ------------------------------------------------------------------------------------------


@implementation GNEOutlineViewRowItem


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
- (instancetype)initWithTableView:(GNESectionedTableView *)tableView
                       dataSource:(id<GNESectionedTableViewDataSource>)dataSource
                         delegate:(id<GNESectionedTableViewDelegate>)delegate
{
    NSAssert3(NO, @"Instances of %@ should not be initialized with %@. Use %@ instead.",
              NSStringFromClass([self class]), NSStringFromSelector(_cmd),
              NSStringFromSelector(@selector(initWithIndexPath:sectionItem:tableView:dataSource:delegate:)));
    NSIndexPath *indexPath = [NSIndexPath gne_indexPathForRow:NSNotFound inSection:NSNotFound];

    return [self initWithIndexPath:indexPath
                       sectionItem:nil
                         tableView:tableView
                        dataSource:dataSource
                          delegate:delegate];
}


- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath
                      sectionItem:(GNEOutlineViewSectionItem *)sectionItem
                        tableView:(GNESectionedTableView *)tableView
                       dataSource:(id<GNESectionedTableViewDataSource>)dataSource
                         delegate:(id<GNESectionedTableViewDelegate>)delegate
{
    if ((self = [super initWithTableView:tableView dataSource:dataSource delegate:delegate]))
    {
        _indexPath = indexPath;
        _sectionItem = sectionItem;
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
    if ((self = [super initWithCoder:aDecoder]))
    {
        _indexPath = indexPath;
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
#pragma mark - Type
// ------------------------------------------------------------------------------------------
- (GNEOutlineViewItemType)type
{
    return GNEOutlineViewItemTypeRow;
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


@end
