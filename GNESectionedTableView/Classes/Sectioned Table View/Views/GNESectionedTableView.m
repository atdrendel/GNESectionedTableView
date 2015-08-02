//
//  GNESectionedTableView.m
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
#import "NSOutlineView+GNE_Additions.h"

#import "GNEOutlineViewItem.h"
#import "GNEOutlineViewParentItem.h"

#import "GNESectionedTableViewMove.h"
#import "GNESectionedTableViewMovingItem.h"

@import QuartzCore;

// ------------------------------------------------------------------------------------------


static NSString * const kOutlineViewStandardColumnIdentifier = @"com.goneeast.OutlineViewStandardColumn";

static NSString * const kOutlineViewStandardHeaderRowViewIdentifier =
                                                        @"com.goneeast.OutlineViewStandardHeaderRowViewIdentifier";
static NSString * const kOutlineViewStandardHeaderCellViewIdentifier =
                                                        @"com.goneeast.OutlineViewStandardHeaderCellViewIdentifier";

static const CGFloat kDefaultRowHeight = 32.0f;

static const NSUInteger kSectionHeaderRowModifier = 1;
static const NSUInteger kSectionFooterRowModifier = 2;

typedef NS_ENUM(NSUInteger, GNEDragType)
{
    GNEDragTypeBoth = 0,
    GNEDragTypeSections,
    GNEDragTypeRows
};


typedef NS_ENUM(NSUInteger, GNEDragLocation)
{
    GNEDragLocationTop = 0,
    GNEDragLocationBottom
};


// ------------------------------------------------------------------------------------------


@interface GNESectionedTableView () <NSOutlineViewDataSource, NSOutlineViewDelegate, GNEOutlineViewItemPasteboardWritingDelegate>


/// Array of outline view parent items that map to the table view's sections.
@property (nonatomic, strong) NSMutableArray *outlineViewParentItems;

/// Array of arrays of outline view items that map to the table view's rows.
@property (nonatomic, strong) NSMutableArray *outlineViewItems;

@property (nonatomic, strong) NSMutableArray *selectedAutoCollapsedIndexPaths;
@property (nonatomic, strong) NSMutableIndexSet *autoCollapsedSections;

@property (nonatomic, strong) NSMutableIndexSet *insertedSectionsToExpand;

@property (nonatomic, strong) NSMutableDictionary *rowViewToIndexPathMap;

/// Move that is initialized in -outlineView:draggingSession:willBeginAtPoint:forItems:
/// and cleared in -outlineView:draggingSession:endedAtPoint:operation:.
@property (nonatomic, strong) GNESectionedTableViewMove *currentMove;

/// Incremented in -beginUpdates and decremented in -endUpdates.
@property (atomic, assign) NSUInteger updateCount;

@end


// ------------------------------------------------------------------------------------------


@implementation GNESectionedTableView


// ------------------------------------------------------------------------------------------


@dynamic selectedIndexPath;
@dynamic selectedIndexPaths;


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self p_commonInitialization];
    }

    return self;
}


- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder]))
    {
        self.frame = CGRectZero;
        [self p_commonInitialization];
    }

    return self;
}


