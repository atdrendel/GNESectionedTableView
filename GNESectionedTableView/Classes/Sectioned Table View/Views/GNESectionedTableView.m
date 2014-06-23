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
#ifdef DEBUG
    NSLog(@"%@\n%@", NSStringFromSelector(_cmd), indexPaths);
#endif
    
    [self p_checkIndexPathsArray:indexPaths];
    
    NSArray *groupedIndexPaths = [self p_sortedIndexPathsGroupedBySectionInIndexPaths:indexPaths];
    
    [self beginUpdates];
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
    [self endUpdates];
    
    [self p_checkDataSourceIntegrity];
}


- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withAnimation:(NSTableViewAnimationOptions)animationOptions
{
#ifdef DEBUG
    NSLog(@"%@\n%@", NSStringFromSelector(_cmd), indexPaths);
#endif
    
    [self p_checkIndexPathsArray:indexPaths];
    
    NSArray *groupedIndexPaths = [self p_sortedIndexPathsGroupedBySectionInIndexPaths:indexPaths];
    
    NSIndexPath *firstIndexPath = [self p_firstIndexPathInSortedAndGroupedIndexPaths:groupedIndexPaths];
    NSUInteger firstSection = (firstIndexPath) ? firstIndexPath.gne_section : 0;
    
    [self beginUpdates];
    for (NSArray *indexPathsInSection in groupedIndexPaths)
    {
        
        firstIndexPath = [indexPathsInSection firstObject];
        
        if (firstIndexPath == nil)
        {
            continue;
        }
        
        GNEOutlineViewItem *firstItem = [self p_outlineViewItemWithIndexPath:firstIndexPath];
        
        if (firstItem == nil)
        {
            continue;
        }
        
        GNEOutlineViewParentItem *parentItem = firstItem.parentItem;
        
        NSParameterAssert(parentItem);
        
        NSMutableIndexSet *deletedIndexes = [NSMutableIndexSet indexSet];
        for (NSIndexPath *indexPath in indexPathsInSection)
        {
            GNEOutlineViewItem *item = [self p_outlineViewItemWithIndexPath:indexPath];
            
            if (item == nil)
            {
                continue;
            }
            
            NSParameterAssert([item.parentItem isEqual:parentItem]);
            
            NSIndexPath *actualIndexPath = [self p_indexPathInOutlineViewItemsArrayOfOutlineViewItem:item];
            
            NSParameterAssert(actualIndexPath);
            
            // Add the item's index path row to the index set that will be passed to the NSOutlineView.
            [deletedIndexes addIndex:item.indexPath.gne_row];
            
            NSParameterAssert(actualIndexPath.gne_section < [self.outlineViewItems count]);
            NSParameterAssert(actualIndexPath.gne_row < [self.outlineViewItems[actualIndexPath.gne_section] count]);
            
            // Delete the actual item from the outline view items array.
            [self.outlineViewItems[actualIndexPath.gne_section] removeObjectAtIndex:actualIndexPath.gne_row];
        }
        
        // Delete the outline view rows with the supplied animation.
        [self removeItemsAtIndexes:deletedIndexes inParent:parentItem withAnimation:animationOptions];
    }
    [self endUpdates];
    
    [self p_updateIndexPathsForOutlineViewItemsBeginningAtSection:firstSection];
    
    [self p_checkDataSourceIntegrity];
}


- (void)moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSParameterAssert(fromIndexPath);
    NSParameterAssert(toIndexPath);
    
    NSUInteger toSection = toIndexPath.gne_section;
    
    GNEOutlineViewParentItem *toParentItem = [self p_outlineViewParentItemForSection:toSection];
    
    NSParameterAssert(toParentItem);
    if (toParentItem == nil)
    {
        return;
    }
    
    GNEOutlineViewItem *fromItem = [self p_outlineViewItemWithIndexPath:fromIndexPath];
    
    NSParameterAssert(fromItem);
    if (fromItem == nil)
    {
        return;
    }
    
    [self p_animateMoveOfOutlineViewItem:fromItem toRow:toIndexPath.gne_row inOutlineViewParentItem:toParentItem];
    
    [self p_checkDataSourceIntegrity];
}


