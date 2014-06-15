//
//  GNESectionedTableView.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 5/27/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

#import "GNESectionedTableView.h"
#import "NSOutlineView+GNE_Additions.h"

#import "GNEOutlineViewItem.h"
#import "GNEOutlineViewParentItem.h"

// ------------------------------------------------------------------------------------------


static NSString * const kOutlineViewOutlineColumnIdentifier = @"com.goneeast.OutlineViewOutlineColumn";
static NSString * const kOutlineViewStandardColumnIdentifier = @"com.goneeast.OutlineViewStandardColumn";

static NSString * const kOutlineViewStandardHeaderRowViewIdentifier =
                                                        @"com.goneeast.OutlineViewStandardHeaderRowViewIdentifier";
static NSString * const kOutlineViewStandardHeaderCellViewIdentifier =
                                                        @"com.goneeast.OutlineViewStandardHeaderCellViewIdentifier";

static const CGFloat kDefaultRowHeight = 32.0f;

// By default, unsafe row heights are not allowed. They seem to work in 10.9, but not in 10.8.
#ifdef UNSAFE_ROW_HEIGHT_ALLOWED
static const CGFloat kInvisibleRowHeight = 0.00001f;
#else
static const CGFloat kInvisibleRowHeight = 1.0f;
#endif


// ------------------------------------------------------------------------------------------


@interface GNESectionedTableView () <NSOutlineViewDataSource, NSOutlineViewDelegate>
{
    NSTableColumn *_privateOutlineColumn; // NSOutlineView doesn't retain its outlineColumn property
}


/// Array of outline view parent items that map to the table view's sections.
@property (nonatomic, strong) NSMutableArray *outlineViewParentItems;

/// Array of arrays of outline view items that map to the table view's rows.
@property (nonatomic, strong) NSMutableArray *outlineViewItems;


@end


// ------------------------------------------------------------------------------------------


@implementation GNESectionedTableView


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
- (instancetype)init
{
    if ((self = [super init]))
    {
        [self p_commonInitialization];
    }
    
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self p_commonInitialization];
    }
    
    return self;
}