- (void)p_commonInitialization
{
    _outlineViewParentItems = [NSMutableArray array];
    _outlineViewItems = [NSMutableArray array];

    _autoExpandSections = YES;

    _selectedAutoCollapsedIndexPaths = [NSMutableArray array];
    _autoCollapsedSections = [NSMutableIndexSet indexSet];
    
    _insertedSectionsToExpand = [NSMutableIndexSet indexSet];
    
    _rowViewToIndexPathMap = [NSMutableDictionary dictionary];
    
    self.dataSource = self;
    self.delegate = self;
    
    self.wantsLayer = YES;
    self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
    
    self.gridStyleMask = NSTableViewGridNone;
    
    self.headerView = nil;
    self.cornerView = nil;
    
    self.outlineTableColumn = nil;
    self.autoresizesOutlineColumn = NO;
    self.indentationPerLevel = 0.0;
    self.indentationMarkerFollowsCell = NO;
    
    NSTableColumn *standardColumn = [[NSTableColumn alloc] initWithIdentifier:kOutlineViewStandardColumnIdentifier];
    standardColumn.resizingMask = NSTableColumnAutoresizingMask;
    [self addTableColumn:standardColumn];
    self.allowsColumnResizing = NO;
    
    self.columnAutoresizingStyle = NSTableViewSequentialColumnAutoresizingStyle;
    self.autoresizesOutlineColumn = NO;
    
    self.rowSizeStyle = NSTableViewRowSizeStyleCustom;
    
    self.action = @selector(p_didClickRow:);
    self.doubleAction = @selector(p_didDoubleClickRow:);
    
    [self expandItem:nil expandChildren:YES];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Dealloc
// ------------------------------------------------------------------------------------------
- (void)dealloc
{
    [_rowViewToIndexPathMap removeAllObjects];
    _rowViewToIndexPathMap = nil;
    
    _tableViewDataSource = nil;
    _tableViewDelegate = nil;
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSView
// ------------------------------------------------------------------------------------------
- (void)viewDidMoveToWindow
{
    if ([self window])
    {
        [self p_sizeStandardTableColumnToFit];
        [self p_registerForDraggedTypes];
    }
}


- (void)setFrameSize:(NSSize)newSize
{
    [super setFrameSize:newSize];
    [self p_sizeStandardTableColumnToFit];
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSOutlineView
// ------------------------------------------------------------------------------------------
- (void)reloadData
{
    __strong typeof(self) strongSelf = self;

    [super reloadData];

    [strongSelf selectRowIndexes:[NSIndexSet indexSet]
            byExtendingSelection:NO];
    
    [strongSelf.outlineViewParentItems removeAllObjects];
    [strongSelf.outlineViewItems removeAllObjects];
    [strongSelf p_buildOutlineViewItemArrays];
    
    [super reloadData];

    if (strongSelf.autoExpandSections)
    {
        [strongSelf expandAllSections:NO];
    }
}


/*
 -[NSOutlineView reloadItem:] is buggy and doesn't actually reload items that are more than
 one step away from root. This corresponds to our "rows" level. So, we have to force the reload
 using -[NSTableView reloadDataForRowIndexes:columnIndexes:].
 */
- (void)reloadItem:(id)item
{
    NSInteger tableViewRow = [self rowForItem:item];
    
    if (tableViewRow >= 0)
    {
        NSIndexSet *rowIndexes = [NSIndexSet indexSetWithIndex:(NSUInteger)tableViewRow];
        
        NSUInteger columnCount = (NSUInteger)self.numberOfColumns;
        NSRange columnRange = NSMakeRange(0, columnCount);
        NSIndexSet *columnIndexes = [NSIndexSet indexSetWithIndexesInRange:columnRange];
        
        [self reloadDataForRowIndexes:rowIndexes
                        columnIndexes:columnIndexes];
    }
}


- (void)beginUpdates
{
    self.updateCount++;
    [super beginUpdates];
}


- (void)endUpdates
{
    [super endUpdates];
    self.updateCount--;
    
    if (self.updateCount == 0)
    {
        [self expandSections:self.insertedSectionsToExpand animated:NO];
        [self.insertedSectionsToExpand removeAllIndexes];
        [self p_updateMapForAvailableRowViews];
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Public - Views
// ------------------------------------------------------------------------------------------
- (NSIndexPath * __nullable)indexPathForView:(NSView * __nullable)view
{
    NSInteger tableViewRow = [self rowForView:view];
    
    return [self indexPathForTableViewRow:tableViewRow];
}


- (NSTableCellView * __nullable)cellViewAtIndexPath:(NSIndexPath * __nullable)indexPath
{
    NSInteger tableViewRow = [self tableViewRowForIndexPath:indexPath];
    NSInteger columnCount = self.numberOfColumns;
    if (tableViewRow < 0 || columnCount < 1)
    {
        return nil;
    }
    
    NSTableCellView *cellView = [self viewAtColumn:0 row:tableViewRow makeIfNecessary:NO];
    
    return ([cellView isKindOfClass:[NSTableCellView class]]) ? cellView : nil;
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Public - Counts
// ------------------------------------------------------------------------------------------
- (NSUInteger)numberOfSections
{
    GNEParameterAssert(self.outlineViewParentItems.count == self.outlineViewItems.count);
    
    return self.outlineViewParentItems.count;
}


- (NSUInteger)numberOfRowsInSection:(NSUInteger)section
{
    GNEParameterAssert(section < self.outlineViewItems.count);
    
    if (section < self.outlineViewItems.count)
    {
        return ((NSArray *)self.outlineViewItems[section]).count;
    }
    
    return NSNotFound;
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Public - Index Paths / NSTableView Rows
// ------------------------------------------------------------------------------------------
- (BOOL)isIndexPathValid:(NSIndexPath * __nullable)indexPath
{
    if (indexPath == nil)
    {
        return NO;
    }
    
    NSUInteger sectionCount = self.outlineViewItems.count;
    if (indexPath.gne_section < sectionCount)
    {
        BOOL isSectionHeader = [self isIndexPathHeader:indexPath];
        BOOL isSectionFooter = [self isIndexPathFooter:indexPath];
        NSUInteger rowCount = ((NSArray *)self.outlineViewItems[indexPath.gne_section]).count;
        
        return (isSectionHeader || isSectionFooter || indexPath.gne_row < rowCount);
    }
    
    return NO;
}


- (BOOL)isIndexPathHeader:(NSIndexPath * __nullable)indexPath
{
    if (indexPath == nil)
    {
        return NO;
    }
    
    NSUInteger sectionCount = self.numberOfSections;
    
    NSUInteger section = indexPath.gne_section;
    NSUInteger row = indexPath.gne_row;
    NSUInteger headerRow = (NSUInteger)(NSNotFound - kSectionHeaderRowModifier);
    
    return (section < sectionCount && row == headerRow);
}


- (BOOL)isIndexPathFooter:(NSIndexPath * __nullable)indexPath
{
    if (indexPath == nil)
    {
        return NO;
    }
    
    NSUInteger sectionCount = self.numberOfSections;
    
    NSUInteger section = indexPath.gne_section;
    NSUInteger row = indexPath.gne_row;
    NSUInteger footerRow = (NSUInteger)(NSNotFound - kSectionFooterRowModifier);
    
    return (section < sectionCount && row == footerRow);
}


- (NSIndexPath * __nullable)indexPathForHeaderInSection:(NSUInteger)section
{
    NSUInteger sectionCount = self.numberOfSections;
    if (section < sectionCount)
    {
        NSUInteger headerRow = (NSUInteger)(NSNotFound - kSectionHeaderRowModifier);
        
        return [NSIndexPath gne_indexPathForRow:headerRow inSection:section];
    }
    
    return nil;
}


- (NSIndexPath * __nullable)indexPathForFooterInSection:(NSUInteger)section
{
    NSUInteger sectionCount = self.numberOfSections;
    if (section < sectionCount)
    {
        NSUInteger footerRow = (NSUInteger)(NSNotFound - kSectionFooterRowModifier);
        
        return [NSIndexPath gne_indexPathForRow:footerRow inSection:section];
    }
    
    return nil;
}


- (NSIndexPath  * __nullable)indexPathForTableViewRow:(NSInteger)row
{
    if (row >= 0)
    {
        GNEOutlineViewItem *item = [self itemAtRow:row];

        return [self p_indexPathOfOutlineViewItem:item];
    }

    return nil;
}


- (NSInteger)tableViewRowForIndexPath:(NSIndexPath * __nullable)indexPath
{
    if ([self isIndexPathValid:indexPath] == NO)
    {
        return -1;
    }
    
    GNEOutlineViewItem *item = [self p_outlineViewItemAtIndexPath:indexPath];
    
    return [self rowForItem:item];
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Public - Insertion, Deletion, Move, and Update
// ------------------------------------------------------------------------------------------
- (void)insertRowsAtIndexPaths:(NSArray * __nonnull)indexPaths
                 withAnimation:(NSTableViewAnimationOptions)animationOptions
{
#if GNE_CRUD_LOGGING_ENABLED
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
            NSUInteger section = ((NSIndexPath *)indexPathsInSection.firstObject).gne_section;
            
            GNEOutlineViewParentItem *parentItem = [self p_outlineViewParentItemForSection:section];
            GNEAssert1(parentItem, @"No outline view parent item exists for section %lu", (long unsigned)section);
            
            if (parentItem == nil)
            {
                return;
            }
            
            NSUInteger parentItemIndex = [self.outlineViewParentItems indexOfObject:parentItem];
            GNEParameterAssert(parentItemIndex < self.outlineViewItems.count);
            
            NSMutableArray *rows = self.outlineViewItems[parentItemIndex];
            
            for (NSIndexPath *indexPath in indexPathsInSection)
            {
                GNEOutlineViewItem *outlineViewItem = [[GNEOutlineViewItem alloc] initWithParentItem:parentItem];
                outlineViewItem.pasteboardWritingDelegate = self;
                [insertedIndexes addIndex:[rows gne_insertObject:outlineViewItem atIndex:indexPath.gne_row]];
            }
            
            [self insertItemsAtIndexes:insertedIndexes inParent:parentItem withAnimation:animationOptions];
        }
    }
    [self endUpdates];
    
    [self p_checkDataSourceIntegrity];
}


- (void)deleteRowsAtIndexPaths:(NSArray * __nonnull)indexPaths
                 withAnimation:(NSTableViewAnimationOptions)animationOptions
{
#if GNE_CRUD_LOGGING_ENABLED
    NSLog(@"%@\n%@", NSStringFromSelector(_cmd), indexPaths);
#endif
    
    [self p_checkIndexPathsArray:indexPaths];
    
    NSArray *groupedIndexPaths = [self p_reverseSortedIndexPathsGroupedBySectionInIndexPaths:indexPaths];
    
    NSIndexPath *firstIndexPath = nil;
    
    [self beginUpdates];
    for (NSArray *indexPathsInSection in groupedIndexPaths)
    {
        firstIndexPath = indexPathsInSection.firstObject;
        
        if (firstIndexPath == nil)
        {
            continue;
        }
        
        GNEOutlineViewItem *firstItem = [self p_outlineViewItemAtIndexPath:firstIndexPath];
        
        if (firstItem == nil)
        {
            continue;
        }
        
        GNEOutlineViewParentItem *parentItem = firstItem.parentItem;
        
        GNEParameterAssert(parentItem);
        
        NSMutableIndexSet *deletedIndexes = [NSMutableIndexSet indexSet];
        for (NSIndexPath *indexPath in indexPathsInSection)
        {
            GNEOutlineViewItem *item = [self p_outlineViewItemAtIndexPath:indexPath];
            
            if (item == nil)
            {
                continue;
            }

#if GNE_ASSERT_ENABLED
            GNEOutlineViewParentItem *actualParentItem = item.parentItem;
            GNEParameterAssert([actualParentItem isEqual:parentItem]);
#endif
            
#if GNE_CRUD_LOGGING_ENABLED
            NSIndexPath *actualIndexPath = [self p_indexPathOfOutlineViewItem:item];
            GNEParameterAssert([actualIndexPath compare:indexPath] == NSOrderedSame);
#endif
            
            // Add the item's index path row to the index set that will be passed to the NSOutlineView.
            [deletedIndexes addIndex:indexPath.gne_row];
            
            // Delete the actual item from the outline view items array.
            [self.outlineViewItems[indexPath.gne_section] removeObjectAtIndex:indexPath.gne_row];
        }
        
        // Delete the outline view rows with the supplied animation.
        [self removeItemsAtIndexes:deletedIndexes inParent:parentItem withAnimation:animationOptions];
    }
    [self endUpdates];
    
    [self p_checkDataSourceIntegrity];
}


- (void)moveRowAtIndexPath:(NSIndexPath * __nonnull)fromIndexPath
               toIndexPath:(NSIndexPath * __nonnull)toIndexPath
{
    GNEParameterAssert(fromIndexPath);
    GNEParameterAssert(toIndexPath);
    
    [self moveRowsAtIndexPaths:@[fromIndexPath] toIndexPaths:@[toIndexPath]];
}


- (void)moveRowsAtIndexPaths:(NSArray * __nonnull)fromIndexPaths
                toIndexPaths:(NSArray * __nonnull)toIndexPaths
{
    GNEParameterAssert(fromIndexPaths.count == toIndexPaths.count);
    
    [self p_checkIndexPathsArray:fromIndexPaths];
    [self p_checkIndexPathsArray:toIndexPaths];
    
    if (self.currentMove)
    {
        [self.currentMove moveRowsAtIndexPaths:fromIndexPaths toIndexPaths:toIndexPaths];
    }
    else
    {
        NSInteger column = self.numberOfColumns - 1;
        if (column < 0)
        {
            return;
        }
        
        GNESectionedTableViewMove *move = [[GNESectionedTableViewMove alloc] initWithTableView:self];
        
        for (NSIndexPath *indexPath in fromIndexPaths)
        {
            NSInteger tableViewRow = [self tableViewRowForIndexPath:indexPath];
            
            if (tableViewRow == -1 || tableViewRow >= self.numberOfRows)
            {
                continue;
            }
            
            NSTableCellView *cellView = [self viewAtColumn:column row:tableViewRow makeIfNecessary:NO];
            CGRect frame = [self frameOfViewAtIndexPath:indexPath];
            
            if (cellView == nil)
            {
                continue;
            }
            
            GNESectionedTableViewMovingItem *movingItem = [[GNESectionedTableViewMovingItem alloc]
                                                           initWithTableCellView:cellView
                                                           frame:frame
                                                           indexPath:indexPath];
            
            [move addMovingItem:movingItem];
        }
        
        [move moveRowsAtIndexPaths:fromIndexPaths toIndexPaths:toIndexPaths];
    }
}


- (void)moveRowsAtIndexPaths:(NSArray * __nonnull)fromIndexPaths
                 toIndexPath:(NSIndexPath * __nonnull)toIndexPath
{
    [self p_checkIndexPathsArray:fromIndexPaths];
    
    NSUInteger count = fromIndexPaths.count;
    
    NSMutableArray *toIndexPaths = [NSMutableArray array];
    
    NSUInteger section = toIndexPath.gne_section;
    NSUInteger row = toIndexPath.gne_row;
    for (NSUInteger i = 0; i < count; i++)
    {
        NSUInteger toRow = row + i;
        NSIndexPath *anIndexPath = [NSIndexPath gne_indexPathForRow:toRow inSection:section];
        [toIndexPaths addObject:anIndexPath];
    }
    
    [self moveRowsAtIndexPaths:fromIndexPaths toIndexPaths:[toIndexPaths copy]];
}


- (void)reloadRowsAtIndexPaths:(NSArray * __nonnull)indexPaths
{
#if GNE_CRUD_LOGGING_ENABLED
    NSLog(@"%@\n%@", NSStringFromSelector(_cmd), indexPaths);
#endif
    
    [self p_checkIndexPathsArray:indexPaths];
    
    NSArray *groupedIndexPaths = [self p_sortedIndexPathsGroupedBySectionInIndexPaths:indexPaths];
    
    [self beginUpdates];
    for (NSArray *indexPathsInSection in groupedIndexPaths)
    {
        for (NSIndexPath *indexPath in indexPathsInSection)
        {
            GNEOutlineViewItem *item = [self p_outlineViewItemAtIndexPath:indexPath];
            
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


- (void)insertSections:(NSIndexSet * __nonnull)sections
         withAnimation:(NSTableViewAnimationOptions)animationOptions
{
    [self insertSections:sections withAnimation:animationOptions expanded:YES];
}


- (void)insertSections:(NSIndexSet * __nonnull)sections
         withAnimation:(NSTableViewAnimationOptions)animationOptions
              expanded:(BOOL)expanded
{
#if GNE_CRUD_LOGGING_ENABLED
    NSLog(@"%@\n%@", NSStringFromSelector(_cmd), sections);
#endif
    
    GNEParameterAssert([self.tableViewDataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]);
    
    NSMutableIndexSet *insertedSections = [NSMutableIndexSet indexSet];
    
    NSMutableArray *outlineViewParentItemsCopy = [NSMutableArray arrayWithArray:self.outlineViewParentItems];
    NSMutableArray *outlineViewItemsCopy = [NSMutableArray arrayWithArray:self.outlineViewItems];
    
    [sections enumerateIndexesUsingBlock:^(NSUInteger proposedSection, BOOL *stop __unused)
    {
        @autoreleasepool
        {
            NSUInteger sectionCount = outlineViewParentItemsCopy.count;
            NSUInteger section = (proposedSection > sectionCount) ? sectionCount : proposedSection;
            
            GNEOutlineViewParentItem *parentItem = [[GNEOutlineViewParentItem alloc] init];
            parentItem.pasteboardWritingDelegate = self;
            parentItem.hasFooter = [self p_requestDelegateHasFooterInSection:section];
            [outlineViewParentItemsCopy gne_insertObject:parentItem atIndex:section];
            
            NSMutableArray *rows = [NSMutableArray array];
            [outlineViewItemsCopy gne_insertObject:rows atIndex:section];
            
            NSUInteger rowCount = [self.tableViewDataSource tableView:self numberOfRowsInSection:section];
            rowCount += (parentItem.hasFooter) ? 1 : 0; // Add a footer item, if needed.
            
            for (NSUInteger row = 0; row < rowCount; row++)
            {
                GNEOutlineViewItem *item = [[GNEOutlineViewItem alloc] initWithParentItem:parentItem];
                item.pasteboardWritingDelegate = self;
                
                [rows addObject:item];
            }
            
            [insertedSections addIndex:section];
        }
    }];
    
    GNEParameterAssert(sections.count == insertedSections.count);
    
    self.outlineViewParentItems = outlineViewParentItemsCopy;
    self.outlineViewItems = outlineViewItemsCopy;
    
    [self insertItemsAtIndexes:insertedSections inParent:nil withAnimation:animationOptions];
    
    if (expanded)
    {
        [self.insertedSectionsToExpand addIndexes:insertedSections];
    }
    
    [self p_checkDataSourceIntegrity];
}


- (void)deleteSections:(NSIndexSet * __nonnull)sections
         withAnimation:(NSTableViewAnimationOptions)animationOptions
{
#if GNE_CRUD_LOGGING_ENABLED
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
            NSUInteger index = [self p_sectionForOutlineViewParentItem:parentItem];
            
            if (index != NSNotFound)
            {
                GNEParameterAssert([deletedSections containsIndex:index] == NO);
                
                [deletedSections addIndex:index];
                
                GNEParameterAssert(index < outlineViewParentItemsCopy.count);
                GNEParameterAssert(index < outlineViewItemsCopy.count);
                
                [outlineViewParentItemsCopy removeObjectAtIndex:index];
                [outlineViewItemsCopy removeObjectAtIndex:index];
            }
        }
    }];
    
    GNEParameterAssert(sections.count == deletedSections.count);
    
    self.outlineViewParentItems = outlineViewParentItemsCopy;
    self.outlineViewItems = outlineViewItemsCopy;
    
    [self removeItemsAtIndexes:deletedSections inParent:nil withAnimation:animationOptions];
    
    [self p_checkDataSourceIntegrity];
}


- (void)moveSection:(NSUInteger)fromSection toSection:(NSUInteger)toSection
{
    [self moveSections:[GNEOrderedIndexSet indexSetWithIndex:fromSection]
            toSections:[GNEOrderedIndexSet indexSetWithIndex:toSection]];
}


- (void)moveSections:(GNEOrderedIndexSet * __nonnull)fromSections
          toSections:(GNEOrderedIndexSet * __nonnull)toSections
{
#if GNE_CRUD_LOGGING_ENABLED
    NSLog(@"%@\nFrom: %@ To: %@", NSStringFromSelector(_cmd), fromSections, toSections);
#endif
    
    GNEParameterAssert(self.outlineViewParentItems.count == self.outlineViewItems.count);
    
    if (self.currentMove)
    {
        [self p_updateAutoCollapsedSectionsForMoveFromSections:fromSections
                                                    toSections:toSections];
        self.currentMove.autoCollapsedSections = self.autoCollapsedSections;
        
        [self.currentMove moveSections:fromSections toSections:toSections];
    }
    else
    {
        GNESectionedTableViewMove *move = [[GNESectionedTableViewMove alloc] initWithTableView:self];
        __weak typeof(self) weakSelf = self;
        move.completion = ^()
        {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf p_updateMapForAvailableRowViews];
        };
        
        GNEOrderedIndexSet *sectionsToExpand = [GNEOrderedIndexSet indexSet];
        [fromSections enumerateIndexesUsingBlock:^(NSUInteger section,
                                                   NSUInteger position,
                                                   BOOL *stop __unused)
        {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            BOOL isExpanded = [strongSelf isSectionExpanded:section];
            NSIndexPath *headerIndexPath = [strongSelf indexPathForHeaderInSection:section];
            CGRect sectionFrame = [strongSelf frameOfSection:section];
            NSArray *cellViews = [strongSelf p_availableCellViewsForSection:section];
            
            if (headerIndexPath && cellViews.count > 0)
            {
                GNESectionedTableViewMovingItem *movingItem = [[GNESectionedTableViewMovingItem alloc]
                                                               initForSectionWithTableCellViews:cellViews
                                                               frame:sectionFrame
                                                               headerIndexPath:headerIndexPath];
                [move addMovingItem:movingItem];
                if (isExpanded)
                {
                    [sectionsToExpand addIndex:[toSections indexAtPosition:position]];
                }
            }
        }];
        
        move.sectionsToExpand = sectionsToExpand.ns_indexSet;
        [move moveSections:fromSections toSections:toSections];
    }
    
    [self p_checkDataSourceIntegrity];
}


- (void)moveSections:(GNEOrderedIndexSet * __nonnull)fromSections toSection:(NSUInteger)toSection
{
    GNEParameterAssert(self.outlineViewParentItems.count == self.outlineViewItems.count);
    
    GNEOrderedIndexSet *toSections = [GNEOrderedIndexSet indexSet];
    NSUInteger count = fromSections.count;
    for (NSUInteger i = 0; i < count; i++)
    {
        [toSections addIndex:(toSection + i)];
    }
    
    [self moveSections:fromSections toSections:toSections];
    
    [self p_checkDataSourceIntegrity];
}


- (void)reloadSections:(NSIndexSet * __nonnull)sections
{
#if GNE_CRUD_LOGGING_ENABLED
    NSLog(@"%@\n%@", NSStringFromSelector(_cmd), sections);
#endif
    
    GNEParameterAssert(self.outlineViewParentItems.count == self.outlineViewItems.count);
    
    NSUInteger sectionCount = self.outlineViewParentItems.count;
    
    [self beginUpdates];
    [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop __unused)
    {
        GNEOutlineViewParentItem *parentItem = nil;
        if (section < sectionCount && (parentItem = [self p_outlineViewParentItemForSection:section]))
        {
            [self reloadItem:parentItem];
            if (section < self.outlineViewItems.count)
            {
                NSArray *children = self.outlineViewItems[section];
                for (id child in children)
                {
                    [self reloadItem:child];
                }
            }
        }
    }];
    [self endUpdates];
    
    [self p_checkDataSourceIntegrity];
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Public - Expand/Collapse Sections
// ------------------------------------------------------------------------------------------
- (BOOL)isSectionExpanded:(NSUInteger)section
{
    GNEParameterAssert(section < self.outlineViewParentItems.count + 1);
    
    if (section < self.outlineViewParentItems.count)
    {
        GNEOutlineViewParentItem *parentItem = self.outlineViewParentItems[section];
        
        return [self isItemExpanded:parentItem];
    }
    
    return NO;
}


- (void)expandAllSections:(BOOL)animated
{
    NSUInteger count = self.numberOfSections;
    NSRange range = NSMakeRange(0, count);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    
    [self expandItem:nil expandChildren:NO];
    [self expandSections:indexSet animated:animated];
    
}


- (void)expandSection:(NSUInteger)section animated:(BOOL)animated
{
    GNEParameterAssert(section < self.outlineViewParentItems.count);
    
    if (section < self.outlineViewParentItems.count)
    {
        [self expandSections:[NSIndexSet indexSetWithIndex:section]
                    animated:animated];
    }
}


- (void)expandSections:(NSIndexSet * __nonnull)sections animated:(BOOL)animated
{
    if (animated)
    {
        NSAnimationContext *context = [NSAnimationContext currentContext];
        NSString *name = kCAMediaTimingFunctionEaseOut;
        context.timingFunction = [CAMediaTimingFunction functionWithName:name];
    }
    
    NSUInteger count = self.outlineViewParentItems.count;
    __weak typeof(self) weakSelf = self;
    [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop __unused)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        BOOL canExpandSection = YES;
        SEL selector = @selector(tableView:shouldExpandSection:);
        if ([strongSelf.tableViewDelegate respondsToSelector:selector])
        {
            canExpandSection = [strongSelf.tableViewDelegate tableView:strongSelf
                                                   shouldExpandSection:section];
        }

        if (canExpandSection)
        {
            id outlineView = (animated) ? strongSelf.animator : strongSelf;
            if (section < count)
            {
                GNEOutlineViewParentItem *parentItem = strongSelf.outlineViewParentItems[section];
                if ([strongSelf isItemExpanded:parentItem] == NO)
                {
                    [outlineView expandItem:parentItem];
                }
            }
        }
    }];
}


- (void)collapseAllSections:(BOOL)animated
{
    NSUInteger count = self.numberOfSections;
    NSRange range = NSMakeRange(0, count);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    
    [self collapseSections:indexSet animated:animated];
}


- (void)collapseSection:(NSUInteger)section animated:(BOOL)animated
{
    GNEParameterAssert(section < self.outlineViewParentItems.count);
    
    if (section < self.outlineViewParentItems.count)
    {
        [self collapseSections:[NSIndexSet indexSetWithIndex:section]
                      animated:animated];
    }
}


- (void)collapseSections:(NSIndexSet * __nonnull)sections animated:(BOOL)animated
{
    if (animated)
    {
        NSAnimationContext *context = [NSAnimationContext currentContext];
        NSString *name = kCAMediaTimingFunctionEaseIn;
        context.timingFunction = [CAMediaTimingFunction functionWithName:name];
    }
    
    NSUInteger count = self.outlineViewParentItems.count;
    __weak typeof(self) weakSelf = self;
    [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop __unused)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        BOOL canCollapseSection = YES;
        SEL selector = @selector(tableView:shouldCollapseSection:);
        if ([strongSelf.tableViewDelegate respondsToSelector:selector])
        {
            canCollapseSection = [strongSelf.tableViewDelegate tableView:strongSelf
                                                   shouldCollapseSection:section];
        }

        if (canCollapseSection)
        {
            id outlineView = (animated) ? strongSelf.animator : strongSelf;
            if (section < count)
            {
                GNEOutlineViewParentItem *parentItem = strongSelf.outlineViewParentItems[section];
                if ([strongSelf isItemExpanded:parentItem])
                {
                    [outlineView collapseItem:parentItem];
                }
            }
        }
    }];
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Public - Selection
// ------------------------------------------------------------------------------------------
- (NSIndexPath *)selectedIndexPath
{
    NSInteger selectedRow = self.selectedRow;
    
    if (selectedRow >= 0)
    {
        GNEOutlineViewItem *item = [self itemAtRow:selectedRow];
        
        return [self p_indexPathOfOutlineViewItem:item];
    }
    
    return nil;
}


- (NSArray *)selectedIndexPaths
{
    NSIndexSet *selectedRows = self.selectedRowIndexes;
    if (selectedRows.count > 0)
    {
        NSMutableArray *indexPaths = [NSMutableArray array];
        
        __weak typeof(self) weakSelf = self;
        [selectedRows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop __unused)
        {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            GNEOutlineViewItem *item = [strongSelf itemAtRow:(NSInteger)idx];
            NSIndexPath *indexPath = [strongSelf p_indexPathOfOutlineViewItem:item];
            if (indexPath)
            {
                [indexPaths addObject:indexPath];
            }
        }];
        
        if (indexPaths.count > 0)
        {
            SEL selector = NSSelectorFromString(@"gne_compare:");
            return [indexPaths sortedArrayUsingSelector:selector];
        }
    }
    
    return @[];
}


- (BOOL)isIndexPathSelected:(NSIndexPath * __nonnull)indexPath
{
    GNEParameterAssert(indexPath);
    
    NSArray *selectedIndexPaths = self.selectedIndexPaths;
    
    if (indexPath && selectedIndexPaths.count > 0)
    {
        NSRange range = NSMakeRange(0, selectedIndexPaths.count);
        NSUInteger index = [selectedIndexPaths indexOfObject:indexPath
                                               inSortedRange:range
                                                     options:NSBinarySearchingFirstEqual
                                             usingComparator:^NSComparisonResult(NSIndexPath *first,
                                                                                 NSIndexPath *second)
        {
            return [first gne_compare:second];
        }];
        
        return ((index == NSNotFound) ? NO : YES);
    }
    
    return NO;
}


- (void)selectRowAtIndexPath:(NSIndexPath * __nullable)indexPath byExtendingSelection:(BOOL)extend
{
    if (indexPath == nil && extend == NO)
    {
        [self deselectAll:self];
        
        return;
    }
    
    NSUInteger section = indexPath.gne_section;
    NSUInteger row = indexPath.gne_row;
    
    GNEParameterAssert(section < self.outlineViewItems.count &&
                       row < ((NSArray *)self.outlineViewItems[section]).count);
    
    if (section >= self.outlineViewItems.count ||
        row >= ((NSArray *)self.outlineViewItems[section]).count)
    {
        return;
    }
    
    GNEOutlineViewItem *item = ((NSArray *)self.outlineViewItems[section])[row];
    NSInteger tableViewRow = [self rowForItem:item];
    
    if (tableViewRow >= 0 &&
        tableViewRow < self.numberOfRows)
    {
        [self selectRowIndexes:[NSIndexSet indexSetWithIndex:(NSUInteger)tableViewRow]
          byExtendingSelection:extend];
    }
}


- (void)selectRowsAtIndexPaths:(NSArray * __nullable)indexPaths byExtendingSelection:(BOOL)extend
{
    if (indexPaths.count == 0 && extend == NO)
    {
        [self deselectAll:self];
        
        return;
    }
    
    NSMutableIndexSet *tableViewRowIndexes = [NSMutableIndexSet indexSet];
    
    for (NSIndexPath *indexPath in indexPaths)
    {
        NSInteger tableViewRow = [self tableViewRowForIndexPath:indexPath];
        if (tableViewRow >= 0)
        {
            [tableViewRowIndexes addIndex:(NSUInteger)tableViewRow];
        }
    }
    
    [self selectRowIndexes:tableViewRowIndexes byExtendingSelection:extend];
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Public - Layout Support
// ------------------------------------------------------------------------------------------
- (NSIndexPath * __nullable)indexPathForViewAtPoint:(CGPoint)point
{
    NSInteger tableViewRow = [self rowAtPoint:point];
    
    return [self indexPathForTableViewRow:tableViewRow];
}


- (CGRect)frameOfViewAtIndexPath:(NSIndexPath * __nonnull)indexPath
{
    GNEOutlineViewItem *item = [self p_outlineViewItemAtIndexPath:indexPath];
    NSInteger lastColumn = self.numberOfColumns - 1; // Assume only one column
    if (item && lastColumn >= 0)
    {
        NSInteger row = [self rowForItem:item];
        
        return [super frameOfCellAtColumn:lastColumn row:row];
    }
    
    return CGRectZero;
}


- (CGRect)frameOfSection:(NSUInteger)section
{
    GNEOutlineViewParentItem *parentItem = [self p_outlineViewParentItemForSection:section];
    NSIndexPath *sectionIndexPath = [self p_indexPathOfOutlineViewItem:parentItem];
    
    if (sectionIndexPath == nil)
    {
        return CGRectZero;
    }
    
    CGRect frame = [self frameOfViewAtIndexPath:sectionIndexPath];
    if ([self isItemExpanded:parentItem])
    {
        NSArray *rowsArray = self.outlineViewItems[section];
        for (GNEOutlineViewItem *item in rowsArray)
        {
            NSIndexPath *indexPath = [self p_indexPathOfOutlineViewItem:item];
            if (indexPath == nil)
            {
                break;
            }
            frame = CGRectUnion(frame, [self frameOfViewAtIndexPath:indexPath]);
        }
    }
    
    return frame;
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Public - Scrolling
// ------------------------------------------------------------------------------------------
- (void)scrollRowAtIndexPathToVisible:(NSIndexPath * __nonnull)indexPath
{
    NSInteger tableViewRow = [self tableViewRowForIndexPath:indexPath];
    if (tableViewRow >= 0)
    {
        [self scrollRowToVisible:tableViewRow];
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Internal - Build Data Source Arrays
// ------------------------------------------------------------------------------------------
- (void)p_buildOutlineViewItemArrays
{
    NSUInteger sectionCount = [self p_numberOfSections];
    for (NSUInteger section = 0; section < sectionCount; section++)
    {
        GNEOutlineViewParentItem *parentItem = [[GNEOutlineViewParentItem alloc] init];
        parentItem.pasteboardWritingDelegate = self;
        parentItem.hasFooter = [self p_requestDelegateHasFooterInSection:section];
        
        [self.outlineViewParentItems addObject:parentItem];
        NSMutableArray *rowArray = [NSMutableArray array];
        [self.outlineViewItems addObject:rowArray];
        
        NSUInteger rowCount = [self p_numberOfRowsInSection:section];
        rowCount += ((parentItem.hasFooter) ? 1 : 0);
        for (NSUInteger row = 0; row < rowCount; row++)
        {
            GNEOutlineViewItem *item = [[GNEOutlineViewItem alloc] initWithParentItem:parentItem];
            item.pasteboardWritingDelegate = self;
            [rowArray addObject:item];
        }
    }
}


/**
 Returns YES if the specified section has a header, otherwise NO.
 
 @discussion Returns YES if the table view delegate responds to
 tableView:heightForHeaderInSection:, tableView:rowViewForHeaderInSection:, and
 tableView:cellViewForHeaderInSection: and if the returned height for the header in
 the specified section is greater than or equal to 1.0.
 @param section Section to query the delegate for.
 @return YES if the specified section has a header, otherwise NO.
 */
- (BOOL)p_requestDelegateHasHeaderInSection:(NSUInteger)section
{
    SEL heightSelector = @selector(tableView:heightForHeaderInSection:);
    SEL rowViewSelector = @selector(tableView:rowViewForHeaderInSection:);
    SEL cellViewSelector = @selector(tableView:cellViewForHeaderInSection:);
    
    id <GNESectionedTableViewDelegate> theDelegate = self.tableViewDelegate;
    
    if ([theDelegate respondsToSelector:heightSelector] == NO ||
        [theDelegate respondsToSelector:rowViewSelector] == NO ||
        [theDelegate respondsToSelector:cellViewSelector] == NO)
    {
        return NO;
    }
    
    CGFloat height = [theDelegate tableView:self heightForHeaderInSection:section];
    
    return (height > GNESectionedTableViewInvisibleRowHeight);
}


/**
 Returns YES if the specified section has a footer, otherwise NO.
 
 @discussion Returns YES if the table view delegate responds to
 tableView:heightForFooterInSection:, tableView:rowViewForFooterInSection:,
 and tableView:cellViewForFooterInSection: and if the returned height for
 the footer in the specified section is greater than or equal to 1.0.
 @param section Section to query the delegate for.
 @return YES if the specified section has a footer, otherwise NO.
 */
- (BOOL)p_requestDelegateHasFooterInSection:(NSUInteger)section
{
    SEL heightSelector = @selector(tableView:heightForFooterInSection:);
    SEL rowViewSelector = @selector(tableView:rowViewForFooterInSection:);
    SEL cellViewSelector = @selector(tableView:cellViewForFooterInSection:);
    
    id <GNESectionedTableViewDelegate> theDelegate = self.tableViewDelegate;
    
    if ([theDelegate respondsToSelector:heightSelector] == NO ||
        [theDelegate respondsToSelector:rowViewSelector] == NO ||
        [theDelegate respondsToSelector:cellViewSelector] == NO)
    {
        return NO;
    }
    
    CGFloat height = [theDelegate tableView:self heightForFooterInSection:section];
    
    return (height > GNESectionedTableViewInvisibleRowHeight);
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Internal - Insert, Delete, Move Outline View Items
// ------------------------------------------------------------------------------------------
/**
 Returns an array of arrays. Each inner array contains all of the specified index paths belonging to the same 
 section. The sections and rows are all sorted in ascending order (from smallest to largest).
 
 @param indexPaths Array of index paths to group and sort.
 @return Array of arrays of index paths sorted in ascending order by section and row.
 */
- (NSArray *)p_sortedIndexPathsGroupedBySectionInIndexPaths:(NSArray *)indexPaths
{
    SEL comparator = NSSelectorFromString(@"gne_compare:");
    
    return [self p_sortedIndexPathsGroupedBySectionInIndexPaths:indexPaths usingSelector:comparator];
}


/**
 Returns an array of arrays. Each inner array contains all of the specified index paths belonging to the same
 section. The sections and rows are all sorted in descending order (from largest to smallest).
 
 @param indexPaths Array of index paths to group and sort.
 @return Array of arrays of index paths sorted in descending order by section and row.
 */
- (NSArray *)p_reverseSortedIndexPathsGroupedBySectionInIndexPaths:(NSArray *)indexPaths
{
    SEL comparator = NSSelectorFromString(@"gne_reverseCompare:");
    
    return [self p_sortedIndexPathsGroupedBySectionInIndexPaths:indexPaths usingSelector:comparator];
}


- (NSArray *)p_sortedIndexPathsGroupedBySectionInIndexPaths:(NSArray *)indexPaths usingSelector:(SEL)comparator
{
    NSMutableArray *groupedIndexPaths = [NSMutableArray array];
    NSArray *sortedIndexPaths = [indexPaths sortedArrayUsingSelector:comparator];
    
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
 Returns an index set that contains all of the valid section indexes in the specified index set.
 
 @param sections Index set containing indexes corresponding to outline view parent items in the outline view parent
 items array.
 @return Index set containing all of the valid section indexes in the specified index set.
 */
- (NSIndexSet *)p_indexSetByRemovingInvalidSectionsFromIndexSet:(NSIndexSet *)sections
{
    GNEParameterAssert(self.outlineViewParentItems.count == self.outlineViewItems.count);
    
    if (sections.count == 0)
    {
        return sections;
    }
    
    NSMutableIndexSet *validSections = [NSMutableIndexSet indexSet];
    [validSections addIndexes:sections];
    
    NSUInteger sectionCount = self.outlineViewParentItems.count;
    
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


- (void)p_updateAutoCollapsedSectionsForMoveFromSections:(GNEOrderedIndexSet *)fromSections
                                              toSections:(GNEOrderedIndexSet *)toSections
{
    if (self.autoCollapsedSections.count == 0)
    {
        return;
    }
    
    NSMutableIndexSet *updatedIndexSet = [NSMutableIndexSet indexSet];
    
    __weak typeof(self) weakSelf = self;
    [fromSections enumerateIndexesUsingBlock:^(NSUInteger section,
                                               NSUInteger position,
                                               BOOL *stop __unused)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.autoCollapsedSections containsIndex:section])
        {
            NSUInteger toSection = [toSections indexAtPosition:position];
            if (toSection != NSNotFound)
            {
                [updatedIndexSet addIndex:toSection];
            }
        }
    }];
    
    [self.autoCollapsedSections removeAllIndexes];
    [self.autoCollapsedSections addIndexes:updatedIndexSet];
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Internal - Retrieving Outline View Items
// ------------------------------------------------------------------------------------------
/**
 Returns the index pointing to the specified outline view parent item in the outline view parent items array.
 
 @param parentItem Outline view parent item to locate.
 @return Index matching the current location of the specified outline view parent item in table view's outline
 view parent items array, or NSNotFound if the outline view parent item could not be found.
 */
- (NSUInteger)p_sectionForOutlineViewParentItem:(GNEOutlineViewParentItem *)parentItem
{
    NSUInteger index = [self.outlineViewParentItems indexOfObject:parentItem];
    
    return index;
}


/**
 Returns an index set of all of the section headers contained in the specified row indexes, or nil if the
 row indexes do not correspond to any section headers.
 
 @param rowIndexes Table view indexes.
 @return Index set of the section headers or nil if the specified row indexes don't correspond to any
 section headers.
 */
- (NSIndexSet *)p_indexSetOfSectionHeadersAtTableViewRows:(NSIndexSet *)rowIndexes
{
    NSMutableIndexSet *sectionIndexes = [NSMutableIndexSet indexSet];
    
    __weak typeof(self) weakSelf = self;
    [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger tableViewRow, BOOL *stop __unused)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        GNEOutlineViewItem *item = [strongSelf itemAtRow:(NSInteger)tableViewRow];
        if (item && item.parentItem == nil)
        {
            GNEParameterAssert([item isKindOfClass:[GNEOutlineViewParentItem class]]);
            NSUInteger section = [strongSelf p_sectionForOutlineViewParentItem:(GNEOutlineViewParentItem *)item];
            if (section != NSNotFound)
            {
                [sectionIndexes addIndex:section];
            }
        }
    }];
    
    return ((sectionIndexes.count > 0) ? [sectionIndexes copy] : nil);
}


/**
 Returns an index set of all of the section footers contained in the specified row indexes, or nil if the
 row indexes do not correspond to any section footers.
 
 @param rowIndexes Table view indexes.
 @return Index set of the section footers or nil if the specified row indexes don't correspond to any
 section footers.
 */
- (NSIndexSet *)p_indexSetOfSectionFootersAtTableViewRows:(NSIndexSet *)rowIndexes
{
    NSMutableIndexSet *sectionIndexes = [NSMutableIndexSet indexSet];
    
    __weak typeof(self) weakSelf = self;
    [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger tableViewRow, BOOL *stop __unused)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        GNEOutlineViewItem *item = [strongSelf itemAtRow:(NSInteger)tableViewRow];
        BOOL isFooter = [self p_isOutlineViewItemFooter:item];
        if (isFooter)
        {
            NSUInteger section = [self p_sectionForOutlineViewParentItem:item.parentItem];
            
            if (section != NSNotFound)
            {
                [sectionIndexes addIndex:section];
            }
        }
    }];
    
    return ((sectionIndexes.count > 0) ? [sectionIndexes copy] : nil);
}


- (NSIndexSet *)p_indexSetOfTableViewRowsForIndexPaths:(NSArray *)indexPaths
{
    if (indexPaths.count == 0)
    {
        return nil;
    }
    
    NSMutableIndexSet *mutableIndexSet = [NSMutableIndexSet indexSet];
    for (NSIndexPath *indexPath in indexPaths)
    {
        NSInteger tableViewRow = [self tableViewRowForIndexPath:indexPath];
        if (tableViewRow >= 0)
        {
            [mutableIndexSet addIndex:(NSUInteger)tableViewRow];
        }
    }
    
    return ((mutableIndexSet.count > 0) ? [mutableIndexSet copy] : nil);
}


- (NSIndexSet *)p_indexSetOfTableViewRowsForHeadersInSections:(NSIndexSet *)sectionIndexes
{
    return [self p_indexSetOfTableViewRowsForAccessoryViewsInSections:sectionIndexes
                                                          rowModifier:kSectionHeaderRowModifier];
}


- (NSIndexSet *)p_indexSetOfTableViewRowsForFootersInSections:(NSIndexSet *)sectionIndexes
{
    return [self p_indexSetOfTableViewRowsForAccessoryViewsInSections:sectionIndexes
                                                          rowModifier:kSectionFooterRowModifier];
}


/**
 Returns the index set for the table view rows corresponding to the accessory views
 (e.g., headers or footers) having the specified row modifier in the specified sections. Returns
 nil if the specified sections don't container accessory views having the specified row modifier.
 */
- (NSIndexSet *)p_indexSetOfTableViewRowsForAccessoryViewsInSections:(NSIndexSet *)sectionIndexes
                                                         rowModifier:(NSUInteger)rowModifier
{
    if (sectionIndexes.count == 0)
    {
        return nil;
    }
    
    NSMutableIndexSet *mutableIndexSet = [NSMutableIndexSet indexSet];
    
    __weak typeof(self) weakSelf = self;
    [sectionIndexes enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop __unused)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil)
        {
            return;
        }

        NSUInteger accessoryViewRow = (NSUInteger)(NSNotFound - rowModifier);
        NSIndexPath *indexPath = [NSIndexPath gne_indexPathForRow:accessoryViewRow
                                                        inSection:section];
        NSInteger tableViewRow = [strongSelf tableViewRowForIndexPath:indexPath];
        if (tableViewRow >= 0)
        {
            [mutableIndexSet addIndex:(NSUInteger)tableViewRow];
        }
    }];
    
    return ((mutableIndexSet.count > 0) ? [mutableIndexSet copy] : nil);
}


