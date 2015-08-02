//
//  GNEOutlineViewParentItem.m
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

#import "GNESectionedTableView.h"
#import "GNEOutlineViewParentItem.h"
#import "NSIndexPath+GNESectionedTableView.h"


// ------------------------------------------------------------------------------------------


static NSString * const kRowItemsKey = @"GNEOutlineViewParentItemRowItems";
static NSString * const kFooterItemKey = @"GNEOutlineViewParentItemFooterItem";

static const NSUInteger kSectionHeaderRowModifier = 1;
static const NSUInteger kSectionFooterRowModifier = 2;


// ------------------------------------------------------------------------------------------


NSIndexPath * headerIndexPathForSection(NSUInteger section)
{
    NSUInteger headerRow = (NSUInteger)(NSNotFound - kSectionHeaderRowModifier);

    return [NSIndexPath gne_indexPathForRow:headerRow inSection:section];
}


NSIndexPath * footerIndexPathForSection(NSUInteger section)
{
    NSUInteger footerRow = (NSUInteger)(NSNotFound - kSectionFooterRowModifier);
        
    return [NSIndexPath gne_indexPathForRow:footerRow inSection:section];
}


// ------------------------------------------------------------------------------------------


@interface GNEOutlineViewParentItem ()

@property (nonatomic, copy) NSArray *rowItems;
@property (nonatomic, strong) GNEOutlineViewItem *footerItem;

@end


// ------------------------------------------------------------------------------------------


@implementation GNEOutlineViewParentItem

@dynamic section;


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath
                       parentItem:(GNEOutlineViewParentItem * __unused)parentItem
                        tableView:(GNESectionedTableView *)tableView
                       dataSource:(id<GNESectionedTableViewDataSource>)dataSource
                         delegate:(id<GNESectionedTableViewDelegate>)delegate
{
    NSAssert3(NO, @"Instances of %@ should not be initialized with %@. Use %@ instead.",
              NSStringFromClass([self class]), NSStringFromSelector(_cmd),
              NSStringFromSelector(@selector(initWithSection:tableView:dataSource:delegate:)));

    return [self initWithSection:indexPath.gne_section tableView:tableView
                      dataSource:dataSource delegate:delegate];
}


- (instancetype)initWithSection:(NSUInteger)section
                      tableView:(GNESectionedTableView *)tableView
                     dataSource:(id<GNESectionedTableViewDataSource>)dataSource
                       delegate:(id<GNESectionedTableViewDelegate>)delegate
{
    NSIndexPath *indexPath = headerIndexPathForSection(section);
    if ((self = [super initWithIndexPath:indexPath parentItem:nil tableView:tableView
                              dataSource:dataSource delegate:delegate]))
    {
        [self p_buildRowItems];
        [self p_buildFooterItem];
    }

    return self;
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSSecureCoding
// ------------------------------------------------------------------------------------------
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        _rowItems = [aDecoder decodeObjectOfClass:[NSArray class] forKey:kRowItemsKey];
        _footerItem = [aDecoder decodeObjectOfClass:[GNEOutlineViewItem class] forKey:kFooterItemKey];
        [self p_updateParentItemOfRowItemsAndFooterItem];
    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.rowItems forKey:kRowItemsKey];
    [aCoder encodeObject:self.footerItem forKey:kFooterItemKey];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Appearance
// ------------------------------------------------------------------------------------------
- (CGFloat)height
{
    id<GNESectionedTableViewDelegate> delegate = self.tableViewDelegate;
    if ([delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)])
    {
        return [delegate tableView:self.tableView heightForHeaderInSection:self.section];
    }

    return GNESectionedTableViewInvisibleRowHeight;
}


- (NSTableRowView *)rowView
{
    NSTableRowView *rowView = nil;
    id<GNESectionedTableViewDelegate> delegate = self.tableViewDelegate;
    if ([delegate respondsToSelector:@selector(tableView:rowViewForHeaderInSection:)])
    {
        rowView = [delegate tableView:self.tableView rowViewForHeaderInSection:self.section];
    }

    return rowView ?: [NSTableRowView new];
}


