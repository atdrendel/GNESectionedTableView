//
//  GNEOutlineViewSectionItem.m
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

#import "GNEOutlineViewSectionItem.h"
#import "GNEOutlineViewRowItem.h"
#import "GNESectionedTableView.h"
#import "NSIndexPath+GNESectionedTableView.h"


// ------------------------------------------------------------------------------------------


static NSString * const kRowItemsKey = @"GNEOutlineViewSectionItemRowItems";
static NSString * const kFooterItemKey = @"GNEOutlineViewSectionItemFooterItem";

static const NSUInteger kSectionHeaderRowModifier = 1;
static const NSUInteger kSectionFooterRowModifier = 2;


// ------------------------------------------------------------------------------------------


NSIndexPath * GNEHeaderIndexPathForSection(NSUInteger section)
{
    NSUInteger headerRow = (NSUInteger)(NSNotFound - kSectionHeaderRowModifier);

    return [NSIndexPath gne_indexPathForRow:headerRow inSection:section];
}


NSIndexPath * GNEFooterIndexPathForSection(NSUInteger section)
{
    NSUInteger footerRow = (NSUInteger)(NSNotFound - kSectionFooterRowModifier);
        
    return [NSIndexPath gne_indexPathForRow:footerRow inSection:section];
}


// ------------------------------------------------------------------------------------------


@interface GNEOutlineViewSectionItem ()

@property (nonatomic, assign, readwrite) BOOL isExpanded;
@property (nonatomic, copy) NSArray *rowItems;
@property (nonatomic, strong) GNEOutlineViewRowItem *footerItem;

@end


// ------------------------------------------------------------------------------------------


@implementation GNEOutlineViewSectionItem


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
- (instancetype)initWithTableView:(GNESectionedTableView *)tableView
                       dataSource:(id<GNESectionedTableViewDataSource>)dataSource
                         delegate:(id<GNESectionedTableViewDelegate>)delegate
{
    NSAssert3(NO, @"Instances of %@ should not be initialized with %@. Use %@ instead.",
              NSStringFromClass([self class]), NSStringFromSelector(_cmd),
              NSStringFromSelector(@selector(initWithSection:tableView:dataSource:delegate:)));

    return [self initWithSection:NSNotFound
                       tableView:tableView
                      dataSource:dataSource
                        delegate:delegate];
}