/**
 Returns the child index of the specified outline view item in its parent, otherwise NSNotFound.
 Throws an exception if the specified outline view parent item does not match the specified
 outline view item's parent.
 */
- (NSUInteger)p_childIndexOfOutlineViewItem:(GNEOutlineViewItem *)item
                               inParentItem:(GNEOutlineViewParentItem *)parentItem
{
    GNEOutlineViewParentItem *theParentItem = item.parentItem;
    
    GNEParameterAssert([theParentItem isEqual:parentItem]);
    
    if ([theParentItem isEqual:parentItem])
    {
        return [self p_childIndexOfOutlineViewItem:item];
    }
    
    return NSNotFound;
}


/// Returns the child index of the specified outline view item in its parent, otherwise NSNotFound.
- (NSUInteger)p_childIndexOfOutlineViewItem:(GNEOutlineViewItem *)item
{
    NSUInteger section = [self p_sectionForOutlineViewParentItem:item.parentItem];
    NSUInteger sectionCount = self.outlineViewItems.count;
    
    if (section == NSNotFound || section >= sectionCount)
    {
        return NSNotFound;
    }
    
    NSArray *items = self.outlineViewItems[section];
    
    return [items indexOfObject:item];
}


/**
 Returns the index path pointing to the specified outline view item in the outline view items array.
 
 @param item Outline view item to locate.
 @return Index path matching the current location of the specified outline view item in table view's outline view
            items array, or nil if it couldn't be found.
 */