- (void)moveRowsAtIndexPaths:(NSArray *)fromIndexPaths toIndexPaths:(NSArray *)toIndexPaths
{
    NSParameterAssert([fromIndexPaths count] == [toIndexPaths count]);
    
    [self p_checkIndexPathsArray:fromIndexPaths];
    [self p_checkIndexPathsArray:toIndexPaths];
    
    NSUInteger moveCount = [fromIndexPaths count];
    
    [self beginUpdates];
    for (NSUInteger i = 0; i < moveCount; i++)
    {
        NSIndexPath *fromIndexPath = fromIndexPaths[i];
        NSIndexPath *toIndexPath = toIndexPaths[i];
        
        if ([fromIndexPath compare:toIndexPath] == NSOrderedSame)
        {
            continue;
        }
        
        [self moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
    }
    [self endUpdates];
    
    [self p_checkDataSourceIntegrity];
}


- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths
{
#ifdef DEBUG
    NSLog(@"%@\n%@", NSStringFromSelector(_cmd), indexPaths);
#endif
    
    [self p_checkIndexPathsArray:indexPaths];
    
    NSArray *groupedIndexPaths = [self p_sortedIndexPathsGroupedBySectionInIndexPaths:indexPaths];
    
    [self beginUpdates];
    for (NSArray *indexPathsInSection in groupedIndexPaths)
    {
        for (NSIndexPath *indexPath in indexPathsInSection)
        {
            GNEOutlineViewItem *item = [self p_outlineViewItemWithIndexPath:indexPath];
            
            if (item == nil)
            {
                continue;
            }
            
            [self reloadItem:item];
        }
    }
    [self endUpdates];
    
    [self p_checkDataSourceIntegrity];
}


- (void)insertSections:(NSIndexSet *)sections withAnimation:(NSTableViewAnimationOptions)animationOptions
{
#ifdef DEBUG
    NSLog(@"%@\n%@", NSStringFromSelector(_cmd), sections);
#endif
    
    NSParameterAssert([self.tableViewDataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]);
    
    NSMutableIndexSet *insertedSections = [NSMutableIndexSet indexSet];
    
    NSMutableArray *outlineViewParentItemsCopy = [NSMutableArray arrayWithArray:self.outlineViewParentItems];
    NSMutableArray *outlineViewItemsCopy = [NSMutableArray arrayWithArray:self.outlineViewItems];
    
    [sections enumerateIndexesUsingBlock:^(NSUInteger proposedSection, BOOL *stop __unused)
    {
        @autoreleasepool
        {
            NSUInteger sectionCount = [outlineViewParentItemsCopy count];
            NSUInteger section = (proposedSection > sectionCount) ? sectionCount : proposedSection;
            
            NSIndexPath *parentItemIndexPath = [NSIndexPath gne_indexPathForRow:NSNotFound inSection:section];
            GNEOutlineViewParentItem *parentItem = [[GNEOutlineViewParentItem alloc]
                                                    initWithIndexPath:parentItemIndexPath];
            parentItem.visible = [self p_outlineViewParentItemIsVisibleForSection:section];
            [outlineViewParentItemsCopy gne_insertObject:parentItem atIndex:section];
            
            NSMutableArray *rows = [NSMutableArray array];
            [outlineViewItemsCopy gne_insertObject:rows atIndex:section];
            
            NSUInteger rowCount = [self.tableViewDataSource tableView:self numberOfRowsInSection:section];
            
            for (NSUInteger row = 0; row < rowCount; row++)
            {
                NSIndexPath *indexPath = [NSIndexPath gne_indexPathForRow:row inSection:section];
                GNEOutlineViewItem *item = [[GNEOutlineViewItem alloc] initWithIndexPath:indexPath
                                                                              parentItem:parentItem];
                
                [rows addObject:item];
            }
            
            [insertedSections addIndex:section];
        }
    }];
    
    NSParameterAssert([sections count] == [insertedSections count]);
    
    self.outlineViewParentItems = outlineViewParentItemsCopy;
    self.outlineViewItems = outlineViewItemsCopy;
    
    [self p_updateIndexPathsForOutlineViewItemsBeginningAtSection:[insertedSections firstIndex]];
    [self insertItemsAtIndexes:insertedSections inParent:nil withAnimation:animationOptions];
    [self p_expandParentItemsAtIndexes:insertedSections];
    
    [self p_checkDataSourceIntegrity];
}


- (void)deleteSections:(NSIndexSet *)sections withAnimation:(NSTableViewAnimationOptions)animationOptions
{
#ifdef DEBUG
    NSLog(@"%@\n%@", NSStringFromSelector(_cmd), sections);
#endif
    
    NSMutableArray *outlineViewParentItemsCopy = [NSMutableArray arrayWithArray:self.outlineViewParentItems];
    NSMutableArray *outlineViewItemsCopy = [NSMutableArray arrayWithArray:self.outlineViewItems];
    
    NSMutableIndexSet *deletedSections = [NSMutableIndexSet indexSet];
    [sections enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger section, BOOL *stop __unused)
    {
        GNEOutlineViewParentItem *parentItem = [self p_outlineViewParentItemForSection:section];
        
        if (parentItem)
        {
            NSUInteger index = [self p_indexInOutlineViewParentItemsArrayOfOutlineViewParentItem:parentItem];
            
            if (index != NSNotFound)
            {
                NSParameterAssert([deletedSections containsIndex:index] == NO);
                
                [deletedSections addIndex:index];
                
                NSParameterAssert(index < [outlineViewParentItemsCopy count]);
                NSParameterAssert(index < [outlineViewItemsCopy count]);
                
                [outlineViewParentItemsCopy removeObjectAtIndex:index];
                [outlineViewItemsCopy removeObjectAtIndex:index];
            }
        }
    }];
    
    NSParameterAssert([sections count] == [deletedSections count]);
    
    self.outlineViewParentItems = outlineViewParentItemsCopy;
    self.outlineViewItems = outlineViewItemsCopy;
    
    [self p_updateIndexPathsForOutlineViewItemsBeginningAtSection:[deletedSections firstIndex]];
    [self removeItemsAtIndexes:deletedSections inParent:nil withAnimation:animationOptions];
    
    [self p_checkDataSourceIntegrity];
}