- (NSTableCellView *)cellView
{
    id<GNESectionedTableViewDelegate> delegate = self.tableViewDelegate;
    if ([delegate respondsToSelector:@selector(tableView:cellViewForHeaderInSection:)])
    {
        return [delegate tableView:self.tableView cellViewForHeaderInSection:self.section];
    }

    return nil;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Item Accessors
// ------------------------------------------------------------------------------------------
- (GNEOutlineViewItem *)itemAtIndex:(NSUInteger)index
{
    NSUInteger count = self.rowItems.count;
    if (index < count)
    {
        return self.rowItems[index];
    }

    return nil;
}


- (NSArray *)itemsAtIndexes:(NSIndexSet *)indexes
{
    NSMutableArray *items = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop __unused)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        GNEOutlineViewItem *item = [strongSelf itemAtIndex:index];
        if (item)
        {
            [items addObject:item];
        }
    }];

    return [items copy];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Insert, Delete, and Update Items
// ------------------------------------------------------------------------------------------
- (void)insertItems:(NSArray *)items
            atIndex:(NSUInteger)index
      withAnimation:(NSTableViewAnimationOptions)animationOptions
{
    NSUInteger count = self.rowItems.count;
    GNEParameterAssert(index <= count);
    if (items.count == 0 || index > count) { return; }

    NSMutableArray *mutableRowItems = [NSMutableArray arrayWithArray:self.rowItems];
    NSRange indexRange = NSMakeRange(index, items.count);
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:indexRange];
    [mutableRowItems insertObjects:items atIndexes:indexes];
    [self p_updateParentItemOfRowItemsAndFooterItem];
    [self p_updateIndexPathsOfRowItemsAndFooterItem];
    [self.tableView insertItemsAtIndexes:indexes inParent:self withAnimation:animationOptions];
}


- (NSArray *)deleteItemsAtIndexes:(NSIndexSet *)indexes
                    withAnimation:(NSTableViewAnimationOptions)animationOptions
{
    if (indexes.count == 0) { return @[]; };

    NSMutableArray *deletedItems = [NSMutableArray array];
    NSMutableArray *mutableRowItems = [NSMutableArray arrayWithArray:self.rowItems];
    NSMutableIndexSet *deletedIndexes = [NSMutableIndexSet indexSet];

    [indexes enumerateIndexesWithOptions:NSEnumerationReverse
                              usingBlock:^(NSUInteger index, BOOL *stop __unused)
    {
        GNEParameterAssert(index < mutableRowItems.count);
        if (index >= mutableRowItems.count) { return; }

        GNEOutlineViewItem *item = mutableRowItems[index];
        [deletedItems addObject:item];
        [mutableRowItems removeObjectAtIndex:index];
        [deletedIndexes addIndex:index];
    }];

    self.rowItems = [mutableRowItems copy];
    [self.tableView removeItemsAtIndexes:deletedIndexes
                                inParent:self
                           withAnimation:animationOptions];

    return [deletedItems copy];
}