- (void)p_commonInitialization
{
    _outlineViewParentItems = [NSMutableArray array];
    _outlineViewItems = [NSMutableArray array];
    
    [self setDataSource:self];
    [self setDelegate:self];
    
    [self setWantsLayer:YES];
    [self setLayerContentsRedrawPolicy:NSViewLayerContentsRedrawOnSetNeedsDisplay];
    
    [self setGridStyleMask:NSTableViewGridNone];
    
    [self setHeaderView:nil];
    [self setCornerView:nil];
    
    _privateOutlineColumn = [[NSTableColumn alloc] initWithIdentifier:kOutlineViewOutlineColumnIdentifier];
    [self setOutlineTableColumn:_privateOutlineColumn];
    NSTableColumn *standardColumn = [[NSTableColumn alloc] initWithIdentifier:kOutlineViewStandardColumnIdentifier];
    [standardColumn setResizingMask:NSTableColumnAutoresizingMask];
    [self addTableColumn:standardColumn];
    [self setAllowsColumnResizing:NO];
    
    [self setColumnAutoresizingStyle:NSTableViewLastColumnOnlyAutoresizingStyle];
    [self setAutoresizesOutlineColumn:NO];
    
    [self setRowSizeStyle:NSTableViewRowSizeStyleCustom];
    
    [self expandItem:nil expandChildren:YES];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Dealloc
// ------------------------------------------------------------------------------------------
- (void)dealloc
{
    _tableViewDataSource = nil;
    _tableViewDelegate = nil;
    
    _privateOutlineColumn = nil;
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSView
// ------------------------------------------------------------------------------------------
- (void)viewDidMoveToWindow
{
    if ([self window])
    {
        [self p_sizeStandardTableColumnToFit];
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSOutlineView
// ------------------------------------------------------------------------------------------
// Disable responsive scrolling
- (CGRect)preparedContentRect
{
    return [self visibleRect];
}


// Disable responsive scrolling
- (void)prepareContentInRect:(CGRect __unused)rect
{
    
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Public - Insertion, Deletion, Move, and Update
// ------------------------------------------------------------------------------------------
- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withAnimation:(NSTableViewAnimationOptions)animationOptions
{
    [self p_checkIndexPathsArray:indexPaths];
    
    NSArray *groupedIndexPaths = [self p_sortedIndexPathsGroupedBySectionInIndexPaths:indexPaths];
    
    for (NSArray *indexPathsInSection in groupedIndexPaths)
    {
        @autoreleasepool
        {
            NSMutableIndexSet *insertedIndexes = [NSMutableIndexSet indexSet];
            NSUInteger section = ((NSIndexPath *)[indexPathsInSection firstObject]).gne_section;
            
            GNEOutlineViewParentItem *parentItem = [self p_outlineViewParentItemForSection:section];
            NSAssert1(parentItem, @"No outline view parent item exists for section %lu", (long unsigned)section);
            
            if (parentItem == nil)
            {
                return;
            }
            
            NSUInteger parentItemIndex = [self.outlineViewParentItems indexOfObject:parentItem];
            NSParameterAssert(parentItemIndex < [self.outlineViewItems count]);
            
            NSMutableArray *rows = self.outlineViewItems[parentItemIndex];
            
            for (NSIndexPath *indexPath in indexPathsInSection)
            {
                GNEOutlineViewItem *outlineViewItem = [[GNEOutlineViewItem alloc] initWithIndexPath:indexPath
                                                                                         parentItem:parentItem];
                [insertedIndexes addIndex:[rows gne_insertObject:outlineViewItem atIndex:indexPath.gne_row]];
            }
            
            [self insertItemsAtIndexes:insertedIndexes inParent:parentItem withAnimation:animationOptions];
            [self p_updateIndexPathsForOutlineViewItemsInSection:section];
        }
    }
}


- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withAnimation:(NSTableViewAnimationOptions)animationOptions
{
    [self p_checkIndexPathsArray:indexPaths];
}


- (void)moveRowsAtIndexPaths:(NSArray *)fromIndexPaths toIndexPaths:(NSArray *)toIndexPaths
{
    [self p_checkIndexPathsArray:fromIndexPaths];
    [self p_checkIndexPathsArray:toIndexPaths];
}


- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths
{
    [self p_checkIndexPathsArray:indexPaths];
}


- (void)insertSections:(NSIndexSet *)sections withAnimation:(NSTableViewAnimationOptions)animationOptions
{
    NSParameterAssert([self.tableViewDataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]);
    
    NSMutableIndexSet *insertedSections = [NSMutableIndexSet indexSet];
    
    [sections enumerateIndexesUsingBlock:^(NSUInteger proposedSection, BOOL *stop __unused)
    {
        NSUInteger sectionCount = [self.outlineViewParentItems count];
        NSUInteger section = (proposedSection > sectionCount) ? sectionCount : proposedSection;
        
        NSIndexPath *parentItemIndexPath = [NSIndexPath gne_indexPathForRow:NSNotFound inSection:section];
        GNEOutlineViewParentItem *parentItem = [[GNEOutlineViewParentItem alloc]
                                                initWithIndexPath:parentItemIndexPath];
        parentItem.visible = [self p_outlineViewParentItemIsVisibleForSection:section];
        [self.outlineViewParentItems gne_insertObject:parentItem atIndex:section];
        
        NSUInteger rowCount = [self.tableViewDataSource tableView:self numberOfRowsInSection:section];
        
        NSMutableArray *rows = [NSMutableArray arrayWithCapacity:rowCount];
        [self.outlineViewItems gne_insertObject:rows atIndex:section];
        
        for (NSUInteger row = 0; row < rowCount; row++)
        {
            NSIndexPath *indexPath = [NSIndexPath gne_indexPathForRow:row inSection:section];
            GNEOutlineViewItem *item = [[GNEOutlineViewItem alloc] initWithIndexPath:indexPath
                                                                          parentItem:parentItem];
            
            [rows addObject:item];
        }
        
        [insertedSections addIndex:section];
    }];
    
    [self insertItemsAtIndexes:insertedSections inParent:nil withAnimation:animationOptions];
}


- (void)deleteSections:(NSIndexSet *)sections withAnimation:(NSTableViewAnimationOptions)animationOptions
{
    
}


- (void)moveSection:(NSUInteger)fromSection toSection:(NSUInteger)toSection
{
    
}


- (void)reloadSections:(NSIndexSet *)sections
{
    
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Public - Cell Frames
// ------------------------------------------------------------------------------------------
- (CGRect)frameOfCellAtIndexPath:(NSIndexPath *)indexPath
{
    GNEOutlineViewItem *item = [self p_outlineViewItemWithIndexPath:indexPath];
    if (item)
    {
        NSInteger row = [self rowForItem:item];
        
        return [super frameOfCellAtColumn:0 row:row];
    }
    
    return CGRectZero;
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Internal - Build Data Source Arrays
// ------------------------------------------------------------------------------------------
- (void)p_buildOutlineViewItemArrays
{
    NSUInteger sectionCount = [self p_numberOfSections];
    for (NSUInteger section = 0; section < sectionCount; section++)
    {
        NSIndexPath *parentItemIndexPath = [NSIndexPath gne_indexPathForRow:NSNotFound inSection:section];
        GNEOutlineViewParentItem *parentItem = [[GNEOutlineViewParentItem alloc]
                                                initWithIndexPath:parentItemIndexPath];
        BOOL isVisible = [self p_outlineViewParentItemIsVisibleForSection:section];
        parentItem.visible = isVisible;
        
        [self.outlineViewParentItems addObject:parentItem];
        NSMutableArray *rowArray = [NSMutableArray array];
        [self.outlineViewItems addObject:rowArray];
        
        NSUInteger rowCount = [self p_numberOfRowsInSection:section];
        for (NSUInteger row = 0; row < rowCount; row++)
        {
            NSIndexPath *itemIndexPath = [NSIndexPath gne_indexPathForRow:row inSection:section];
            GNEOutlineViewItem *item = [[GNEOutlineViewItem alloc] initWithIndexPath:itemIndexPath
                                                                          parentItem:parentItem];
            [rowArray addObject:item];
        }
    }
}


/**
 Determines if the outline view parent item for the specified item is visible to the user based on the height
    and row view of the section header returned by the table view delegate.
 
 @discussion This method should only be called when originally building the outline view item arrays. After the
                outline view parent items' visible property is initially set, it's up to the user to reload
                the cell.
 @param section Section of the outline view parent item.
 @return YES if the outline view parent item is visible, otherwise NO.
 */
- (BOOL)p_outlineViewParentItemIsVisibleForSection:(NSUInteger)section
{
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)] &&
        [self.tableViewDelegate respondsToSelector:@selector(tableView:rowViewForHeaderInSection:)])
    {
        CGFloat height = [self.tableViewDelegate tableView:self heightForHeaderInSection:section];
        NSTableRowView *rowView = [self.tableViewDelegate tableView:self rowViewForHeaderInSection:section];
        
        if (height > 0.0f && rowView)
        {
            return YES;
        }
    }
    
    return NO;
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Internal - Insert, Delete, Move Outline View Items
// ------------------------------------------------------------------------------------------
/**
 Updates the index paths of all of the outline view items currently belonging to the specified section.
 
 @param section Section whose outline view items need updating.
 */
- (void)p_updateIndexPathsForOutlineViewItemsInSection:(NSUInteger)section
{
    NSParameterAssert(section < [self.outlineViewItems count]);
    
    NSMutableArray *rows = self.outlineViewItems[section];
    NSUInteger count = [rows count];
    
    for (NSUInteger row = 0; row < count; row++)
    {
        GNEOutlineViewItem *item = rows[row];
        NSIndexPath *indexPath = [NSIndexPath gne_indexPathForRow:row inSection:section];
        item.indexPath = indexPath;
    }
}


/**
 Returns an array of arrays. Each inner array contains all of the specified index paths belonging to the same 
    section. The sections and rows are all sorted in ascending order (from smallest to largest).
 
 @param indexPaths Array of index paths to group and sort.
 @return Array of arrays of index paths sorted in ascending order by section and row.
 */
- (NSArray *)p_sortedIndexPathsGroupedBySectionInIndexPaths:(NSArray *)indexPaths
{
    NSMutableArray *groupedIndexPaths = [NSMutableArray array];
    SEL compareSelector = NSSelectorFromString(@"gne_compare:");
    NSArray *sortedIndexPaths = [indexPaths sortedArrayUsingSelector:compareSelector];
    
    NSUInteger currentSection = NSNotFound;
    NSMutableArray *indexPathsInCurrentSection = nil;
    
    for (NSIndexPath *indexPath in sortedIndexPaths)
    {
        if (currentSection != indexPath.gne_section)
        {
            currentSection = indexPath.gne_section;
            indexPathsInCurrentSection = [NSMutableArray array];
            [groupedIndexPaths addObject:indexPathsInCurrentSection];
        }
        
        [indexPathsInCurrentSection addObject:indexPath];
    }
    
    return groupedIndexPaths;
}



// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Internal - Retrieving Outline View Items
// ------------------------------------------------------------------------------------------
- (GNEOutlineViewItem *)p_outlineViewItemAtIndex:(NSUInteger)index ofParent:(GNEOutlineViewParentItem *)parentItem
{
    NSParameterAssert(parentItem == nil || [parentItem isKindOfClass:[GNEOutlineViewParentItem class]]);
    
    if (parentItem)
    {
        NSUInteger parentItemIndex = parentItem.indexPath.gne_section;
        
        NSParameterAssert(parentItemIndex < [self.outlineViewItems count]);
        
        NSArray *itemArray = self.outlineViewItems[parentItemIndex];
        
        NSParameterAssert(index < [itemArray count]);
        
        return [itemArray objectAtIndex:index];
    }
    else
    {
        NSParameterAssert(index < [self.outlineViewParentItems count]);
        
        return self.outlineViewParentItems[index];
    }
    
    NSAssert2(NO, @"Could not find item at index %lu of parent %@", (unsigned long)index, parentItem);
    
    return nil;
}


/**
 Returns the outline view item or parent item matching the specified index path.
 
 @discussion This method first tries to match the outline view parent item at the specified index path. If that
                outline view parent item doesn't match, it iterates through all of the outline view items
                in the specified section until a match is found. If a match still can't be found, it iterates
                through all of the outline view items until it finds a match.
 @param indexPath Index path to use to find a matching outline view item.
 @return Outline view item matching the specified index path, otherwise nil.
 */
- (GNEOutlineViewItem *)p_outlineViewItemWithIndexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert(indexPath);
    
    BOOL isParentItem = (indexPath.gne_row == NSNotFound);
    
    if (isParentItem)
    {
        return [self p_outlineViewParentItemWithIndexPath:indexPath];
    }
    else
    {
        NSUInteger sectionCount = [self.outlineViewItems count];
        if (indexPath.gne_section < sectionCount)
        {
            NSArray *rowArray = self.outlineViewItems[indexPath.gne_section];
            NSUInteger rowCount = [rowArray count];
            
            // First, try the outline view item at the specified index path.
            if (indexPath.gne_row < rowCount)
            {
                GNEOutlineViewItem *item = rowArray[indexPath.gne_row];
                if ([item.indexPath compare:indexPath] == NSOrderedSame)
                {
                    return item;
                }
            }
            
            // Then, try the other items in the same section.
            for (NSUInteger i = 0; i < rowCount; i++)
            {
                GNEOutlineViewItem *item = rowArray[i];
                if ([item.indexPath compare:indexPath] == NSOrderedSame)
                {
                    return item;
                }
            }
        }
        
        // Lastly, iterate through all of the outline view items until a match is found.
        for (NSUInteger section = 0; section < sectionCount; section++)
        {
            NSArray *rowArray = self.outlineViewItems[section];
            NSUInteger rowCount = [rowArray count];
            
            for (NSUInteger row = 0; row < rowCount; row++)
            {
                GNEOutlineViewItem *item = rowArray[row];
                if ([item.indexPath compare:indexPath] == NSOrderedSame)
                {
                    return item;
                }
            }
        }
    }
    
    return nil;
}


/**
 Returns the outline view parent item for the specified section.
 
 @discussion This method first tries to match the outline view parent item at the specified index path. If that
                outline view parent item doesn't match, it iterates through all of the outline view parent
                items until a match is found.
 @param section Section to use to find a matching outline view parent item.
 @return Outline view parent item matching the specified section, otherwise nil.
 */
- (GNEOutlineViewParentItem *)p_outlineViewParentItemForSection:(NSUInteger)section
{
    NSIndexPath *indexPath = [NSIndexPath gne_indexPathForRow:NSNotFound inSection:section];
    
    return [self p_outlineViewParentItemWithIndexPath:indexPath];
}


/**
 Returns the outline view parent item matching the specified index path.
 
 @discussion This method first tries to match the outline view parent item at the specified index path. If that
                outline view parent item doesn't match, it iterates through all of the outline view parent
                items until a match is found.
 @param indexPath Index path to use to find a matching outline view parent item.
 @return Outline view parent item matching the specified index path, otherwise nil.
 */
- (GNEOutlineViewParentItem *)p_outlineViewParentItemWithIndexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert(indexPath);
    NSParameterAssert(indexPath.gne_row == NSNotFound);
    
    NSUInteger parentItemsCount = [self.outlineViewParentItems count];
    
    if (indexPath.gne_section < parentItemsCount)
    {
        GNEOutlineViewParentItem *parentItem = self.outlineViewParentItems[indexPath.gne_section];
        if ([parentItem.indexPath compare:indexPath] == NSOrderedSame)
        {
            return parentItem;
        }
    }
    
    for (NSUInteger i = 0; i < parentItemsCount; i++)
    {
        GNEOutlineViewParentItem *parentItem = self.outlineViewParentItems[i];
        if ([parentItem.indexPath compare:indexPath] == NSOrderedSame)
        {
            return parentItem;
        }
    }
    
    return nil;
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Internal - Counts
// ------------------------------------------------------------------------------------------
- (NSUInteger)p_numberOfSections
{
    if ([self.tableViewDataSource respondsToSelector:@selector(numberOfSectionsInTableView:)])
    {
        return [self.tableViewDataSource numberOfSectionsInTableView:self];
    }
    
    return 0;
}


- (NSUInteger)p_numberOfRowsInSection:(NSUInteger)section
{
    if ([self.tableViewDataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)])
    {
        return [self.tableViewDataSource tableView:self numberOfRowsInSection:section];
    }
    
    return 0;
}


- (NSUInteger)p_numberOfRowsInOutlineView
{
    NSUInteger sectionCount = [self.outlineViewItems count];
    NSUInteger rowCount = 0;
    
    for (NSUInteger section = 0; section < sectionCount; section++)
    {
        rowCount += [self.outlineViewItems[section] count];
    }
    
    return (sectionCount + rowCount); // Section headers count as rows even if they are not "visible"
}


- (NSUInteger)p_numberOfOutlineViewItemsForOutlineViewParentItem:(GNEOutlineViewParentItem *)parentItem
{
    NSParameterAssert([parentItem isKindOfClass:[GNEOutlineViewParentItem class]]);
    
    NSUInteger parentItemIndex = parentItem.indexPath.gne_section;
    
    NSParameterAssert(parentItemIndex != NSNotFound);
    NSParameterAssert(parentItemIndex < [self.outlineViewItems count]);
    
    return [self.outlineViewItems[parentItemIndex] count];
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Internal - Debug Checks
// ------------------------------------------------------------------------------------------
#ifdef DEBUG
- (void)p_checkIndexPathsArray:(NSArray *)indexPaths
{
    for (NSIndexPath *indexPath in indexPaths)
    {
        NSParameterAssert([indexPath isKindOfClass:[NSIndexPath class]] && [indexPath length] == 2);
    }
}
#else
- (void)p_checkIndexPathsArray:(NSArray * __unused)indexPaths
{
    
}
#endif


// ------------------------------------------------------------------------------------------
#pragma mark - NSOutlineView - Reloading Data
// ------------------------------------------------------------------------------------------
// TODO: Perhaps nil out outline view item arrays, -[super reloadData], rebuild arrays, -[super reloadData]
- (void)reloadData
{
    
    __weak typeof(self) weakSelf = self;
    [self performAfterAnimations:^(NSOutlineView *__weak ov __unused)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil)
        {
            return;
        }
        
        [strongSelf.outlineViewParentItems removeAllObjects];
        [strongSelf.outlineViewItems removeAllObjects];
        
        [strongSelf p_buildOutlineViewItemArrays];
        
        [super reloadData];
        [strongSelf expandItem:nil expandChildren:YES];
    }];
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSOutlineView - Cell Frames
// ------------------------------------------------------------------------------------------
- (NSRect)frameOfOutlineCellAtRow:(NSInteger __unused)row
{
    return CGRectZero;
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSOutlineViewDataSource - Required
// ------------------------------------------------------------------------------------------
- (NSInteger)numberOfRowsInOutlineView:(NSOutlineView * __unused)outlineView
{
    return (NSInteger)[self p_numberOfRowsInOutlineView];
}


- (id)outlineView:(NSOutlineView * __unused)outlineView
            child:(NSInteger)index
           ofItem:(GNEOutlineViewParentItem *)parentItem
{
    NSParameterAssert(parentItem == nil || [parentItem isKindOfClass:[GNEOutlineViewParentItem class]]);
    
    return [self p_outlineViewItemAtIndex:(NSUInteger)index ofParent:parentItem];
}


- (BOOL)outlineView:(NSOutlineView * __unused)outlineView isItemExpandable:(GNEOutlineViewItem *)item
{
    NSParameterAssert(item == nil || [item isKindOfClass:[GNEOutlineViewItem class]]);
    
    if (item)
    {
        if ([item isKindOfClass:[GNEOutlineViewParentItem class]])
        {
            return YES; // Parent items should always be expandable.
        }
        else
        {
            return NO; // Child items should never be expandable.
        }
    }
    
    return YES; // Root item is always expandable
}


- (NSInteger)outlineView:(NSOutlineView * __unused)outlineView numberOfChildrenOfItem:(GNEOutlineViewItem *)item
{
    NSParameterAssert(item == nil || [item isKindOfClass:[GNEOutlineViewItem class]]);
    
    if (item)
    {
        if ([item isKindOfClass:[GNEOutlineViewParentItem class]])
        {
            return (NSInteger)[self p_numberOfOutlineViewItemsForOutlineViewParentItem:(GNEOutlineViewParentItem *)item];
        }
        else // Child objects cannot have children (they are too young!!!).
        {
            return 0;
        }
    }
    
    return (NSInteger)[self.outlineViewParentItems count]; // root item has all of the parent items (sections) as children.
}


-           (id)outlineView:(NSOutlineView * __unused)outlineView
  objectValueForTableColumn:(NSTableColumn * __unused)tableColumn
                     byItem:(GNEOutlineViewItem *)item
{
    NSParameterAssert(item == nil || [item isKindOfClass:[GNEOutlineViewItem class]]);
    
    return item;
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSOutlineViewDelegate - View Size and Appearance
// ------------------------------------------------------------------------------------------
- (CGFloat)outlineView:(NSOutlineView * __unused)outlineView heightOfRowByItem:(GNEOutlineViewItem *)item
{
    NSParameterAssert([item isKindOfClass:[GNEOutlineViewItem class]]);
    
    // Section header
    if (item.parentItem == nil)
    {
        if ([self p_outlineViewParentItemIsVisibleForSection:item.indexPath.gne_section])
        {
            return [self.tableViewDelegate tableView:self heightForHeaderInSection:item.indexPath.gne_section];
        }
        
        return kInvisibleRowHeight;
    }
    
    // Row
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)])
    {
        return [self.tableViewDelegate tableView:self heightForRowAtIndexPath:item.indexPath];
    }
    
    return kDefaultRowHeight;
}


- (BOOL)outlineView:(NSOutlineView * __unused)outlineView isGroupItem:(GNEOutlineViewItem *)item
{
    NSParameterAssert(item == nil || [item isKindOfClass:[GNEOutlineViewItem class]]);
    
    return NO;
}


- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(GNEOutlineViewItem *)item
{
    NSParameterAssert(item == nil || [item isKindOfClass:[GNEOutlineViewItem class]]);
    NSParameterAssert([self.tableViewDataSource respondsToSelector:@selector(tableView:rowViewForRowAtIndexPath:)]);
    
    // Section header
    if (item.parentItem == nil)
    {
        if ([self.tableViewDelegate respondsToSelector:@selector(tableView:rowViewForHeaderInSection:)])
        {
            return [self.tableViewDelegate tableView:self rowViewForHeaderInSection:item.indexPath.gne_section];
        }
        else
        {
            NSTableRowView *rowView = [outlineView makeViewWithIdentifier:kOutlineViewStandardHeaderRowViewIdentifier
                                                                    owner:outlineView];
            
            if (rowView == nil)
            {
                rowView = [[NSTableRowView alloc] initWithFrame:CGRectZero];
                [rowView setAutoresizingMask:NSViewWidthSizable];
                rowView.identifier = kOutlineViewStandardHeaderRowViewIdentifier;
                rowView.backgroundColor = [NSColor clearColor];
            }
            
            return rowView;
        }
    }
    
    // Row
    return [self.tableViewDataSource tableView:self rowViewForRowAtIndexPath:item.indexPath];
}


- (NSView *)outlineView:(NSOutlineView * __unused)outlineView
     viewForTableColumn:(NSTableColumn * __unused)tableColumn
                   item:(GNEOutlineViewItem *)item
{
    NSParameterAssert(item == nil || [item isKindOfClass:[GNEOutlineViewItem class]]);
    NSParameterAssert([self.tableViewDataSource respondsToSelector:@selector(tableView:cellViewForRowAtIndexPath:)]);
    
    // Section header
    if (item.parentItem == nil)
    {
        if ([self.tableViewDelegate respondsToSelector:@selector(tableView:cellViewForHeaderInSection:)])
        {
            return [self.tableViewDelegate tableView:self cellViewForHeaderInSection:item.indexPath.gne_section];
        }
    }
    
    // Row
    return [self.tableViewDataSource tableView:self cellViewForRowAtIndexPath:item.indexPath];
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSOutlineViewDelegate - Selection
// ------------------------------------------------------------------------------------------
- (BOOL)outlineView:(NSOutlineView * __unused)outlineView shouldSelectItem:(GNEOutlineViewItem *)item
{
    NSParameterAssert(item == nil || [item isKindOfClass:[GNEOutlineViewItem class]]);
    
    // Don't allow the selection of the root object (not that it is even possible).
    if (item == nil)
    {
        return NO;
    }
    
    // Don't allow the selection of section headers.
    if (item.parentItem == nil)
    {
        return NO;
    }
    
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:shouldSelectRowAtIndexPath:)])
    {
        return [self.tableViewDelegate tableView:self shouldSelectRowAtIndexPath:item.indexPath];
    }
    
    return YES;
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSOutlineView - Table Columns
// ------------------------------------------------------------------------------------------
- (void)p_sizeStandardTableColumnToFit
{
    NSTableColumn *standardColumn = nil;
    if ((standardColumn = [self tableColumnWithIdentifier:kOutlineViewStandardColumnIdentifier]))
    {
        [standardColumn setWidth:ceil([self frame].size.width)];
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Accessors
// ------------------------------------------------------------------------------------------
- (void)setTableViewDataSource:(id<GNESectionedTableViewDataSource>)tableViewDataSource
{
    NSParameterAssert(tableViewDataSource == nil ||
                      [tableViewDataSource conformsToProtocol:@protocol(GNESectionedTableViewDataSource)]);
    
    if (_tableViewDataSource != tableViewDataSource)
    {
        _tableViewDataSource = tableViewDataSource;
        
        [self reloadData];
        [self expandItem:nil expandChildren:YES];
    }
}


- (void)setTableViewDelegate:(id<GNESectionedTableViewDelegate>)tableViewDelegate
{
    NSParameterAssert(tableViewDelegate == nil ||
                      [tableViewDelegate conformsToProtocol:@protocol(GNESectionedTableViewDelegate)]);
    
    if (_tableViewDelegate != tableViewDelegate)
    {
        _tableViewDelegate = tableViewDelegate;
        
        [self reloadData];
        [self expandItem:nil expandChildren:YES];
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSOutlineView - Accessors
// ------------------------------------------------------------------------------------------
- (id <NSOutlineViewDataSource>)dataSource
{
    return self;
}


- (void)setDataSource:(id<NSOutlineViewDataSource> __unused)aSource
{
    [super setDataSource:self];
}


- (id <NSOutlineViewDelegate>)delegate
{
    return self;
}


- (void)setDelegate:(id<NSOutlineViewDelegate> __unused)anObject
{
    [super setDelegate:self];
}



@end