- (void)moveSection:(NSUInteger)fromSection toSection:(NSUInteger)toSection
{
    [self moveSections:[NSIndexSet indexSetWithIndex:fromSection] toSection:toSection];
}


- (void)moveSections:(NSIndexSet *)fromSections toSection:(NSUInteger)toSection
{
#ifdef DEBUG
    NSLog(@"%@\nFrom: %@ To: %lu", NSStringFromSelector(_cmd), fromSections, toSection);
#endif
    
    NSParameterAssert([self.outlineViewParentItems count] == [self.outlineViewItems count]);
    
    NSMutableIndexSet *validSections = [[self p_indexSetByRemovingInvalidSectionsFromIndexSet:fromSections]
                                        mutableCopy];
    
    /**
     If the target section is the first section in the fromSections parameter, remove it and insert all of the
        other sections above it.
     */
    while ([validSections firstIndex] == toSection)
    {
        [validSections removeIndex:toSection];
        toSection += 1;
    }
    
    __block NSUInteger sectionsAbove = 0;
    __block NSUInteger sectionsBelow = 0;
    
    /**
     If the target section is contained in the fromSections parameter, remove it, insert the sections greater than
        it above it, and insert all of the sections less than it below it. 
     */
    if ([validSections containsIndex:toSection])
    {
        [validSections removeIndex:toSection];
        toSection += 1;
        sectionsBelow += 1;
    }
    
    [self beginUpdates];
    [validSections enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger fromSection,
                                                                                 BOOL *stop __unused)
    {
        // Set defaults.
        NSUInteger convertedFromSection = fromSection;
        NSUInteger convertedToSection = toSection;
        
        if (fromSection > toSection)
        {
            sectionsAbove += 1;
            convertedFromSection = fromSection + (sectionsAbove - 1);
        }
        else if (fromSection < toSection)
        {
            sectionsBelow += 1;
            convertedToSection = toSection - sectionsBelow;
        }
        
        GNEOutlineViewParentItem *parentItem = [self p_outlineViewParentItemForSection:convertedFromSection];
        NSUInteger parentItemIndex = [self p_indexInOutlineViewParentItemsArrayOfOutlineViewParentItem:parentItem];
        
        NSUInteger smallestSection = (parentItemIndex < convertedToSection) ? parentItemIndex : convertedToSection;
        
        NSParameterAssert(parentItemIndex != NSNotFound && parentItemIndex < [self.outlineViewItems count]);
        
        if (parentItemIndex == NSNotFound || parentItemIndex >= [self.outlineViewItems count])
        {
            return;
        }
        
        NSMutableArray *rows = self.outlineViewItems[parentItemIndex];
        
        [self.outlineViewParentItems removeObjectAtIndex:parentItemIndex];
        [self.outlineViewItems removeObjectAtIndex:parentItemIndex];
        
        [self.outlineViewParentItems gne_insertObject:parentItem atIndex:convertedToSection];
        [self.outlineViewItems gne_insertObject:rows atIndex:convertedToSection];
        
        /**
         The index paths must be updated before the animation happens because the views for sections that aren't
            already visible will need to be created, which means the data source (which has already changed) will
            need to be queried.
         */
        [self p_updateIndexPathsForOutlineViewItemsBeginningAtSection:smallestSection];
        
        [self moveItemAtIndex:(NSInteger)parentItemIndex
                     inParent:nil
                      toIndex:(NSInteger)convertedToSection
                     inParent:nil];
    }];
    [self endUpdates];
    
    [self p_checkDataSourceIntegrity];
}