- (NSIndexPath *)p_indexPathOfOutlineViewItem:(GNEOutlineViewItem *)item
{
    if (item == nil)
    {
        return nil;
    }
    
    NSUInteger sectionCount = self.outlineViewItems.count;
    
    // If it's a outline view parent item, make a section header index path for it.
    GNEOutlineViewParentItem *parentItem = item.parentItem;
    if (parentItem == nil)
    {
        NSUInteger section = [self p_sectionForOutlineViewParentItem:(GNEOutlineViewParentItem *)item];
        NSIndexPath *indexPath = [self indexPathForHeaderInSection:section];
        
        return ((section == NSNotFound) ? nil : indexPath);
    }
    
    NSUInteger section = [self p_sectionForOutlineViewParentItem:parentItem];

    if (section != NSNotFound && section < sectionCount)
    {
        // If it represents a section footer, make a section footer index path for it.
        if ([self p_isOutlineViewItemFooter:item])
        {
            return [self indexPathForFooterInSection:section];
        }
        else // Find the outline view item in its parent's section.
        {
            NSUInteger childIndex = [self p_childIndexOfOutlineViewItem:item];
            
            return ((childIndex == NSNotFound) ? nil : [NSIndexPath gne_indexPathForRow:childIndex
                                                                              inSection:section]);
        }
    }
    
    return nil;
}


- (NSArray *)p_indexPathsByRemovingHeadersAndFootersFromIndexPaths:(NSArray *)indexPaths
{
    NSMutableArray *mutableIndexPaths = [NSMutableArray array];
    
    for (NSIndexPath *indexPath in indexPaths)
    {
        if ([self isIndexPathHeader:indexPath] == NO &&
            [self isIndexPathFooter:indexPath] == NO)
        {
            [mutableIndexPaths addObject:indexPath];
        }
    }
    
    return [mutableIndexPaths copy];
}


/**
 Returns an array of the index paths of the rows contained in the specified table view row indexes, or nil if
 the table view row indexes do not correspond to any rows.
 
 @param rowIndexes Table view indexes.
 @return Array of the index paths for the rows or nil if the specified table view row indexes don't
 correspond to any rows.
 */
- (NSArray *)p_indexPathsOfRowsAtTableViewRows:(NSIndexSet *)rowIndexes
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop __unused)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        GNEOutlineViewItem *item = [strongSelf itemAtRow:(NSInteger)idx];
        if (item.parentItem)
        {
            NSIndexPath *indexPath = [strongSelf p_indexPathOfOutlineViewItem:item];
            if (indexPath)
            {
                [indexPaths addObject:indexPath];
            }
        }
    }];
    
    return ((indexPaths.count > 0) ? [NSArray arrayWithArray:indexPaths] : nil);
}


/**
 Returns the outline view item or outline view parent item located at the specified index in the outline
 view items array or outline view parent items array, or nil if the item couldn't be found.
 
 @discussion Returns an outline view item if parentItem is not nil, otherwise returns an outline view
 parent item.
 @param index Index of the desired outline view item or parent item.
 @param parentItem Outline view parent item for the desired outline view item or nil if searching for
 an outline view parent item.
 @return Outline view item or outline view parent item located at the specified index of the specified parent.
 */
- (GNEOutlineViewItem *)p_outlineViewItemAtIndex:(NSUInteger)index ofParent:(GNEOutlineViewParentItem *)parentItem
{
    GNEParameterAssert(parentItem == nil || [parentItem isKindOfClass:[GNEOutlineViewParentItem class]]);
    
    if (parentItem)
    {
        NSUInteger section = [self p_sectionForOutlineViewParentItem:parentItem];
        
        if (section < self.outlineViewItems.count && index < ((NSArray *)self.outlineViewItems[section]).count)
        {
            NSArray *sectionArray = self.outlineViewItems[section];
            
            return sectionArray[index];
        }
    }
    else if (index < self.outlineViewParentItems.count)
    {
        return self.outlineViewParentItems[index];
    }
    
    GNEAssert2(NO, @"Could not find item at index %lu of parent %@", (unsigned long)index, parentItem);
    
    return nil;
}


/**
 Returns the outline view parent item for the specified section.
 
 @param section Section to use to find a matching outline view parent item.
 @return Outline view parent item for the specified section, otherwise nil.
 */
- (GNEOutlineViewParentItem *)p_outlineViewParentItemForSection:(NSUInteger)section
{
    NSIndexPath *indexPath = [self indexPathForHeaderInSection:section];
    
    return [self p_outlineViewParentItemWithIndexPath:indexPath];
}


/**
 Returns the outline view parent item at the specified index path.
 
 @param indexPath Index path to use to find a matching outline view parent item.
 @return Outline view parent item at the specified index path, otherwise nil.
 */
- (GNEOutlineViewParentItem *)p_outlineViewParentItemWithIndexPath:(NSIndexPath *)indexPath
{
    GNEParameterAssert(indexPath);
    GNEParameterAssert([self isIndexPathHeader:indexPath]);
    
    NSUInteger parentItemsCount = self.outlineViewParentItems.count;
    
    GNEParameterAssert(indexPath.gne_section < parentItemsCount);
    
    if (indexPath.gne_section < parentItemsCount)
    {
        return self.outlineViewParentItems[indexPath.gne_section];
    }
    
    return nil;
}


/**
 Returns the outline view item at the specified index path.
 
 @param indexPath Index path to use to find a matching outline view item.
 @return Outline view item at the specified index path, otherwise nil.
 */
- (GNEOutlineViewItem *)p_outlineViewItemAtIndexPath:(NSIndexPath *)indexPath
{
    GNEParameterAssert(indexPath);
    
    // If it's an outline view parent item, call the appropriate method.
    if ([self isIndexPathHeader:indexPath])
    {
        return [self p_outlineViewParentItemForSection:indexPath.gne_section];
    }
    
    NSUInteger sectionCount = self.outlineViewItems.count;
    
    GNEParameterAssert(indexPath.gne_section < sectionCount);
    
    if (indexPath.gne_section < sectionCount)
    {
        NSArray *sectionArray = self.outlineViewItems[indexPath.gne_section];
        NSUInteger rowCount = sectionArray.count;
        
        GNEParameterAssert([self isIndexPathFooter:indexPath] ||
                           indexPath.gne_row < rowCount);
        
        if ([self isIndexPathFooter:indexPath])
        {
            return [self p_outlineViewItemForFooterInSection:indexPath.gne_section];
        }
        else if (indexPath.gne_row < rowCount)
        {
            return sectionArray[indexPath.gne_row];
        }
    }
    
    return nil;
}


- (GNEOutlineViewItem *)p_outlineViewItemForFooterInSection:(NSUInteger)section
{
    GNEOutlineViewParentItem *parentItem = [self p_outlineViewParentItemForSection:section];
    
    return [self p_outlineViewItemForFooterInOutlineViewParentItem:parentItem];
}


/**
 Returns the outline view item that represents the footer in the section of the specified
 outline view parent item or nil if the section for the parent item doesn't have a footer
 or can't be found.
 */
- (GNEOutlineViewItem *)p_outlineViewItemForFooterInOutlineViewParentItem:(GNEOutlineViewParentItem *)parentItem
{
    if (parentItem.hasFooter == NO)
    {
        return nil;
    }
    
    NSUInteger section = [self p_sectionForOutlineViewParentItem:parentItem];
    NSUInteger sectionCount = self.outlineViewItems.count;
    
    if (section == NSNotFound || section >= sectionCount)
    {
        return nil;
    }
    
    NSArray *items = self.outlineViewItems[section];
    NSUInteger rowCount = items.count;
    
    if (rowCount == 0)
    {
        return nil;
    }
    
    GNEOutlineViewItem *item = items[rowCount - 1];
    
    return item;
}