- (instancetype)initWithSection:(NSUInteger)section
                      tableView:(GNESectionedTableView *)tableView
                     dataSource:(id<GNESectionedTableViewDataSource>)dataSource
                       delegate:(id<GNESectionedTableViewDelegate>)delegate
{
    if ((self = [super initWithTableView:tableView
                              dataSource:dataSource
                                delegate:delegate]))
    {
        _section = section;
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
        _footerItem = [aDecoder decodeObjectOfClass:[GNEOutlineViewRowItem class] forKey:kFooterItemKey];
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
#pragma mark - Type
// ------------------------------------------------------------------------------------------
- (GNEOutlineViewItemType)type
{
    return GNEOutlineViewItemTypeSection;
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
- (BOOL)containsRowItem:(GNEOutlineViewRowItem *)item
{
    GNEParameterAssert(item.isRow);

    return [self.rowItems containsObject:item];
}


- (NSUInteger)indexOfRowItem:(GNEOutlineViewRowItem *)item
{
    GNEParameterAssert(item.isRow);

    return [self.rowItems indexOfObject:item];
}


- (GNEOutlineViewRowItem *)rowItemAtIndex:(NSUInteger)index
{
    GNEParameterAssert(index < self.rowItems.count);
    NSUInteger count = self.rowItems.count;
    if (index < count)
    {
        return self.rowItems[index];
    }

    return nil;
}


- (NSArray *)rowItemsAtIndexes:(NSIndexSet *)indexes
{
    NSMutableArray *items = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop __unused)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        GNEOutlineViewRowItem *item = [strongSelf rowItemAtIndex:index];
        if (item)
        {
            [items addObject:item];
        }
    }];

    return [items copy];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Expand/Collapse
// ------------------------------------------------------------------------------------------
- (void)expand:(BOOL)animated
{
    GNESectionedTableView *tableView = [self p_tableView:animated];
    if (self.canExpand)
    {
        [self p_notifyDelegateWillExpand];
        [tableView expandItem:self expandChildren:YES];
        [self p_notifyDelegateDidExpand];
    }
}


- (void)collapse:(BOOL)animated
{
    GNESectionedTableView *tableView = [self p_tableView:animated];
    if (self.canCollapse)
    {
        [self p_notifyDelegateWillCollapse];
        [tableView collapseItem:self collapseChildren:YES];
        [self p_notifyDelegateDidCollapse];
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - Insert, Delete, and Update Items
// ------------------------------------------------------------------------------------------
- (void)insertRowItems:(NSArray *)items
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


- (NSArray *)deleteRowItemsAtIndexes:(NSIndexSet *)indexes
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

        GNEOutlineViewRowItem *item = mutableRowItems[index];
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


- (void)reloadRowItemsAtIndexes:(NSIndexSet *)indexes
{
    NSArray *items = [self rowItemsAtIndexes:indexes];
    for (GNEOutlineViewRowItem *item in items)
    {
        [self.tableView reloadItem:item];
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - Table View
// ------------------------------------------------------------------------------------------
- (GNESectionedTableView *)p_tableView:(BOOL)animated
{
    GNESectionedTableView *tableView = self.tableView;

    return (animated) ? tableView.animator : tableView;
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
        [rowItems addObject:[self p_newRowItemWithIndexPath:indexPath]];
    }

    self.rowItems = [rowItems copy];
}


- (void)p_buildFooterItem
{
    [self p_assertDataSourceDelegateAreValid];
    BOOL hasFooter = [self p_requestDelegateHasFooter];
    self.footerItem = (hasFooter) ? [self p_newFooterItem] : nil;
}


- (void)p_updateParentItemOfRowItemsAndFooterItem
{
    for (GNEOutlineViewRowItem *item in self.rowItems)
    {
        item.sectionItem = self;
    }
    self.footerItem.sectionItem = self;
}


- (void)p_updateIndexPathsOfRowItemsAndFooterItem
{
    NSUInteger section = self.section;
    NSUInteger count = self.rowItems.count;
    for (NSUInteger row = 0; row < count; row++)
    {
        GNEOutlineViewRowItem *item = self.rowItems[row];
        item.indexPath = [NSIndexPath gne_indexPathForRow:row inSection:section];
    }
    self.footerItem.indexPath = footerIndexPathForSection(section);
}


- (GNEOutlineViewRowItem *)p_newRowItemWithIndexPath:(NSIndexPath *)indexPath
{
    GNEOutlineViewRowItem *item = [[GNEOutlineViewRowItem alloc] initWithIndexPath:indexPath
                                                                       sectionItem:self
                                                                         tableView:self.tableView
                                                                        dataSource:self.tableViewDataSource
                                                                          delegate:self.tableViewDelegate];

    return item;
}


- (GNEOutlineViewRowItem *)p_newFooterItem
{
    NSIndexPath *indexPath = footerIndexPathForSection(self.section);
    GNEOutlineViewRowItem *footerItem = [self p_newRowItemWithIndexPath:indexPath];
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


- (void)p_notifyDelegateWillExpand
{
    id<GNESectionedTableViewDelegate> delegate = self.tableViewDelegate;
    if ([delegate respondsToSelector:@selector(tableView:willExpandSection:)])
    {
        [delegate tableView:self.tableView willExpandSection:self.section];
    }
}


- (void)p_notifyDelegateWillCollapse
{
    id<GNESectionedTableViewDelegate> delegate = self.tableViewDelegate;
    if ([delegate respondsToSelector:@selector(tableView:willCollapseSection:)])
    {
        [delegate tableView:self.tableView willCollapseSection:self.section];
    }
}


- (void)p_notifyDelegateDidExpand
{
    id<GNESectionedTableViewDelegate> delegate = self.tableViewDelegate;
    if ([delegate respondsToSelector:@selector(tableView:didExpandSection:)])
    {
        [delegate tableView:self.tableView didExpandSection:self.section];
    }
}


- (void)p_notifyDelegateDidCollapse
{
    id<GNESectionedTableViewDelegate> delegate = self.tableViewDelegate;
    if ([delegate respondsToSelector:@selector(tableView:didCollapseSection:)])
    {
        [delegate tableView:self.tableView didCollapseSection:self.section];
    }
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
    for (GNEOutlineViewRowItem *item in self.rowItems)
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
- (void)setSection:(NSUInteger)section
{
    if (_section != section)
    {
        _section = section;
        [self p_updateIndexPathsOfRowItemsAndFooterItem];
    }
}


- (BOOL)isCollapsed
{
    return (self.isExpanded == NO);
}


- (BOOL)canExpand
{
    id<GNESectionedTableViewDelegate> delegate = self.tableViewDelegate;
    SEL selector = @selector(tableView:shouldExpandSection:);
    BOOL responds = [delegate respondsToSelector:selector];
    if (responds)
    {
        return [delegate tableView:self.tableView shouldExpandSection:self.section];
    }

    return YES;
}


- (BOOL)canCollapse
{
    id<GNESectionedTableViewDelegate> delegate = self.tableViewDelegate;
    SEL selector = @selector(tableView:shouldCollapseSection:);
    BOOL responds = [delegate respondsToSelector:selector];
    if (responds)
    {
        return [delegate tableView:self.tableView shouldCollapseSection:self.section];
    }

    return YES;
}


- (BOOL)hasFooter
{
    return (self.footerItem != nil);
}


@end