- (void)reloadSections:(NSIndexSet *)sections
{
#ifdef DEBUG
    NSLog(@"%@\n%@", NSStringFromSelector(_cmd), sections);
#endif
    
    NSParameterAssert([self.outlineViewParentItems count] == [self.outlineViewItems count]);
    
    NSUInteger sectionCount = [self.outlineViewParentItems count];
    
    [self beginUpdates];
    [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop __unused)
    {
        GNEOutlineViewParentItem *parentItem = nil;
        if (section < sectionCount && (parentItem = [self p_outlineViewParentItemForSection:section]))
        {
            [self reloadItem:parentItem reloadChildren:YES];
        }
    }];
    [self endUpdates];
    
    [self p_checkDataSourceIntegrity];
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
 Animates the move of the specified outline view item to the specified row in its current parent.
 
 @param item Outline view item to move.
 @param toRow Row index to move the outline view item to.
 */
- (void)p_animateMoveOfOutlineViewItem:(GNEOutlineViewItem *)item toRow:(NSUInteger)toRow
{
    NSParameterAssert(item);
    
    GNEOutlineViewParentItem *parentItem = item.parentItem;
    
    NSUInteger section = [self p_indexInOutlineViewParentItemsArrayOfOutlineViewParentItem:parentItem];

    NSParameterAssert(section != NSNotFound);
    if (section == NSNotFound)
    {
        return;
    }
    
    NSIndexPath *fromIndexPath = [self p_indexPathInOutlineViewItemsArrayOfOutlineViewItem:item];
    
    NSParameterAssert(fromIndexPath);
    if (fromIndexPath == nil)
    {
        return;
    }
    
    NSUInteger fromSection = fromIndexPath.gne_section;
    NSUInteger fromRow = fromIndexPath.gne_row;
    
    toRow = (fromRow < toRow) ? (toRow - 1) : toRow;
    
    [self.outlineViewItems[fromSection] removeObjectAtIndex:fromRow];
    [self.outlineViewItems[fromSection] gne_insertObject:item atIndex:toRow];
    
    [self p_updateIndexPathsForOutlineViewItemsInSection:fromSection];
    
    [self moveItemAtIndex:(NSInteger)fromRow
                 inParent:parentItem
                  toIndex:(NSInteger)toRow
                 inParent:parentItem];
}