/// Returns YES if the specified outline view item represents the footer in its section, otherwise NO.
- (BOOL)p_isOutlineViewItemFooter:(GNEOutlineViewItem *)item
{
    GNEOutlineViewParentItem *parentItem = item.parentItem;
    
    if (parentItem == nil || parentItem.hasFooter == NO)
    {
        return NO;
    }
    
    NSUInteger childCount = [self p_numberOfOutlineViewItemsForOutlineViewParentItem:parentItem];
    NSUInteger childIndex = [self p_childIndexOfOutlineViewItem:item];
    
    if (childCount == 0 || childIndex == NSNotFound)
    {
        return NO;
    }
    
    return ((childCount - 1) == childIndex);
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


/**
 Returns the total number of rows (headers, footers, and normal rows) contained in the outline
 view.
 */
- (NSUInteger)p_numberOfRowsInOutlineView
{
    NSUInteger sectionCount = self.outlineViewItems.count;
    NSUInteger rowAndFooterCount = 0;
    
    for (NSUInteger section = 0; section < sectionCount; section++)
    {
        rowAndFooterCount += ((NSArray *)self.outlineViewItems[section]).count;
    }
    
    return (sectionCount + rowAndFooterCount); // Section headers count as rows even if they are not "visible"
}


/**
 Returns the number of outline view items (including items that represent normal rows and footers)
 in the specified outline view parent item.
 */
- (NSUInteger)p_numberOfOutlineViewItemsForOutlineViewParentItem:(GNEOutlineViewParentItem *)parentItem
{
    GNEParameterAssert([parentItem isKindOfClass:[GNEOutlineViewParentItem class]]);
    
    NSUInteger section = [self p_sectionForOutlineViewParentItem:parentItem];
    if (section < self.outlineViewItems.count)
    {
        return ((NSArray *)self.outlineViewItems[section]).count;
    }
    
    return 0;
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Internal - Expand/Collapse
// ------------------------------------------------------------------------------------------
- (NSUInteger)p_sectionForExpandCollapseNotification:(NSNotification *)notification
{
    NSString * const kItemKey = @"NSObject";
    GNEOutlineViewParentItem *parentItem = notification.userInfo[kItemKey];
    
    if ([notification.object isEqual:self] == NO ||
        [parentItem isKindOfClass:[GNEOutlineViewParentItem class]] == NO)
    {
        return NSNotFound;
    }
    
    return [self p_sectionForOutlineViewParentItem:parentItem];
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Internal - Selection
// ------------------------------------------------------------------------------------------
- (void)p_didClickRow:(id)sender
{
    if ([self isEqual:sender] == NO)
    {
        return;
    }
    
    NSInteger clickedRow = self.clickedRow;
    GNEOutlineViewItem *item = nil;
    if (clickedRow >= 0 && (item = [self itemAtRow:clickedRow]))
    {
        BOOL shouldDelay = [self p_shouldDelayClickActionForOutlineViewItem:item];
        if (shouldDelay)
        {
            SEL selector = @selector(p_performClickActionForRowNumber:);
            [self performSelector:selector
                       withObject:@(clickedRow)
                       afterDelay:[NSEvent doubleClickInterval]];
        }
        else
        {
            [self p_cancelClickActions];
            [self p_performClickActionForRowNumber:@(clickedRow)];
        }
    }
}


- (void)p_didDoubleClickRow:(id)sender
{
    if ([self isEqual:sender] == NO)
    {
        return;
    }
    
    NSInteger clickedRow = self.clickedRow;
    
    GNEOutlineViewItem *item = nil;
    if (clickedRow >= 0 && (item = [self itemAtRow:clickedRow]))
    {
        GNEOutlineViewParentItem *parentItem = item.parentItem;
        
        SEL headerSelector = @selector(tableView:didDoubleClickHeaderInSection:);
        if (parentItem == nil && [self.tableViewDelegate respondsToSelector:headerSelector])
        {
            [self p_cancelClickActions];
            NSUInteger section = [self p_sectionForOutlineViewParentItem:(GNEOutlineViewParentItem *)item];
            [self.tableViewDelegate tableView:self didDoubleClickHeaderInSection:section];
        }
        
        if (parentItem)
        {
            SEL footerSelector = @selector(tableView:didDoubleClickFooterInSection:);
            SEL rowSelector = @selector(tableView:didDoubleClickRowAtIndexPath:);
            
            BOOL isFooter = [self p_isOutlineViewItemFooter:item];
            NSIndexPath *indexPath = [self p_indexPathOfOutlineViewItem:item];
            
            if (isFooter && [self.tableViewDelegate respondsToSelector:footerSelector])
            {
                [self p_cancelClickActions];
                [self.tableViewDelegate tableView:self
                    didDoubleClickFooterInSection:indexPath.gne_section];
            }
            else if (isFooter == NO && [self.tableViewDelegate respondsToSelector:rowSelector])
            {
                [self p_cancelClickActions];
                [self.tableViewDelegate tableView:self didDoubleClickRowAtIndexPath:indexPath];
            }
        }
    }
}


- (void)p_performClickActionForRowNumber:(NSNumber *)rowNumber
{
    NSInteger clickedRow = rowNumber.integerValue;
    
    GNEOutlineViewItem *item = nil;
    if (clickedRow >= 0 && (item = [self itemAtRow:clickedRow]))
    {
        [self p_cancelClickActions];
        GNEOutlineViewParentItem *parentItem = item.parentItem;
        
        SEL headerSelector = @selector(tableView:didClickHeaderInSection:);
        if (parentItem == nil && [self.tableViewDelegate respondsToSelector:headerSelector])
        {
            NSUInteger section = [self p_sectionForOutlineViewParentItem:(GNEOutlineViewParentItem *)item];
            [self.tableViewDelegate tableView:self didClickHeaderInSection:section];
        }
        
        if (parentItem)
        {
            SEL footerSelector = @selector(tableView:didClickFooterInSection:);
            SEL rowSelector = @selector(tableView:didClickRowAtIndexPath:);
            
            BOOL isFooter = [self p_isOutlineViewItemFooter:item];
            NSIndexPath *indexPath = [self p_indexPathOfOutlineViewItem:item];
            
            if (isFooter && [self.tableViewDelegate respondsToSelector:footerSelector])
            {
                [self.tableViewDelegate tableView:self
                          didClickFooterInSection:indexPath.gne_section];
            }
            else if (isFooter == NO && [self.tableViewDelegate respondsToSelector:rowSelector])
            {
                [self.tableViewDelegate tableView:self didClickRowAtIndexPath:indexPath];
            }
        }
    }
}


- (BOOL)p_shouldDelayClickActionForOutlineViewItem:(GNEOutlineViewItem *)item
{
    if (item == nil)
    {
        return NO;
    }
    
    SEL headerSelector = @selector(tableView:didDoubleClickHeaderInSection:);
    SEL footerSelector = @selector(tableView:didDoubleClickFooterInSection:);
    SEL rowSelector = @selector(tableView:didDoubleClickRowAtIndexPath:);
    
    NSIndexPath *indexPath = [self p_indexPathOfOutlineViewItem:item];
    if ([self isIndexPathHeader:indexPath])
    {
        return ([self.tableViewDelegate respondsToSelector:headerSelector]);
    }
    else if ([self isIndexPathFooter:indexPath])
    {
        return ([self.tableViewDelegate respondsToSelector:footerSelector]);
    }
    else
    {
        return ([self.tableViewDelegate respondsToSelector:rowSelector]);
    }
    
    return NO;
}


- (void)p_cancelClickActions
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}


- (NSArray *)p_selectedIndexPathsInSection:(NSUInteger)section
{
    NSArray *selectedIndexPaths = self.selectedIndexPaths;
    
    NSIndexSet *matchingIndexes = [selectedIndexPaths indexesOfObjectsPassingTest:^BOOL(NSIndexPath *indexPath,
                                                                                        NSUInteger idx __unused,
                                                                                        BOOL *stop __unused)
    {
        return (section == indexPath.gne_section);
    }];
    
    return [selectedIndexPaths objectsAtIndexes:matchingIndexes];
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Internal - Drag-and-drop
// ------------------------------------------------------------------------------------------
- (void)p_registerForDraggedTypes
{
    [self unregisterDraggedTypes];
    
    NSArray *draggedTypes = @[GNEOutlineViewItemPasteboardType];
    
    if ([self.tableViewDataSource respondsToSelector:@selector(draggedTypesForTableView:)])
    {
        NSArray *additionalTypes = [self.tableViewDataSource draggedTypesForTableView:self];
        
        if (additionalTypes.count > 0)
        {
            draggedTypes = [draggedTypes arrayByAddingObjectsFromArray:additionalTypes];
        }
    }
    
    [self registerForDraggedTypes:draggedTypes];
    [self setDraggingSourceOperationMask:(NSDragOperationGeneric | NSDragOperationMove)
                                forLocal:YES];
}


- (void)p_updateDataSourceForDrag:(id <NSDraggingInfo>)info
{
    SEL selector = @selector(tableView:didUpdateDrag:);
    if ([self.tableViewDataSource respondsToSelector:selector])
    {
        [self.tableViewDataSource tableView:self didUpdateDrag:info];
    }
}


- (void)p_collapseDraggedSectionsForOutlineViewItems:(NSArray *)items
{
    for (GNEOutlineViewItem *item in items)
    {
        NSUInteger section = [self p_sectionForOutlineViewParentItem:(GNEOutlineViewParentItem *)item];
        
        if (section == NSNotFound)
        {
            continue;
        }
        
        if ([self isSectionExpanded:section])
        {
            [self.autoCollapsedSections addIndex:section];
            NSArray *indexPaths = [self p_selectedIndexPathsInSection:section];
            [self.selectedAutoCollapsedIndexPaths addObjectsFromArray:indexPaths];
            [self collapseSection:section animated:YES];
        }
    }
}


- (NSDragOperation)p_sectionDragOperationForDrop:(id<NSDraggingInfo>)info
{
    NSDragOperation dragOperation = NSDragOperationNone;
    __block BOOL canDrag = YES;
    
    CGPoint windowPoint = [info draggingLocation];
    CGPoint draggingLocation = [self convertPoint:windowPoint fromView:nil];
    
    NSIndexPath *indexPath = [self indexPathForViewAtPoint:draggingLocation];
    
    if (indexPath == nil)
    {
        return dragOperation;
    }

    // If the cursor is in the bottom half of a section, set the target to be the next section.
    GNEDragLocation dragLocation = [self p_dragLocationForWindowPoint:windowPoint
                                                            inSection:indexPath.gne_section];
    NSUInteger modifier = (dragLocation == GNEDragLocationBottom) ? 1 : 0;
    NSUInteger targetSection = indexPath.gne_section + modifier;
    
    __weak typeof(self) weakSelf = self;
    [info enumerateDraggingItemsWithOptions:0
                                    forView:self
                                    classes:@[[GNEOutlineViewItem class]]
                              searchOptions:@{}
                                 usingBlock:^(NSDraggingItem *draggingItem,
                                              NSInteger idx __unused,
                                              BOOL *stop)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        GNEOutlineViewItem *draggedItem = [strongSelf p_draggedItemForDraggingItem:draggingItem];
        NSIndexPath *fromIndexPath = [self p_indexPathOfOutlineViewItem:draggedItem];

        SEL selector = @selector(tableView:canDragSection:toSection:);
        if (fromIndexPath && [strongSelf.tableViewDataSource respondsToSelector:selector])
        {
            canDrag = [strongSelf.tableViewDataSource tableView:self
                                                 canDragSection:fromIndexPath.gne_section
                                                      toSection:targetSection];
        }
        
        if (canDrag == NO)
        {
            *stop = YES;
        }
    }];
    
    if (canDrag)
    {
        [self setDropItem:nil dropChildIndex:(NSInteger)targetSection];
        dragOperation = NSDragOperationMove;
    }
    
    return dragOperation;
}


- (NSDragOperation)p_rowDragOperationForDrop:(id<NSDraggingInfo>)info
                          proposedParentItem:(GNEOutlineViewItem *)proposedParentItem
                          proposedChildIndex:(NSInteger)proposedChildIndex
{
    NSUInteger toSection = [self p_sectionForOutlineViewParentItem:(GNEOutlineViewParentItem *)proposedParentItem];
    SEL selector = @selector(tableView:canDragRowAtIndexPath:toIndexPath:);
    
    if (proposedChildIndex == NSOutlineViewDropOnItemIndex)
    {
        return [self p_rowDragOperationForDropOnItemDrop:info
                                      proposedParentItem:proposedParentItem];
    }
    // Only allow drags to locations inside sections, not between sections
    else if (toSection != NSNotFound && [self.tableViewDataSource respondsToSelector:selector])
    {
        GNEParameterAssert([proposedParentItem isKindOfClass:[GNEOutlineViewParentItem class]]);
        GNEParameterAssert(toSection < self.outlineViewItems.count);
        
        __block BOOL canDrag = NO;
        
        NSIndexPath *toIndexPath = [self p_targetIndexPathForDragToProposedParentItem:proposedParentItem
                                                                   proposedChildIndex:proposedChildIndex];
        
        if (toIndexPath == nil)
        {
            return NSDragOperationNone;
        }
        
        __weak typeof(self) weakSelf = self;
        [info enumerateDraggingItemsWithOptions:0
                                        forView:self
                                        classes:@[[GNEOutlineViewItem class]]
                                  searchOptions:@{}
                                     usingBlock:^(NSDraggingItem *draggingItem,
                                                  NSInteger idx __unused,
                                                  BOOL *stop)
        {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf == nil)
            {
                canDrag = NO;
                *stop = YES;
                return;
            }
            
            GNEOutlineViewItem *draggedItem = [strongSelf p_draggedItemForDraggingItem:draggingItem];
            NSIndexPath *fromIndexPath = [strongSelf p_indexPathOfOutlineViewItem:draggedItem];
            
            if (fromIndexPath == nil)
            {
                canDrag = NO;
                *stop = YES;
                return;
            }
            
            canDrag = [strongSelf.tableViewDataSource tableView:strongSelf
                                          canDragRowAtIndexPath:fromIndexPath
                                                    toIndexPath:toIndexPath];
            
            if (canDrag == NO)
            {
                *stop = YES;
            }
        }];
        
        return ((canDrag) ? NSDragOperationMove : NSDragOperationNone);
    }
    
    return NSDragOperationNone;
}


- (NSDragOperation)p_rowDragOperationForDropOnItemDrop:(id<NSDraggingInfo>)info
                                    proposedParentItem:(GNEOutlineViewItem *)proposedParentItem
{
    __block BOOL canDropOn = NO;
    
    SEL headerSelector = @selector(tableView:canDropRowAtIndexPath:onHeaderInSection:);
    SEL rowSelector = @selector(tableView:canDropRowAtIndexPath:onRowAtIndexPath:);
    
    GNEOutlineViewParentItem *parentItem = proposedParentItem.parentItem;
    
    __weak typeof(self) weakSelf = self;
    [info enumerateDraggingItemsWithOptions:0
                                    forView:self
                                    classes:@[[GNEOutlineViewItem class]]
                              searchOptions:@{}
                                 usingBlock:^(NSDraggingItem *draggingItem,
                                              NSInteger idx __unused,
                                              BOOL *stop)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil)
        {
            canDropOn = NO;
            *stop = YES;
            return;
        }
        
        GNEOutlineViewItem *draggedItem = [strongSelf p_draggedItemForDraggingItem:draggingItem];
        NSIndexPath *fromIndexPath = [strongSelf p_indexPathOfOutlineViewItem:draggedItem];
        BOOL isFooter = [strongSelf p_isOutlineViewItemFooter:proposedParentItem];
        
        if (fromIndexPath == nil || isFooter)
        {
            canDropOn = NO;
            *stop = YES;
            return;
        }
        
        if (proposedParentItem && parentItem == nil &&
            [strongSelf.tableViewDataSource respondsToSelector:headerSelector])
        {
            GNEOutlineViewParentItem *theParentItem = (GNEOutlineViewParentItem *)proposedParentItem;
            NSUInteger section = [strongSelf p_sectionForOutlineViewParentItem:theParentItem];
            if (section != NSNotFound)
            {
                canDropOn = [strongSelf.tableViewDataSource tableView:strongSelf
                                                canDropRowAtIndexPath:fromIndexPath
                                                    onHeaderInSection:section];
            }
        }
        if (proposedParentItem && parentItem &&
            [strongSelf.tableViewDataSource respondsToSelector:rowSelector])
        {
            NSIndexPath *toIndexPath = [strongSelf p_indexPathOfOutlineViewItem:proposedParentItem];
            if (toIndexPath)
            {
                canDropOn = [strongSelf.tableViewDataSource tableView:strongSelf
                                                canDropRowAtIndexPath:fromIndexPath
                                                     onRowAtIndexPath:toIndexPath];
            }
        }
        
        // If one of the drops has been denied, cancel the drag operation.
        if (canDropOn == NO)
        {
            *stop = YES;
        }
    }];
    
    return ((canDropOn) ? NSDragOperationMove : NSDragOperationNone);
}


- (BOOL)p_performDropOnDragOperationWithProposedParentItem:(GNEOutlineViewItem *)proposedParentItem
                                            fromIndexPaths:(NSArray *)fromIndexPaths
{
    GNEParameterAssert([self p_isOutlineViewItemFooter:proposedParentItem] == NO);
    
    SEL headerSelector = @selector(tableView:didDropRowsAtIndexPaths:onHeaderInSection:);
    SEL rowSelector = @selector(tableView:didDropRowsAtIndexPaths:onRowAtIndexPath:);
    
    GNEOutlineViewParentItem *parentItem = proposedParentItem.parentItem;
    NSIndexPath *toIndexPath = [self p_indexPathOfOutlineViewItem:proposedParentItem];
    
    if (parentItem == nil && [self.tableViewDataSource respondsToSelector:headerSelector])
    {
        [self.tableViewDataSource tableView:self
                    didDropRowsAtIndexPaths:fromIndexPaths
                          onHeaderInSection:toIndexPath.gne_section];
        
        return YES;
    }
    else if (parentItem && toIndexPath && fromIndexPaths.count > 0 &&
             [self.tableViewDataSource respondsToSelector:rowSelector])
    {
        [self.tableViewDataSource tableView:self
                    didDropRowsAtIndexPaths:fromIndexPaths
                           onRowAtIndexPath:toIndexPath];
        
        return YES;
    }
    
    return NO;
}


- (BOOL)p_performSectionDragOperationWithProposedChildIndex:(NSInteger)proposedChildIndex
                                               fromSections:(NSIndexSet *)fromSections
{
    SEL sectionSelector = @selector(tableView:didDragSections:toSection:);
    if (fromSections.count > 0 && [self.tableViewDataSource respondsToSelector:sectionSelector])
    {
        [self.tableViewDataSource tableView:self
                            didDragSections:fromSections
                                  toSection:(NSUInteger)proposedChildIndex];
        
        return YES;
    }
    
    return NO;
}


- (BOOL)p_performRowDragOperationWithProposedParentItem:(GNEOutlineViewParentItem *)proposedParentItem
                                     proposedChildIndex:(NSInteger)proposedChildIndex
                                         fromIndexPaths:(NSArray *)fromIndexPaths
{
    GNEParameterAssert([proposedParentItem isKindOfClass:[GNEOutlineViewParentItem class]]);
    
    NSUInteger toSection = [self p_sectionForOutlineViewParentItem:(GNEOutlineViewParentItem *)proposedParentItem];
    NSIndexPath *toIndexPath = [NSIndexPath gne_indexPathForRow:(NSUInteger)proposedChildIndex
                                                      inSection:toSection];
    
    SEL rowSelector = @selector(tableView:didDragRowsAtIndexPaths:toIndexPath:);
    if (toIndexPath && fromIndexPaths.count > 0 && [self.tableViewDataSource respondsToSelector:rowSelector])
    {
        [self.tableViewDataSource tableView:self
                    didDragRowsAtIndexPaths:fromIndexPaths
                                toIndexPath:toIndexPath];
        
        return YES;
    }
    
    return NO;
}