- (void)reloadItemsAtIndexes:(NSIndexSet *)indexes
{
    NSArray *items = [self itemsAtIndexes:indexes];
    for (GNEOutlineViewItem *item in items)
    {
        [self.tableView reloadItem:item];
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - Row/Footer Items
// ------------------------------------------------------------------------------------------
- (void)p_buildRowItems
{
    [self p_assertDataSourceDelegateAreValid];
    NSMutableArray *rowItems = [NSMutableArray array];
    NSUInteger section = self.section;
    NSUInteger count = [self p_requestDelegateNumberOfRows];
    for (NSUInteger row = 0; row < count; row++)
    {
        NSIndexPath *indexPath = [NSIndexPath gne_indexPathForRow:row inSection:section];
        [rowItems addObject:[self p_itemWithIndexPath:indexPath]];
    }

    self.rowItems = [rowItems copy];
}


- (void)p_buildFooterItem
{
    [self p_assertDataSourceDelegateAreValid];
    BOOL hasFooter = [self p_requestDelegateHasFooter];
    self.footerItem = (hasFooter) ? [self p_footerItem] : nil;
}


- (void)p_updateParentItemOfRowItemsAndFooterItem
{
    for (GNEOutlineViewItem *item in self.rowItems)
    {
        item.parentItem = self;
    }
    self.footerItem.parentItem = self;
}


- (void)p_updateIndexPathsOfRowItemsAndFooterItem
{
    NSUInteger section = self.section;
    NSUInteger count = self.rowItems.count;
    for (NSUInteger row = 0; row < count; row++)
    {
        GNEOutlineViewItem *item = self.rowItems[row];
        item.indexPath = [NSIndexPath gne_indexPathForRow:row inSection:section];
    }
    self.footerItem.indexPath = footerIndexPathForSection(section);
}


- (GNEOutlineViewItem *)p_itemWithIndexPath:(NSIndexPath *)indexPath
{
    GNEOutlineViewItem *item = [[GNEOutlineViewItem alloc] initWithIndexPath:indexPath
                                                                  parentItem:self
                                                                   tableView:self.tableView
                                                                  dataSource:self.tableViewDataSource
                                                                    delegate:self.tableViewDelegate];

    return item;
}


- (GNEOutlineViewItem *)p_footerItem
{
    NSIndexPath *indexPath = footerIndexPathForSection(self.section);
    GNEOutlineViewItem *footerItem = [self p_itemWithIndexPath:indexPath];
    footerItem.isFooter = YES;

    return footerItem;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Data Source / Delegate
// ------------------------------------------------------------------------------------------
- (void)p_assertDataSourceDelegateAreValid
{
    GNEParameterAssert([self.tableViewDataSource conformsToProtocol:@protocol(GNESectionedTableViewDataSource)]);
    GNEParameterAssert([self.tableViewDelegate conformsToProtocol:@protocol(GNESectionedTableViewDelegate)]);
}


- (NSUInteger)p_requestDelegateNumberOfRows
{
    id<GNESectionedTableViewDataSource> dataSource = self.tableViewDataSource;
    if ([dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)])
    {
        return [dataSource tableView:self.tableView numberOfRowsInSection:self.section];
    }

    return 0;
}


- (BOOL)p_requestDelegateHasFooter
{
    id<GNESectionedTableViewDataSource> dataSource = self.tableViewDataSource;
    if ([dataSource respondsToSelector:@selector(tableView:hasFooterInSection:)])
    {
        return [dataSource tableView:self.tableView hasFooterInSection:self.section];
    }

    return NO;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Description
// ------------------------------------------------------------------------------------------
- (NSString *)description
{
    NSString *sectionString = @"[\n";
    for (GNEOutlineViewItem *item in self.rowItems)
    {
        sectionString = [sectionString stringByAppendingFormat:@"\t%@\n", item.description];
    }
    sectionString = [sectionString stringByAppendingString:@"]"];
    
    return [NSString stringWithFormat:@"<%@: %p> Section %lu\n%@", NSStringFromClass([self class]),
            self, (unsigned long)self.section, sectionString];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Accessors
// ------------------------------------------------------------------------------------------
- (void)setParentItem:(GNEOutlineViewParentItem * __unused)parentItem
{
    NSAssert(NO, @"Outline view parent items cannot have parent items.");
}


- (NSUInteger)section
{
    return self.indexPath.gne_section;
}


- (void)setSection:(NSUInteger)section
{
    if (self.indexPath.gne_section != section)
    {
        self.indexPath = headerIndexPathForSection(section);
        [self p_updateIndexPathsOfRowItemsAndFooterItem];
    }
}


- (BOOL)hasFooter
{
    return (self.footerItem != nil);
}


@end