/**
 Animates the move of the specified outline view item to the specified row in the specified outline view parent item.
 
 @param item Outline view item to move.
 @param toRow Row index to move the outline view item to.
 @param toParentItem Outline view parent item to move the specified outline view item to.
 */
- (void)p_animateMoveOfOutlineViewItem:(GNEOutlineViewItem *)item
                                 toRow:(NSUInteger)toRow
               inOutlineViewParentItem:(GNEOutlineViewParentItem *)toParentItem
{
    NSParameterAssert(item);
    NSParameterAssert(toParentItem);
    
    GNEOutlineViewParentItem *fromParentItem = item.parentItem;
    
    if ([fromParentItem isEqual:toParentItem])
    {
        [self p_animateMoveOfOutlineViewItem:item toRow:toRow];
    }
    
    NSIndexPath *actualIndexPath = [self p_indexPathInOutlineViewItemsArrayOfOutlineViewItem:item];
    NSUInteger toSection = [self p_indexInOutlineViewParentItemsArrayOfOutlineViewParentItem:toParentItem];
    
    NSParameterAssert(actualIndexPath);
    NSParameterAssert(toSection != NSNotFound);
    if (actualIndexPath == nil || toSection == NSNotFound)
    {
        return;
    }
    
    NSUInteger fromSection = actualIndexPath.gne_section;
    NSUInteger fromRow = actualIndexPath.gne_row;
    
    [self.outlineViewItems[fromSection] removeObjectAtIndex:fromRow];
    
    item.parentItem = toParentItem;
    
    [(NSMutableArray *)self.outlineViewItems[toSection] gne_insertObject:item atIndex:toRow];
    
    NSUInteger smallestSection = (fromSection < toSection) ? fromSection : toSection;
    
    [self p_updateIndexPathsForOutlineViewItemsBeginningAtSection:smallestSection];
    
    [self moveItemAtIndex:(NSInteger)fromRow
                 inParent:fromParentItem
                  toIndex:(NSInteger)toRow
                 inParent:toParentItem];
}


- (void)p_updateIndexPathsForOutlineViewItemsBeginningAtSection:(NSUInteger)section
{
    NSParameterAssert([self.outlineViewParentItems count] == [self.outlineViewItems count]);
    
    if (section >= [self.outlineViewItems count])
    {
        return;
    }
    
    NSUInteger sectionCount = [self.outlineViewParentItems count];
    
    for (; section < sectionCount; section++)
    {
        GNEOutlineViewParentItem *parentItem = self.outlineViewParentItems[section];
        parentItem.indexPath = [NSIndexPath gne_indexPathForRow:NSNotFound inSection:section];
        
        NSMutableArray *rows = self.outlineViewItems[section];
        NSUInteger rowCount = [rows count];
        for (NSUInteger row = 0; row < rowCount; row++)
        {
            GNEOutlineViewItem *item = rows[row];
            item.indexPath = [NSIndexPath gne_indexPathForRow:row inSection:section];
        }
    }
}


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


/**
 Returns the first index path contained in a sorted and grouped array of arrays of index paths.
 
 @discussion This method should be used on the array returned by p_sortedIndexPathsGroupedBySectionInIndexPaths:.
 @param groupedIndexPaths Array of arrays of index paths that have already been sorted.
 @return First index path in the specified sorted and grouped array of arrays of index paths.
 */
- (NSIndexPath *)p_firstIndexPathInSortedAndGroupedIndexPaths:(NSArray *)groupedIndexPaths
{
    NSParameterAssert(groupedIndexPaths == nil ||
                      [groupedIndexPaths count] == 0 ||
                      [[groupedIndexPaths firstObject] isKindOfClass:[NSArray class]]);
    
    if (groupedIndexPaths == nil || [groupedIndexPaths count] == 0)
    {
        return nil;
    }
    
    return [[groupedIndexPaths firstObject] firstObject];
}