- (GNEDragType)p_dragTypeForDrop:(id<NSDraggingInfo>)info
{
    __block GNEDragType dragType = GNEDragTypeBoth;
    __block BOOL hasSections = NO;
    __block BOOL hasRows = NO;
    
    __weak typeof(self) weakSelf = self;
    [info enumerateDraggingItemsWithOptions:0
                                    forView:self
                                    classes:@[[GNEOutlineViewItem class]]
                              searchOptions:@{}
                                 usingBlock:^(NSDraggingItem *draggingItem,
                                              NSInteger idx __unused,
                                              BOOL *stop)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf == nil)
        {
            *stop = YES;
            return;
        }
        
        GNEOutlineViewItem *draggedItem = [strongSelf p_draggedItemForDraggingItem:draggingItem];
        
        if (draggedItem.parentItem == nil)
        {
            hasSections = YES;
            dragType = GNEDragTypeSections;
        }
        else
        {
            hasRows = YES;
            dragType = GNEDragTypeRows;
        }
        
        if (hasSections && hasRows)
        {
            dragType = GNEDragTypeBoth;
            *stop = YES;
        }
    }];
    
    return dragType;
}


/**
 Retargets the proposed parent item and/or proposed child index for the specified drag operation if needed.
 Returns YES if the proposed targets were changed, otherwise NO.
 
 @discussion If the user drags a row to a section header, we need to retarget it to the last index in the
 previous section. Additionally, if the user drags the row past the last row, we need to retarget it to 
 the count (last index plus one) of the last section.
 @param info Drag operation
 @param proposedParentItemPtr Pointer to a pointer to an instance of GNEOutlineViewItem or nil.
 @param proposedChildIndexPtr Pointer to the proposedChildIndex integer.
 @return YES if the drop was retargeted, otherwise NO.
 */
- (BOOL)p_retargetDropOnDragOperation:(id<NSDraggingInfo>)info
                 toProposedParentItem:(GNEOutlineViewItem * __autoreleasing *)proposedParentItemPtr
                   proposedChildIndex:(NSInteger *)proposedChildIndexPtr
{
    if (proposedParentItemPtr == NULL || proposedChildIndexPtr == NULL)
    {
        return NO;
    }
    
    GNEOutlineViewItem *proposedParent = *proposedParentItemPtr;
    NSInteger proposedChildIndex = *proposedChildIndexPtr;
    GNEOutlineViewParentItem *parentItem = proposedParent.parentItem;
    if (proposedParent && parentItem == nil)
    {
        GNEParameterAssert([proposedParent isKindOfClass:[GNEOutlineViewParentItem class]]);
        
        GNEOutlineViewParentItem *aParentItem = (GNEOutlineViewParentItem *)proposedParent;
        NSUInteger toSection = [self p_sectionForOutlineViewParentItem:aParentItem];
        
        if (toSection > 0 && toSection != NSNotFound)
        {
            NSUInteger prevSection = toSection - 1;
            GNEOutlineViewParentItem *prevParentItem = [self p_outlineViewParentItemForSection:prevSection];
            GNEParameterAssert(prevParentItem);
            NSUInteger rowCount = [self p_numberOfOutlineViewItemsForOutlineViewParentItem:prevParentItem];
            *proposedParentItemPtr = prevParentItem;
            *proposedChildIndexPtr = (NSInteger)rowCount;
            [self setDropItem:prevParentItem dropChildIndex:proposedChildIndex];
            
            return YES;
        }
    }
    else if (proposedParent && parentItem)
    {
        GNEParameterAssert([proposedParent isMemberOfClass:[GNEOutlineViewItem class]]);
        GNEParameterAssert([parentItem isKindOfClass:[GNEOutlineViewParentItem class]]);
        
        /*
         When a row is dragged past the last row in the table view, the default behavior is to create a "drop on"
         drag operation to the last row. For our purposes, this is always wrong. However, what we want to do
         here depends on whether or not the section has a footer.
         
         If the section does NOT have a footer, we want to be able to drag the row past the last row and
         reorder them. So, we have to do that manually here.
         
         If the section does have a footer, we want to retarget the drop to the first index of the next section,
         if it exists.
         */
        
        BOOL hasFooter = parentItem.hasFooter;
        NSIndexPath *indexPath = [self p_indexPathOfOutlineViewItem:proposedParent];
        CGRect rowFrame = [self frameOfViewAtIndexPath:indexPath];
        NSUInteger proposedParentChildIndex = (indexPath) ? indexPath.gne_row : NSNotFound;
        NSUInteger rowCount = [self p_numberOfOutlineViewItemsForOutlineViewParentItem:parentItem];
        
        if (CGRectEqualToRect(CGRectZero, rowFrame) == NO &&
            proposedParentChildIndex != NSNotFound &&
            rowCount > 0 &&
            proposedParentChildIndex == (rowCount - 1))
        {
            
            if (hasFooter)
            {
                NSUInteger sectionCount = self.outlineViewParentItems.count;
                NSUInteger section = [self p_sectionForOutlineViewParentItem:parentItem];
                NSUInteger nextSection = section + 1;
                if (nextSection < sectionCount) // It's not the last section.
                {
                    GNEOutlineViewParentItem *nextSectionParentItem = self.outlineViewParentItems[nextSection];
                    *proposedParentItemPtr = nextSectionParentItem;
                    *proposedChildIndexPtr = 0;
                    [self setDropItem:nextSectionParentItem dropChildIndex:0];
                }
                else // It's the last section; retarget the drag to the last index before the footer.
                {
                    NSInteger lastRowBeforeFooterIndex = (NSInteger)(proposedParentChildIndex - 1);
                    *proposedParentItemPtr = parentItem;
                    *proposedChildIndexPtr = lastRowBeforeFooterIndex;
                    [self setDropItem:parentItem dropChildIndex:lastRowBeforeFooterIndex];
                }
                
                return YES;
            }
            else
            {
                CGPoint draggingLocation = [info draggingLocation];
                CGPoint convertedDraggingLocation = [self convertPoint:draggingLocation fromView:nil];
                CGFloat bottomThirdOriginY = rowFrame.origin.y + ((2.0f/3.0f) * rowFrame.size.height);
                if (convertedDraggingLocation.y > bottomThirdOriginY)
                {
                    *proposedParentItemPtr = parentItem;
                    *proposedChildIndexPtr = (NSInteger)rowCount;
                    [self setDropItem:parentItem dropChildIndex:(NSInteger)rowCount];
                    
                    return YES;
                }
            }
        }
    }
    
    return NO;
}


- (NSIndexPath *)p_targetIndexPathForDragToProposedParentItem:(GNEOutlineViewItem *)proposedParentItem
                                           proposedChildIndex:(NSInteger)proposedChildIndex
{
    GNEParameterAssert(self.outlineViewParentItems.count == self.outlineViewItems.count);
    
    GNEOutlineViewParentItem *parentItem = (GNEOutlineViewParentItem *)proposedParentItem;
    
    NSUInteger sectionCount = self.outlineViewItems.count;
    NSUInteger toSection = [self p_sectionForOutlineViewParentItem:parentItem];
    
    if (toSection == NSNotFound || toSection >= sectionCount)
    {
        return nil;
    }
    
    NSUInteger rowCount = ((NSArray *)self.outlineViewItems[toSection]).count;
    if (parentItem.hasFooter && (NSUInteger)proposedChildIndex == rowCount)
    {
        NSUInteger nextSection = toSection + 1;
        if (nextSection < sectionCount)
        {
            GNEOutlineViewParentItem *nextParentItem = self.outlineViewParentItems[nextSection];
            [self setDropItem:nextParentItem dropChildIndex:0];
            
            return [NSIndexPath gne_indexPathForRow:0 inSection:nextSection];
        }
        else
        {
            NSInteger previousChildIndex = (proposedChildIndex > 0) ? (NSInteger)(proposedChildIndex - 1) : 0;
            [self setDropItem:parentItem dropChildIndex:previousChildIndex];
            
            return [NSIndexPath gne_indexPathForRow:(NSUInteger)previousChildIndex
                                          inSection:toSection];
        }
    }
    else
    {
        return [NSIndexPath gne_indexPathForRow:(NSUInteger)proposedChildIndex
                                      inSection:toSection];
    }
    
    return nil;
}


- (GNEDragLocation)p_dragLocationForWindowPoint:(CGPoint)windowPoint
                                      inSection:(NSUInteger)section
{
    CGPoint point = [self convertPoint:windowPoint fromView:nil];
    CGRect sectionFrame = [self frameOfSection:section];
    CGFloat convertedOriginY = point.y - sectionFrame.origin.y;
    BOOL isInTopHalf = (convertedOriginY < (sectionFrame.size.height / 2.0));
    
    return ((isInTopHalf) ? GNEDragLocationTop : GNEDragLocationBottom);
}


- (GNEOutlineViewItem *)p_draggedItemForDraggingItem:(NSDraggingItem *)draggingItem
{
    GNEOutlineViewItem *draggedItem = nil;
    
    GNEOutlineViewItem *item = draggingItem.item;
    NSIndexPath *indexPath = item.draggedIndexPath;
    
    if (indexPath)
    {
        draggedItem = [self p_outlineViewItemAtIndexPath:indexPath];
    }
    
    return draggedItem;
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Internal - View
// ------------------------------------------------------------------------------------------
/// Returns an array containing all of the available (makeIfNecessary == NO) cell views
/// for the specified section, including the section header and section footer.
- (NSArray *)p_availableCellViewsForSection:(NSUInteger)section
{
    NSInteger column = self.numberOfColumns - 1;
    if (column < 0)
    {
        return @[];
    }
    
    NSIndexPath *headerIndexPath = [self indexPathForHeaderInSection:section];
    
    BOOL isExpanded = [self isSectionExpanded:section];
    
    NSInteger headerRow = [self tableViewRowForIndexPath:headerIndexPath];
    if (headerRow == -1 || headerRow >= self.numberOfRows)
    {
        return @[];
    }
    
    NSTableCellView *headerCellView = [self viewAtColumn:column
                                                     row:headerRow
                                         makeIfNecessary:NO];
    
    NSMutableArray *cellViews = [NSMutableArray array];
    if (headerCellView)
    {
        [cellViews addObject:headerCellView];
    }
    
    if (isExpanded)
    {
        NSUInteger rowCount = [self numberOfRowsInSection:section];
        
        if (rowCount == NSNotFound || (NSInteger)rowCount >= self.numberOfRows)
        {
            return [NSArray arrayWithArray:cellViews];
        }
        
        for (NSUInteger row = 0; row < rowCount; row++)
        {
            NSIndexPath *indexPath = [NSIndexPath gne_indexPathForRow:row inSection:section];
            
            NSInteger tableViewRow = [self tableViewRowForIndexPath:indexPath];
            
            if (tableViewRow == -1 || tableViewRow >= self.numberOfRows)
            {
                return [NSArray arrayWithArray:cellViews];
            }
            
            NSTableCellView *cellView = [self viewAtColumn:column
                                                       row:tableViewRow
                                           makeIfNecessary:NO];
            
            if (cellView)
            {
                [cellViews addObject:cellView];
            }
        }
    }
    
    return [NSArray arrayWithArray:cellViews];
}


- (NSString *)p_mapKeyForRowView:(NSTableRowView *)rowView
{
    if (rowView)
    {
        return [NSString stringWithFormat:@"%p", rowView];
    }
    
    return nil;
}


- (void)p_updateMapForAvailableRowViews
{
    __weak typeof(self) weakSelf = self;
    [self enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSIndexPath *indexPath = [strongSelf indexPathForTableViewRow:row];
        [strongSelf p_updateMapForRowView:rowView indexPath:indexPath];
    }];
}


- (void)p_updateMapForRowView:(NSTableRowView *)rowView
                    indexPath:(NSIndexPath *)indexPath
{
    BOOL isRowViewValid = ([rowView isKindOfClass:[NSTableRowView class]]);
    
    if (isRowViewValid)
    {
        NSString *key = [self p_mapKeyForRowView:rowView];
        if (indexPath)
        {
            NSIndexPath *value = [indexPath copy];
            self.rowViewToIndexPathMap[key] = value;
        }
        else
        {
            [self.rowViewToIndexPathMap removeObjectForKey:key];
        }
    }
}


- (NSIndexPath *)p_indexPathForRowView:(NSTableRowView *)rowView
{
    if ([rowView isKindOfClass:[NSTableRowView class]])
    {
        NSString *key = [self p_mapKeyForRowView:rowView];
        
        return (NSIndexPath *)self.rowViewToIndexPathMap[key];
    }
    
    return nil;
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Internal - Debug Checks
// ------------------------------------------------------------------------------------------
#if DEBUG
- (void)p_checkDataSourceIntegrity
{
    if (self.isUpdating)
    {
        return;
    }
    
    id dataSource = (id)self.tableViewDataSource;
    
    SEL numberOfSectionsSelector = NSSelectorFromString(@"numberOfSections");
    SEL numberOfRowsSelector = NSSelectorFromString(@"numberOfRows");
    SEL numberOfFootersSelector = NSSelectorFromString(@"numberOfFooters");
    
    if ([dataSource respondsToSelector:numberOfSectionsSelector] == NO ||
        [dataSource respondsToSelector:numberOfRowsSelector] == NO ||
        [dataSource respondsToSelector:numberOfFootersSelector] == NO)
    {
        return;
    }

    NSUInteger (*numberOfSections)(id, SEL) = (NSUInteger (*)(id, SEL))[dataSource methodForSelector:numberOfSectionsSelector];
    NSUInteger (*numberOfRows)(id, SEL) = (NSUInteger (*)(id, SEL))[dataSource methodForSelector:numberOfRowsSelector];
    NSUInteger (*numberOfFooters)(id, SEL) = (NSUInteger (*)(id, SEL))[dataSource methodForSelector:numberOfFootersSelector];

    if (numberOfSections == NULL || numberOfRows == NULL || numberOfFooters == NULL)
    {
        return;
    }

    NSUInteger numberOfSectionsInDataSource = numberOfSections(dataSource, numberOfRowsSelector);
    NSUInteger numberOfSectionsInOutlineView = (NSUInteger)[self p_numberOfSections];
    
    GNEParameterAssert(numberOfSectionsInDataSource == numberOfSectionsInOutlineView);

    NSUInteger numberOfRowsInDataSource = numberOfRows(dataSource, numberOfRowsSelector);
    NSUInteger numberOfFootersInDataSource = numberOfFooters(dataSource, numberOfFootersSelector);
    NSUInteger totalNumberOfRowsInDataSource = numberOfRowsInDataSource + numberOfFootersInDataSource;
    NSUInteger numberOfRowsInOutlineView = [self p_numberOfRowsInOutlineView] - [self p_numberOfSections];
    
    GNEParameterAssert(totalNumberOfRowsInDataSource == numberOfRowsInOutlineView);
}
#else
- (void)p_checkDataSourceIntegrity
{
    
}
#endif


#if DEBUG
- (void)p_checkIndexPathsArray:(NSArray *)indexPaths
{
    for (NSIndexPath *indexPath in indexPaths)
    {
        GNEParameterAssert([indexPath isKindOfClass:[NSIndexPath class]] && indexPath.length == 2);
    }
}
#else
- (void)p_checkIndexPathsArray:(NSArray * __unused)indexPaths
{
    
}
#endif


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
    GNEParameterAssert(parentItem == nil || [parentItem isKindOfClass:[GNEOutlineViewParentItem class]]);
    
    return [self p_outlineViewItemAtIndex:(NSUInteger)index ofParent:parentItem];
}