/**
 Returns an index set that contains all of the valid section indexes in the specified index set.
 
 @param sections Index set containing indexes corresponding to outline view parent items in the outline view parent
                    items array.
 @return Index set containing all of the valid section indexes in the specified index set.
 */
- (NSIndexSet *)p_indexSetByRemovingInvalidSectionsFromIndexSet:(NSIndexSet *)sections
{
    NSParameterAssert([self.outlineViewParentItems count] == [self.outlineViewItems count]);
    
    if ([sections count] == 0)
    {
        return sections;
    }
    
    NSMutableIndexSet *validSections = [NSMutableIndexSet indexSet];
    [validSections addIndexes:sections];
    
    NSUInteger sectionCount = [self.outlineViewParentItems count];
    
    [sections enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger section, BOOL *stop)
    {
        if (section < sectionCount)
        {
            *stop = YES;
        }
        else
        {
            [validSections removeIndex:section];
        }
    }];
    
    return validSections;
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Internal - Retrieving Outline View Items
// ------------------------------------------------------------------------------------------
/**
 Returns the index pointing to the specified outline view parent item in the outline view parent items array,
    even if that index does not match the section of the index path property of the specified outline view
    item itself. If the outline view parent item could not be found, returns NSNotFound.
 
 @discussion Because of insertions and deletions, for brief moments the section of the index path property of an
                outline view parent item may not match its current location within the GNESectionedTableView's
                outline view parent items array. This method returns the actual index of the specified outline
                view parent item. If the outline view parent item could not be found, this method
                returns NSNotFound.
 @param parentItem Outline view parent item to locate.
 @return Index matching the current location of the specified outline view parent item in table view's outline
            view parent items array, or NSNotFound if the outline view parent item could not be found.
 */
- (NSUInteger)p_indexInOutlineViewParentItemsArrayOfOutlineViewParentItem:(GNEOutlineViewParentItem *)parentItem
{
    NSUInteger count = [self.outlineViewParentItems count];
    
    if (parentItem.indexPath.gne_section < count)
    {
        NSUInteger section = parentItem.indexPath.gne_section;
        GNEOutlineViewParentItem *aParentItem = [self.outlineViewParentItems objectAtIndex:section];
        
        if ([aParentItem isEqual:parentItem])
        {
            return section;
        }
    }
    
    for (NSUInteger i = 0; i < count; i++)
    {
        GNEOutlineViewParentItem *aParentItem = [self.outlineViewParentItems objectAtIndex:i];
        
        if ([aParentItem isEqual:parentItem])
        {
            return i;
        }
    }
    
    return NSNotFound;
}


/**
 Returns the index path pointing to the specified outline view item in the outline view items array, even if that
    index path does not match the index path property of the specified outline view item itself.
 
 @discussion Because of insertions and deletions, for brief moments the index path property of an outline view
                item may not match its current location within the GNESectionedTableView's outline view items
                array. This method returns the actual location of the specified outline view item.
 @param item Outline view item to locate.
 @return Index path matching the current location of the specified outline view item in table view's outline view
            items array, or nil if it couldn't be found.
 */
- (NSIndexPath *)p_indexPathInOutlineViewItemsArrayOfOutlineViewItem:(GNEOutlineViewItem *)item
{
    NSUInteger sectionCount = [self.outlineViewItems count];
    
    NSUInteger section = item.indexPath.gne_section;
    
    if (section < sectionCount)
    {
        NSArray *sectionArray = self.outlineViewItems[section];
        
        // First check the outline view item's index path.
        if (item.indexPath.gne_row < [sectionArray count] && [item isEqual:sectionArray[item.indexPath.gne_row]])
        {
            return [NSIndexPath gne_indexPathForRow:item.indexPath.gne_row inSection:section];
        }
        
        // If it wasn't found, iterate through the section to find the item.
        NSUInteger row = [sectionArray indexOfObject:item];
        if (row != NSNotFound)
        {
            return [NSIndexPath gne_indexPathForRow:row inSection:section];
        }
    }
    
    // If it still wasn't found, iterate through all of the sections.
    for (section = 0; section < sectionCount; section++)
    {
        NSArray *sectionArray = self.outlineViewItems[section];
        NSUInteger row = [sectionArray indexOfObject:item];
        if (row != NSNotFound)
        {
            return [NSIndexPath gne_indexPathForRow:row inSection:section];
        }
    }
    
    return nil;
}


/**
 Returns the outline view item or outline view parent item located at the specified index in the outline view
    items array or outline view parent items array, or nil if the item couldn't be found.
 
 @discussion Returns an outline view item if parentItem is not nil, otherwise returns an outline view parent item.
 @param index Index of the desired outline view item or parent item.
 @param parentItem Outline view parent item for the desired outline view item or nil if searching for an outline
            view parent item.
 @return Outline view item or outline view parent item located at the specified index of the specified parent.
 */
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
 Returns the outline view item or parent item whose index path property matches the specified index path.
 
 @discussion This method first tries to match the outline view parent item at the specified index path. If that
                outline view parent item doesn't match, it iterates through all of the outline view items
                in the specified section until a match is found. If a match still can't be found, it iterates
                through all of the outline view items until it finds a match.
 @param indexPath Index path to use to find a matching outline view item.
 @return Outline view item whose index path property matches the specified index path, otherwise nil.
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
 Returns the outline view parent item whose index path property's section matches the specified section.
 
 @discussion This method first tries to match the outline view parent item at the specified index path. If that
                outline view parent item doesn't match, it iterates through all of the outline view parent
                items until a match is found.
 @param section Section to use to find a matching outline view parent item.
 @return Outline view parent item whose index path property's section matches the specified section, otherwise nil.
 */
- (GNEOutlineViewParentItem *)p_outlineViewParentItemForSection:(NSUInteger)section
{
    NSIndexPath *indexPath = [NSIndexPath gne_indexPathForRow:NSNotFound inSection:section];
    
    return [self p_outlineViewParentItemWithIndexPath:indexPath];
}


/**
 Returns the outline view parent item whose index path property matches the specified index path.
 
 @discussion This method first tries to match the outline view parent item at the specified index path. If that
                outline view parent item doesn't match, it iterates through all of the outline view parent
                items until a match is found.
 @param indexPath Index path to use to find a matching outline view parent item.
 @return Outline view parent item whose index path property matches the specified index path, otherwise nil.
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
#pragma mark - GNESectionedTableView - Internal - Expand/Collapse Parent Items
// ------------------------------------------------------------------------------------------
- (void)p_expandParentItemsAtIndexes:(NSIndexSet *)indexSet
{
    NSUInteger count = [self.outlineViewParentItems count];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop __unused)
    {
        if (index < count)
        {
            GNEOutlineViewParentItem *parentItem = self.outlineViewParentItems[index];
            [self expandItem:parentItem];
        }
    }];
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
- (void)p_checkDataSourceIntegrity
{
    id dataSource = (id)self.tableViewDataSource;
    
    SEL numberOfSectionsSelector = NSSelectorFromString(@"numberOfSections");
    SEL numberOfRowsSelector = NSSelectorFromString(@"numberOfRows");
    
    NSParameterAssert([dataSource respondsToSelector:numberOfSectionsSelector]);
    NSParameterAssert([dataSource respondsToSelector:numberOfRowsSelector]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSUInteger numberOfSectionsInDataSource = (NSUInteger)[dataSource performSelector:numberOfSectionsSelector];
#pragma clang diagnostic pop
    NSUInteger numberOfSectionsInOutlineView = (NSUInteger)[self p_numberOfSections];
    
    NSParameterAssert(numberOfSectionsInDataSource == numberOfSectionsInOutlineView);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSUInteger numberOfRowsInDataSource = (NSUInteger)[dataSource performSelector:numberOfRowsSelector];
#pragma clang diagnostic pop
    NSUInteger numberOfRowsInOutlineView = [self p_numberOfRowsInOutlineView] - [self p_numberOfSections];
    
    NSParameterAssert(numberOfRowsInDataSource == numberOfRowsInOutlineView);
}
#else
- (void)p_checkDataSourceIntegrity
{
    
}
#endif


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