- (BOOL)outlineView:(NSOutlineView * __unused)outlineView isItemExpandable:(GNEOutlineViewItem *)item
{
    GNEParameterAssert(item == nil || [item isKindOfClass:[GNEOutlineViewItem class]]);
    
    if (item)
    {
        if (item.parentItem == nil)
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
    GNEParameterAssert(item == nil || [item isKindOfClass:[GNEOutlineViewItem class]]);
    
    if (item)
    {
        if (item.parentItem == nil)
        {
            GNEOutlineViewParentItem *parentItem = (GNEOutlineViewParentItem *)item;
            
            return (NSInteger)[self p_numberOfOutlineViewItemsForOutlineViewParentItem:parentItem];
        }
        else // Child objects cannot have children (they are too young!!!).
        {
            return 0;
        }
    }
    
    // Root item has all of the parent items (sections) as children.
    return (NSInteger)self.outlineViewParentItems.count;
}


-           (id)outlineView:(NSOutlineView * __unused)outlineView
  objectValueForTableColumn:(NSTableColumn * __unused)tableColumn
                     byItem:(GNEOutlineViewItem *)item
{
    GNEParameterAssert(item == nil || [item isKindOfClass:[GNEOutlineViewItem class]]);
    
    return item;
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSOutlineViewDelegate - View Size and Appearance
// ------------------------------------------------------------------------------------------
- (CGFloat)outlineView:(NSOutlineView * __unused)outlineView heightOfRowByItem:(GNEOutlineViewItem *)item
{
    GNEParameterAssert([item isKindOfClass:[GNEOutlineViewItem class]]);
    
    GNEOutlineViewParentItem *parentItem = item.parentItem;
    
    // Section header
    if (parentItem == nil)
    {
        NSUInteger section = [self p_sectionForOutlineViewParentItem:(GNEOutlineViewParentItem *)item];
        if (section != NSNotFound &&
            [self p_requestDelegateHasHeaderInSection:section])
        {
            return [self.tableViewDelegate tableView:self heightForHeaderInSection:section];
        }
        
        return GNESectionedTableViewInvisibleRowHeight;
    }
    
    NSUInteger section = [self p_sectionForOutlineViewParentItem:parentItem];
    
    // Section footer
    if ([self p_isOutlineViewItemFooter:item])
    {
        GNEParameterAssert([self.tableViewDelegate
                            respondsToSelector:@selector(tableView:heightForFooterInSection:)]);
        
        return [self.tableViewDelegate tableView:self heightForFooterInSection:section];
    }
    
    // Row
    NSIndexPath *indexPath = [self p_indexPathOfOutlineViewItem:item];
    if (indexPath && [self.tableViewDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)])
    {
        return [self.tableViewDelegate tableView:self heightForRowAtIndexPath:indexPath];
    }
    
    return kDefaultRowHeight;
}


- (BOOL)outlineView:(NSOutlineView * __unused)outlineView isGroupItem:(GNEOutlineViewItem * __unused)item
{
    GNEParameterAssert(item == nil || [item isKindOfClass:[GNEOutlineViewItem class]]);
    
    return NO;
}


- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(GNEOutlineViewItem *)item
{
    GNEParameterAssert(item == nil || [item isKindOfClass:[GNEOutlineViewItem class]]);
    GNEParameterAssert([self.tableViewDelegate respondsToSelector:@selector(tableView:rowViewForRowAtIndexPath:)]);
    
    NSTableRowView *rowView = nil;
    NSIndexPath *indexPath = nil;
    
    GNEOutlineViewParentItem *parentItem = item.parentItem;
    
    // Section header
    if (parentItem == nil)
    {
        NSUInteger section = [self p_sectionForOutlineViewParentItem:(GNEOutlineViewParentItem *)item];
        if (section != NSNotFound)
        {
            indexPath = [self indexPathForHeaderInSection:section];
            
            if ([self p_requestDelegateHasHeaderInSection:section])
            {
                rowView = [self.tableViewDelegate tableView:self rowViewForHeaderInSection:section];
            }
            else
            {
                rowView = [outlineView makeViewWithIdentifier:kOutlineViewStandardHeaderRowViewIdentifier
                                                        owner:outlineView];
                if (rowView == nil)
                {
                    rowView = [[NSTableRowView alloc] initWithFrame:CGRectZero];
                    [rowView setAutoresizingMask:NSViewWidthSizable];
                    rowView.identifier = kOutlineViewStandardHeaderRowViewIdentifier;
                    rowView.backgroundColor = [NSColor clearColor];
                }
            }
        }
    }
    else if ([self p_isOutlineViewItemFooter:item]) // Section footer
    {
        GNEParameterAssert([self.tableViewDelegate
                            respondsToSelector:@selector(tableView:rowViewForFooterInSection:)]);
        
        NSUInteger section = [self p_sectionForOutlineViewParentItem:parentItem];
        GNEParameterAssert(section != NSNotFound);
        
        if (section != NSNotFound)
        {
            indexPath = [self indexPathForFooterInSection:section];
            rowView = [self.tableViewDelegate tableView:self
                              rowViewForFooterInSection:section];
            GNEParameterAssert(rowView);
        }
    }
    else // Row
    {
        indexPath = [self p_indexPathOfOutlineViewItem:item];
        if (indexPath)
        {
            rowView = [self.tableViewDelegate tableView:self rowViewForRowAtIndexPath:indexPath];
        }
    }
    
    [self p_updateMapForRowView:rowView indexPath:indexPath];
    
    return rowView;
}


- (NSView *)outlineView:(NSOutlineView * __unused)outlineView
     viewForTableColumn:(NSTableColumn * __unused)tableColumn
                   item:(GNEOutlineViewItem *)item
{
    GNEParameterAssert(item == nil || [item isKindOfClass:[GNEOutlineViewItem class]]);
    GNEParameterAssert([self.tableViewDataSource respondsToSelector:@selector(tableView:cellViewForRowAtIndexPath:)]);
    
    GNEOutlineViewParentItem *parentItem = item.parentItem;
    
    // Section header
    if (parentItem == nil)
    {
        NSUInteger section = [self p_sectionForOutlineViewParentItem:(GNEOutlineViewParentItem *)item];
        if (section != NSNotFound && [self p_requestDelegateHasHeaderInSection:section])
        {
            return [self.tableViewDelegate tableView:self cellViewForHeaderInSection:section];
        }
        
        return nil;
    }
    
    // Section footer
    if ([self p_isOutlineViewItemFooter:item])
    {
        GNEParameterAssert([self.tableViewDelegate
                            respondsToSelector:@selector(tableView:cellViewForFooterInSection:)]);
        
        NSUInteger section = [self p_sectionForOutlineViewParentItem:parentItem];
        GNEParameterAssert(section != NSNotFound);
        
        if (section != NSNotFound)
        {
            return [self.tableViewDelegate tableView:self cellViewForFooterInSection:section];
        }
        
        return nil;
    }
    
    // Row
    NSIndexPath *indexPath = [self p_indexPathOfOutlineViewItem:item];
    if (indexPath)
    {
        return [self.tableViewDelegate tableView:self cellViewForRowAtIndexPath:indexPath];
    }
    
    return nil;
}


- (void)outlineView:(NSOutlineView * __unused)outlineView
      didAddRowView:(NSTableRowView *)rowView
             forRow:(NSInteger)row
{
    GNEParameterAssert([NSThread isMainThread]); // NSDictionary isn't threadsafe.
    
    NSIndexPath *indexPath = [self indexPathForTableViewRow:row];
    
    if (indexPath == nil)
    {
        return;
    }
    
    [self p_updateMapForRowView:rowView indexPath:indexPath];
    
    SEL headerSelector = @selector(tableView:didDisplayRowView:forHeaderInSection:);
    SEL footerSelector = @selector(tableView:didDisplayRowView:forFooterInSection:);
    SEL rowSelector = @selector(tableView:didDisplayRowView:forRowAtIndexPath:);
    
    BOOL isHeader = [self isIndexPathHeader:indexPath];
    BOOL isFooter = [self isIndexPathFooter:indexPath];
    
    // Can't be both a header and a footer.
    GNEParameterAssert((isHeader && isFooter) == NO);
    
    if (isHeader && [self.tableViewDelegate respondsToSelector:headerSelector])
    {
        [self.tableViewDelegate tableView:self
                        didDisplayRowView:rowView
                       forHeaderInSection:indexPath.gne_section];
    }
    else if (isFooter && [self.tableViewDelegate respondsToSelector:footerSelector])
    {
        [self.tableViewDelegate tableView:self
                        didDisplayRowView:rowView
                       forFooterInSection:indexPath.gne_section];
    }
    else if (isHeader == NO && isFooter == NO &&
             [self.tableViewDelegate respondsToSelector:rowSelector])
    {
        [self.tableViewDelegate tableView:self
                        didDisplayRowView:rowView
                        forRowAtIndexPath:indexPath];
    }
}


- (void)outlineView:(NSOutlineView * __unused)outlineView
   didRemoveRowView:(NSTableRowView *)rowView
             forRow:(NSInteger __unused)row
{
    GNEParameterAssert([NSThread isMainThread]);
    
    NSIndexPath *indexPath = [self p_indexPathForRowView:rowView];
    [self p_updateMapForRowView:rowView indexPath:nil];
    
    if (indexPath == nil)
    {
        return;
    }
    
    SEL headerSelector = @selector(tableView:didEndDisplayingRowView:forHeaderInSection:);
    SEL footerSelector = @selector(tableView:didEndDisplayingRowView:forFooterInSection:);
    SEL rowSelector = @selector(tableView:didEndDisplayingRowView:forRowAtIndexPath:);
    
    BOOL isHeader = [self isIndexPathHeader:indexPath];
    BOOL isFooter = [self isIndexPathFooter:indexPath];
    
    // Can't be both a header and a footer.
    GNEParameterAssert((isHeader && isFooter) == NO);
    
    if (isHeader && [self.tableViewDelegate respondsToSelector:headerSelector])
    {
        [self.tableViewDelegate tableView:self
                  didEndDisplayingRowView:rowView
                       forHeaderInSection:indexPath.gne_section];
    }
    else if (isFooter && [self.tableViewDelegate respondsToSelector:footerSelector])
    {
        [self.tableViewDelegate tableView:self
                  didEndDisplayingRowView:rowView
                       forFooterInSection:indexPath.gne_section];
    }
    else if (isHeader == NO && isFooter == NO &&
             [self.tableViewDelegate respondsToSelector:rowSelector])
    {
        [self.tableViewDelegate tableView:self
                  didEndDisplayingRowView:rowView
                        forRowAtIndexPath:indexPath];
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSOutlineViewDelegate - Expand/Collapse
// ------------------------------------------------------------------------------------------
- (BOOL)outlineView:(NSOutlineView * __unused)outlineView shouldExpandItem:(GNEOutlineViewItem *)item
{
    GNEParameterAssert([item isKindOfClass:[GNEOutlineViewItem class]]);
    
    // Don't allow rows or footers to be expanded.
    if (item.parentItem)
    {
        return NO;
    }
    
    NSUInteger section = [self p_sectionForOutlineViewParentItem:(GNEOutlineViewParentItem *)item];
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:shouldExpandSection:)] &&
        section != NSNotFound)
    {
        return [self.tableViewDelegate tableView:self shouldExpandSection:section];
    }
    
    return YES;
}


- (BOOL)outlineView:(NSOutlineView * __unused)outlineView shouldCollapseItem:(GNEOutlineViewItem *)item
{
    GNEParameterAssert([item isKindOfClass:[GNEOutlineViewItem class]]);
    
    // Don't allow rows or footers to be collapsed.
    if (item.parentItem)
    {
        return NO;
    }
    
    NSUInteger section = [self p_sectionForOutlineViewParentItem:(GNEOutlineViewParentItem *)item];
    if ([self.tableViewDelegate respondsToSelector:@selector(tableView:shouldCollapseSection:)] &&
        section != NSNotFound)
    {
        return [self.tableViewDelegate tableView:self shouldCollapseSection:section];
    }
    
    return YES;
}


- (void)outlineViewItemWillExpand:(NSNotification *)notification
{
    NSUInteger section = [self p_sectionForExpandCollapseNotification:notification];
    
    SEL selector = @selector(tableView:willExpandSection:);
    if (section != NSNotFound && [self.tableViewDelegate respondsToSelector:selector])
    {
        [self.tableViewDelegate tableView:self willExpandSection:section];
    }
}


- (void)outlineViewItemWillCollapse:(NSNotification *)notification
{
    NSUInteger section = [self p_sectionForExpandCollapseNotification:notification];
    
    SEL selector = @selector(tableView:willCollapseSection:);
    if (section != NSNotFound && [self.tableViewDelegate respondsToSelector:selector])
    {
        [self.tableViewDelegate tableView:self willCollapseSection:section];
    }
}


- (void)outlineViewItemDidExpand:(NSNotification *)notification
{
    NSUInteger section = [self p_sectionForExpandCollapseNotification:notification];
    
    SEL selector = @selector(tableView:didExpandSection:);
    if (section != NSNotFound && [self.tableViewDelegate respondsToSelector:selector])
    {
        [self.tableViewDelegate tableView:self didExpandSection:section];
    }
}


- (void)outlineViewItemDidCollapse:(NSNotification *)notification
{
    NSUInteger section = [self p_sectionForExpandCollapseNotification:notification];
    
    SEL selector = @selector(tableView:didCollapseSection:);
    if (section != NSNotFound && [self.tableViewDelegate respondsToSelector:selector])
    {
        [self.tableViewDelegate tableView:self didCollapseSection:section];
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSOutlineViewDelegate - Selection
// ------------------------------------------------------------------------------------------
/**
 This method is messy because it calls the delegate's shouldSelectHeader and shouldSelectRow methods
 when determining the allowable selections. Rows corresponding to footers are removed from the proposed
 selection indexes because footers are not selectable.
 
 Because this method is implemented, outlineView:shouldSelectItem: will never be called.
 */
-           (NSIndexSet *)outlineView:(NSOutlineView * __unused)outlineView
 selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes
{
    SEL selector = @selector(tableView:proposedSelectedHeadersInSections:proposedSelectedRowIndexPaths:);
    
    SEL headerSelector = @selector(tableView:shouldSelectHeaderInSection:);
    SEL rowSelector = @selector(tableView:shouldSelectRowAtIndexPath:);
    
    // Convert all table view row indexes into section indexes and/or row index paths.
    NSMutableIndexSet *mutableHeaderIndexes = [NSMutableIndexSet indexSet];
    NSMutableArray *mutableIndexPaths = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    [proposedSelectionIndexes enumerateIndexesUsingBlock:^(NSUInteger tableViewRow,
                                                           BOOL *stop __unused)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil)
        {
            return;
        }
        
        id <GNESectionedTableViewDelegate> tableViewDelegate = strongSelf.tableViewDelegate;
        
        NSIndexPath *indexPath = [strongSelf indexPathForTableViewRow:(NSInteger)tableViewRow];
        
        // Skip nil index paths and footer index paths.
        if (indexPath == nil || [strongSelf isIndexPathFooter:indexPath])
        {
            return;
        }
        
        // Section header
        if ([strongSelf isIndexPathHeader:indexPath])
        {
            BOOL addHeader = YES;
            if ([tableViewDelegate respondsToSelector:headerSelector])
            {
                addHeader = [tableViewDelegate tableView:strongSelf
                             shouldSelectHeaderInSection:indexPath.gne_section];
            }
            
            if (addHeader)
            {
                [mutableHeaderIndexes addIndex:indexPath.gne_section];
            }
        }
        else // Row index path
        {
            BOOL addRow = YES;
            if ([tableViewDelegate respondsToSelector:rowSelector])
            {
                addRow = [tableViewDelegate tableView:strongSelf shouldSelectRowAtIndexPath:indexPath];
            }
            
            if (addRow)
            {
                [mutableIndexPaths addObject:indexPath];
            }
        }
    }];
    
    NSIndexSet *proposedHeaderIndexes = [mutableHeaderIndexes copy];
    NSArray *proposedIndexPaths = [mutableIndexPaths copy];
    
    // If the delegate implements tableView:proposedSelectedHeadersInSections:proposedSelectedRowIndexPaths:
    // then send it the proposals and act on the return values. If the delegate doesn't implement the method
    // use the values we calculated based on its responses to the previous queries.
    if ([self.tableViewDelegate respondsToSelector:selector])
    {
        [self.tableViewDelegate tableView:self
        proposedSelectedHeadersInSections:&proposedHeaderIndexes
            proposedSelectedRowIndexPaths:&proposedIndexPaths];
    }
    
    // Re-transform the approved section indexes and index paths into table view row indexes.
    NSMutableIndexSet *approvedSelectionIndexes = [NSMutableIndexSet indexSet];
    
    if (proposedHeaderIndexes && proposedHeaderIndexes.count > 0)
    {
        NSIndexSet *approvedSectionHeaders = [self
                                              p_indexSetOfSectionHeadersAtTableViewRows:proposedHeaderIndexes];
        [approvedSelectionIndexes addIndexes:approvedSectionHeaders];
    }
    
    if (proposedIndexPaths && proposedIndexPaths.count > 0)
    {
        NSArray *rowIndexPaths = [self p_indexPathsByRemovingHeadersAndFootersFromIndexPaths:proposedIndexPaths];
        
        NSIndexSet *approvedRowIndexes = [self p_indexSetOfTableViewRowsForIndexPaths:rowIndexPaths];
        
        [approvedSelectionIndexes addIndexes:approvedRowIndexes];
    }
    
    return ((approvedSelectionIndexes.count > 0) ? [approvedSelectionIndexes copy] : nil);
}


- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    if ([self isEqual:notification.object] == NO)
    {
        return;
    }
    
    NSIndexSet *selectedRows = self.selectedRowIndexes;
    
    SEL deselectSelector = @selector(tableViewDidDeselectAllHeadersAndRows:);
    SEL selectHeaderSelector = @selector(tableView:didSelectHeaderInSection:);
    SEL selectRowSelector = @selector(tableView:didSelectRowAtIndexPath:);
    SEL selectHeadersSelector = @selector(tableView:didSelectHeadersInSections:);
    SEL selectRowsSelector = @selector(tableView:didSelectRowsAtIndexPaths:);
    
    if (selectedRows.count == 0 &&
        [self.tableViewDelegate respondsToSelector:deselectSelector])
    {
        [self.tableViewDelegate tableViewDidDeselectAllHeadersAndRows:self];
    }
    else if (selectedRows.count == 1)
    {
        GNEOutlineViewItem *item = [self itemAtRow:(NSInteger)selectedRows.firstIndex];
        GNEOutlineViewParentItem *parentItem = item.parentItem;
        if (parentItem == nil && [self.tableViewDelegate respondsToSelector:selectHeaderSelector])
        {
            GNEParameterAssert([item isKindOfClass:[GNEOutlineViewParentItem class]]);
            NSUInteger section = [self p_sectionForOutlineViewParentItem:(GNEOutlineViewParentItem *)item];
            [self.tableViewDelegate tableView:self didSelectHeaderInSection:section];
        }
        else if (parentItem && [self.tableViewDelegate respondsToSelector:selectRowSelector])
        {
            NSIndexPath *indexPath = [self p_indexPathOfOutlineViewItem:item];
            [self.tableViewDelegate tableView:self didSelectRowAtIndexPath:indexPath];
        }
    }
    else
    {
        NSIndexSet *sectionHeaders = [self p_indexSetOfSectionHeadersAtTableViewRows:selectedRows];
        if (sectionHeaders.count > 0 && [self.tableViewDelegate respondsToSelector:selectHeadersSelector])
        {
            [self.tableViewDelegate tableView:self didSelectHeadersInSections:sectionHeaders];
        }
        
        NSArray *rowIndexPaths = [self p_indexPathsOfRowsAtTableViewRows:selectedRows];
        if (rowIndexPaths.count > 0 && [self.tableViewDelegate respondsToSelector:selectRowsSelector])
        {
            [self.tableViewDelegate tableView:self didSelectRowsAtIndexPaths:rowIndexPaths];
        }
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSOutlineViewDataSource - Drag-and-drop
// ------------------------------------------------------------------------------------------
- (id<NSPasteboardWriting>)outlineView:(NSOutlineView * __unused)outlineView
               pasteboardWriterForItem:(GNEOutlineViewItem *)item
{
    GNEParameterAssert([item isKindOfClass:[GNEOutlineViewItem class]]);
    
    // Footers are never draggable.
    if ([self p_isOutlineViewItemFooter:item])
    {
        return nil;
    }
    
    BOOL canDrag = NO;
    
    GNEOutlineViewParentItem *parentItem = item.parentItem;
    if (parentItem == nil &&
        [self.tableViewDataSource respondsToSelector:@selector(tableView:canDragSection:)])
    {
        GNEParameterAssert([item isKindOfClass:[GNEOutlineViewParentItem class]]);
        
        NSUInteger section = [self p_sectionForOutlineViewParentItem:(GNEOutlineViewParentItem *)item];
        canDrag = [self.tableViewDataSource tableView:self canDragSection:section];
    }
    else if (parentItem &&
             [self.tableViewDataSource respondsToSelector:@selector(tableView:canDragRowAtIndexPath:)])
    {
        NSIndexPath *indexPath = [self p_indexPathOfOutlineViewItem:item];
        canDrag = [self.tableViewDataSource tableView:self canDragRowAtIndexPath:indexPath];
    }
    
    return ((canDrag) ? item : nil);
}


- (void)outlineView:(NSOutlineView *)outlineView
    draggingSession:(NSDraggingSession *)session
   willBeginAtPoint:(NSPoint __unused)screenPoint
           forItems:(NSArray *)draggedItems
{
    SEL selector = @selector(tableViewDraggingSessionWillBegin:);
    if ([self.tableViewDataSource respondsToSelector:selector])
    {
        [self.tableViewDataSource tableViewDraggingSessionWillBegin:self];
    }
    
    [self p_collapseDraggedSectionsForOutlineViewItems:draggedItems];
    
    self.currentMove = [[GNESectionedTableViewMove alloc] initWithTableView:self];
    __weak typeof(self) weakSelf = self;
    self.currentMove.completion = ^()
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf p_updateMapForAvailableRowViews];
    };
    self.currentMove.indexPathsToSelect = self.selectedAutoCollapsedIndexPaths;
    
    session.draggingFormation = NSDraggingFormationNone;
    CGPoint draggingLocation = session.draggingLocation;
    CGRect screenDraggingLocation = CGRectMake(draggingLocation.x, draggingLocation.y, 0.0f, 0.0f);
    CGRect windowDraggingLocation = [outlineView.window convertRectFromScreen:screenDraggingLocation];
    CGPoint convertedDraggingLocation = [outlineView.superview convertPoint:windowDraggingLocation.origin
                                                                   fromView:nil];
    
    [session enumerateDraggingItemsWithOptions:0
                                       forView:outlineView
                                       classes:@[[GNEOutlineViewItem class]]
                                 searchOptions:@{}
                                    usingBlock:^(NSDraggingItem *draggingItem,
                                                 NSInteger idx,
                                                 BOOL *stop __unused)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil)
        {
            return;
        }
        
        GNEOutlineViewItem *item = draggingItem.item;
        NSInteger column = [outlineView columnWithIdentifier:kOutlineViewStandardColumnIdentifier];
        NSIndexPath *indexPath = item.draggedIndexPath;
        GNEOutlineViewItem *draggedItem = [strongSelf p_outlineViewItemAtIndexPath:indexPath];
        NSInteger row = [strongSelf rowForItem:draggedItem];
        
        if ([item isKindOfClass:[GNEOutlineViewItem class]] && column >= 0 && row >= 0)
        {
            NSTableRowView *rowView = [outlineView rowViewAtRow:row makeIfNecessary:YES];
            NSTableCellView *cellView = [outlineView viewAtColumn:column row:row makeIfNecessary:YES];
            
            // Create the custom move dragging item.
            GNESectionedTableViewMovingItem *movingItem = [[GNESectionedTableViewMovingItem alloc]
                                                           initWithTableCellView:cellView
                                                           frame:rowView.frame
                                                           indexPath:indexPath];
            [strongSelf.currentMove addMovingItem:movingItem];
            
            // Give the system dragging items the correct appearance.
            draggingItem.imageComponentsProvider = ^ NSArray * ()
            {
                return cellView.draggingImageComponents;
            };
            CGRect draggingFrame = draggingItem.draggingFrame;
            // Center the cell over the cursor.
             CGFloat originY = ceil(convertedDraggingLocation.y - (cellView.bounds.size.height / 2.0));
            // Stack the dragging items on top of each other.
            originY += ceil(idx * cellView.bounds.size.height);
            draggingFrame.origin.y = originY;
            
            draggingItem.draggingFrame = draggingFrame;
        }
    }];
}


- (NSDragOperation)outlineView:(NSOutlineView * __unused)outlineView
                  validateDrop:(id<NSDraggingInfo>)info
                  proposedItem:(GNEOutlineViewItem *)proposedParentItem
            proposedChildIndex:(NSInteger)proposedChildIndex
{
    NSDragOperation dragOperation = NSDragOperationNone;
    GNEDragType dragType = [self p_dragTypeForDrop:info];
    
    // If both sections and rows are selected, the drop is invalid.
    if (dragType == GNEDragTypeBoth)
    {
        return dragOperation;
    }
    
    if (dragType == GNEDragTypeSections)
    {
        dragOperation = [self p_sectionDragOperationForDrop:info];
    }
    else
    {
        // Retarget "drop on" drags that target section headers.
        if (proposedChildIndex == NSOutlineViewDropOnItemIndex)
        {
            [self p_retargetDropOnDragOperation:info
                           toProposedParentItem:&proposedParentItem
                             proposedChildIndex:&proposedChildIndex];
        }
        
        dragOperation = [self p_rowDragOperationForDrop:info
                                     proposedParentItem:proposedParentItem
                                     proposedChildIndex:proposedChildIndex];
    }
    
    [self p_updateDataSourceForDrag:info];
    
    return dragOperation;
}


- (BOOL)outlineView:(NSOutlineView * __unused)outlineView
         acceptDrop:(id<NSDraggingInfo>)info
               item:(GNEOutlineViewItem *)proposedParentItem
         childIndex:(NSInteger)proposedChildIndex
{
    NSMutableIndexSet *fromSections = [NSMutableIndexSet indexSet];
    NSMutableArray *fromIndexPaths = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    [info enumerateDraggingItemsWithOptions:0
                                    forView:self
                                    classes:@[[GNEOutlineViewItem class]]
                              searchOptions:@{}
                                 usingBlock:^(NSDraggingItem *draggingItem,
                                              NSInteger idx __unused,
                                              BOOL *stop __unused)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        GNEOutlineViewItem *draggedItem = [strongSelf p_draggedItemForDraggingItem:draggingItem];
        
        if (draggedItem)
        {
            GNEOutlineViewParentItem *parentItem = draggedItem.parentItem;
            if (parentItem == nil)
            {
                GNEParameterAssert([draggedItem isKindOfClass:[GNEOutlineViewParentItem class]]);
                
                GNEOutlineViewParentItem *aParentItem = (GNEOutlineViewParentItem *)draggedItem;
                NSUInteger section = [strongSelf p_sectionForOutlineViewParentItem:aParentItem];
                [fromSections addIndex:section];
            }
            else
            {
                NSIndexPath *indexPath = [strongSelf p_indexPathOfOutlineViewItem:draggedItem];
                [fromIndexPaths addObject:indexPath];
            }
        }
    }];
    
    BOOL success = NO;
    if (proposedChildIndex == NSOutlineViewDropOnItemIndex) // Drop on
    {
        success = [self p_performDropOnDragOperationWithProposedParentItem:proposedParentItem
                                                            fromIndexPaths:fromIndexPaths];
    }
    else if (proposedParentItem == nil) // Move items to the specified section.
    {
        success = [self p_performSectionDragOperationWithProposedChildIndex:proposedChildIndex
                                                               fromSections:fromSections];
    }
    else // Calculate the destination index path and move the items there.
    {
        GNEOutlineViewParentItem *aParentItem = (GNEOutlineViewParentItem *)proposedParentItem;
        success = [self p_performRowDragOperationWithProposedParentItem:aParentItem
                                                     proposedChildIndex:proposedChildIndex
                                                         fromIndexPaths:fromIndexPaths];
    }
    
    return success;
}


- (void)outlineView:(NSOutlineView * __unused)outlineView
    draggingSession:(NSDraggingSession * __unused)session
       endedAtPoint:(NSPoint __unused)screenPoint
          operation:(NSDragOperation __unused)operation
{
    SEL selector = @selector(tableViewDraggingSessionDidEnd:);
    if ([self.tableViewDataSource respondsToSelector:selector])
    {
        [self.tableViewDataSource tableViewDraggingSessionDidEnd:self];
    }
    
    [self.autoCollapsedSections removeIndexes:self.currentMove.autoCollapsedSections];
    [self expandSections:self.autoCollapsedSections animated:YES];
    // Only reselect the index paths if the move was cancelled.
    if (operation == NSDragOperationNone)
    {
        [self selectRowsAtIndexPaths:self.selectedAutoCollapsedIndexPaths
                byExtendingSelection:YES];
    }
    
    
    [self.selectedAutoCollapsedIndexPaths removeAllObjects];
    [self.autoCollapsedSections removeAllIndexes];
    
    self.currentMove = nil;
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSDraggingSource
// ------------------------------------------------------------------------------------------
- (void)draggingSession:(NSDraggingSession * __unused)session
           movedToPoint:(NSPoint __unused)screenPoint
{
    
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNEOutlineViewItemPasteboardWritingDelegate
// ------------------------------------------------------------------------------------------
- (NSIndexPath *)draggedIndexPathForOutlineViewItem:(GNEOutlineViewItem *)item
{
    if (item)
    {
        return [self p_indexPathOfOutlineViewItem:item];
    }
    
    return nil;
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSOutlineView - Table Columns
// ------------------------------------------------------------------------------------------
- (void)p_sizeStandardTableColumnToFit
{
    NSTableColumn *standardColumn = nil;
    if ((standardColumn = [self tableColumnWithIdentifier:kOutlineViewStandardColumnIdentifier]))
    {
        [standardColumn setWidth:self.bounds.size.width];
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableView - Accessors
// ------------------------------------------------------------------------------------------
- (void)setTableViewDataSource:(id<GNESectionedTableViewDataSource>)tableViewDataSource
{
    GNEParameterAssert(tableViewDataSource == nil ||
                       [tableViewDataSource conformsToProtocol:@protocol(GNESectionedTableViewDataSource)]);
    
    if (_tableViewDataSource != tableViewDataSource)
    {
        _tableViewDataSource = tableViewDataSource;
    }
}


- (void)setTableViewDelegate:(id<GNESectionedTableViewDelegate>)tableViewDelegate
{
    GNEParameterAssert(tableViewDelegate == nil ||
                       [tableViewDelegate conformsToProtocol:@protocol(GNESectionedTableViewDelegate)]);
    
    if (_tableViewDelegate != tableViewDelegate)
    {
        _tableViewDelegate = tableViewDelegate;
        [self p_registerForDraggedTypes];
    }
}


- (BOOL)isUpdating
{
    return (self.updateCount > 0);
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
