//
//  GNESectionedTableViewMove.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 12/22/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

#import "GNESectionedTableViewMove.h"
#import "GNESectionedTableView.h"
#import "GNESectionedTableViewDraggingItem.h"


// ------------------------------------------------------------------------------------------


typedef BOOL(^TestPredicate)(GNESectionedTableViewDraggingItem *draggingItem, NSUInteger index __unused, BOOL *stop __unused);

typedef void(^RowAnimationBlock)(NSIndexPath *fromIndexPath, NSUInteger indexPathIndex, BOOL *stop __unused);

typedef void(^CompletionBlock)();


// ------------------------------------------------------------------------------------------


@interface GNESectionedTableViewMove ()

@property (nonatomic, weak, readwrite) GNESectionedTableView *tableView;
@property (nonatomic, strong) NSMutableSet *mutableDraggingItems;

@end


// ------------------------------------------------------------------------------------------


@implementation GNESectionedTableViewMove


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
- (instancetype)initWithTableView:(GNESectionedTableView *)tableView
{
    if ((self = [super init]))
    {
        _tableView = tableView;
        _mutableDraggingItems = [NSMutableSet set];
    }
    
    return self;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Public - Adding Dragging Items
// ------------------------------------------------------------------------------------------
- (void)addDraggingItem:(GNESectionedTableViewDraggingItem *)draggingItem
{
    if (draggingItem)
    {
        [self.mutableDraggingItems addObject:draggingItem];
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - Public - Move
// ------------------------------------------------------------------------------------------
- (void)moveSections:(GNESections)fromSections toSections:(GNESections)toSections
{
    GNEParameterAssert(fromSections.count == toSections.count);
    
    NSIndexSet *deletedSections = [self p_indexSetForSections:fromSections];
    NSIndexSet *insertedSections = [self p_indexSetForSections:toSections];
    
    [self p_animateDeletionOfSections:deletedSections insertionOfSections:insertedSections];
    
}


- (void)moveRowsAtIndexPaths:(NSArray *)fromIndexPaths toIndexPaths:(NSArray *)toIndexPaths
{
    GNEParameterAssert(fromIndexPaths.count == toIndexPaths.count);
    
    if (fromIndexPaths.count != toIndexPaths.count ||
        fromIndexPaths.count == 0)
    {
        return;
    }
    
    [self p_animateDeletionOfRowsAtIndexPaths:fromIndexPaths
                  insertionOfRowsAtIndexPaths:toIndexPaths];

    [self p_animateMoveOfDraggingItemsAtIndexPaths:fromIndexPaths
                                      toIndexPaths:toIndexPaths];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Private - Moving
// ------------------------------------------------------------------------------------------
- (void)p_animateDeletionOfSections:(NSIndexSet *)deletedIndexes
                insertionOfSections:(NSIndexSet *)insertedIndexes
{
    GNESectionedTableView *tableView = self.tableView;
    
    GNEParameterAssert(tableView);
    GNEParameterAssert(deletedIndexes.count == insertedIndexes.count);
    
    NSArray *indexPathsToSelect = [self p_indexPathsOfSelectedRowsInSections:deletedIndexes];
    
    [tableView beginUpdates];
    [tableView deleteSections:deletedIndexes withAnimation:NSTableViewAnimationEffectGap];
    [tableView insertSections:insertedIndexes withAnimation:NSTableViewAnimationEffectGap];
    [tableView endUpdates];
    
    [tableView selectRowsAtIndexPaths:indexPathsToSelect byExtendingSelection:YES];
}


- (void)p_animateDeletionOfRowsAtIndexPaths:(NSArray *)deletedIndexPaths
                insertionOfRowsAtIndexPaths:(NSArray *)insertedIndexPaths
{
    GNESectionedTableView *tableView = self.tableView;
    
    GNEParameterAssert(tableView);
    GNEParameterAssert(deletedIndexPaths.count == insertedIndexPaths.count);
    
    NSIndexSet *selectedIndexPathIndexes = [self p_indexSetOfSelectedRowInFromIndexPaths:deletedIndexPaths];
    
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:deletedIndexPaths withAnimation:NSTableViewAnimationEffectGap];
    [tableView insertRowsAtIndexPaths:insertedIndexPaths withAnimation:NSTableViewAnimationEffectGap];
    [tableView endUpdates];
    
    [self p_selectRowsMovedToIndexPaths:insertedIndexPaths atIndexes:selectedIndexPathIndexes];
}


- (void)p_animateMoveOfDraggingItemsInSections:(GNESections)fromSections
                                    toSections:(GNESections)toSections
{
    GNEParameterAssert(fromSections.count == toSections.count);
    
    if (fromSections.count != toSections.count)
    {
        return;
    }
    
    NSArray *fromIndexPaths = [self p_indexPathsForSections:fromSections];
    NSArray *toIndexPaths = [self p_indexPathsForSections:toSections];
    
    
}


- (void)p_animateMoveOfDraggingItemsAtIndexPaths:(NSArray *)fromIndexPaths
                                    toIndexPaths:(NSArray *)toIndexPaths
{
    GNESectionedTableView *tableView = self.tableView;
    
    GNEParameterAssert(tableView);
    GNEParameterAssert(fromIndexPaths.count == toIndexPaths.count);
    
    if (fromIndexPaths.count != toIndexPaths.count)
    {
        return;
    }
    
    RowAnimationBlock block = [self p_rowAnimationBlockWithTargetIndexPaths:toIndexPaths];
    NSArray *draggingItems = self.draggingItems;
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context)
    {
        context.duration = 0.19;
        [fromIndexPaths enumerateObjectsUsingBlock:block];
    } completionHandler:^()
    {
        for (GNESectionedTableViewDraggingItem *draggingItem in draggingItems)
        {
            [draggingItem.view removeFromSuperview];
        }
    }];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Private - Selection
// ------------------------------------------------------------------------------------------
- (NSArray *)p_indexPathsOfSelectedRowsInSections:(NSIndexSet *)sections
{
    GNESectionedTableView *tableView = self.tableView;
    
    NSArray *selectedIndexPaths = tableView.selectedIndexPaths;
    
    NSIndexSet *indexes = [selectedIndexPaths indexesOfObjectsPassingTest:^BOOL(NSIndexPath *indexPath,
                                                                                NSUInteger idx __unused,
                                                                                BOOL *stop __unused)
    {
        NSUInteger section = indexPath.gne_section;
        
        return ([sections containsIndex:section]);
    }];
    
    if (indexes.count > 0)
    {
        return [selectedIndexPaths objectsAtIndexes:indexes];
    }
    
    return @[];
}


- (NSIndexSet *)p_indexSetOfSelectedRowInFromIndexPaths:(NSArray *)fromIndexPaths
{
    GNESectionedTableView *tableView = self.tableView;
    NSMutableIndexSet *mutableIndexSet = [NSMutableIndexSet indexSet];
    
    NSUInteger count = fromIndexPaths.count;
    for (NSUInteger i = 0; i < count; i++)
    {
        NSIndexPath *indexPath = fromIndexPaths[i];
        BOOL isSelected = [tableView isIndexPathSelected:indexPath];
        if (isSelected)
        {
            [mutableIndexSet addIndex:i];
        }
    }
    
    return [mutableIndexSet copy];
}


- (void)p_selectRowsMovedToIndexPaths:(NSArray *)toIndexPaths atIndexes:(NSIndexSet *)indexes
{
    if (indexes.count > 0)
    {
        NSArray *selectedIndexPaths = [toIndexPaths objectsAtIndexes:indexes];
        [self.tableView selectRowsAtIndexPaths:selectedIndexPaths byExtendingSelection:YES];
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - Private - Dragging Items
// ------------------------------------------------------------------------------------------
- (TestPredicate)p_draggingItemPredicateWithIndexPath:(NSIndexPath *)indexPath
{
    TestPredicate predicate = ^BOOL(GNESectionedTableViewDraggingItem *draggingItem,
                                    NSUInteger index __unused,
                                    BOOL *stop __unused)
    {
        NSIndexPath *itemIndexPath = draggingItem.indexPath;
        
        return (indexPath && itemIndexPath &&
                [indexPath compare:itemIndexPath] == NSOrderedSame);
    };
    
    return predicate;
}


- (RowAnimationBlock)p_rowAnimationBlockWithTargetIndexPaths:(NSArray *)toIndexPaths
{
    GNESectionedTableView *tableView = self.tableView;
    NSArray *draggingItems = self.draggingItems;
    
    __weak typeof(self) weakSelf = self;
    RowAnimationBlock block = ^(NSIndexPath *fromIndexPath,
                                NSUInteger indexPathIndex,
                                BOOL *stop __unused)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil)
        {
            return;
        }
        
        TestPredicate predicate = [strongSelf p_draggingItemPredicateWithIndexPath:fromIndexPath];
        NSUInteger draggingItemIndex = [draggingItems indexOfObjectPassingTest:predicate];
        
        if (draggingItemIndex == NSNotFound)
        {
            return;
        }
        
        GNESectionedTableViewDraggingItem *draggingItem = draggingItems[draggingItemIndex];
        NSIndexPath *toIndexPath = toIndexPaths[indexPathIndex];
        CGRect toFrame = [tableView frameOfViewAtIndexPath:toIndexPath];
        toFrame.size.height =   (toFrame.size.height <= GNESectionedTableViewInvisibleRowHeight) ?
                                    draggingItem.view.bounds.size.height : toFrame.size.height;
        
        [tableView addSubview:draggingItem.view];
        draggingItem.view.animator.frame = toFrame;
    };
    
    return block;
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESections
// ------------------------------------------------------------------------------------------
- (NSIndexSet *)p_indexSetForSections:(GNESections)sections
{
    NSMutableIndexSet *mutableIndexSet = [NSMutableIndexSet indexSet];
    
    for (NSUInteger i = 0; i < sections.count; i++)
    {
        NSUInteger section = sections.indexes[i];
        if (section < (NSNotFound - 1))
        {
            [mutableIndexSet addIndex:section];
        }
    }
    
    return [mutableIndexSet copy];
}


/// Returns an array of properly-formatted section header index paths for the
/// specified sections.
- (NSArray *)p_indexPathsForSections:(GNESections)sections
{
    NSMutableArray *mutableIndexPaths = [NSMutableArray array];
    
    GNESectionedTableView *tableView = self.tableView;
    
    for (NSUInteger i = 0; i < sections.count; i++)
    {
        NSUInteger section = sections.indexes[i];
        NSIndexPath *indexPath = [tableView indexPathForHeaderInSection:section];
        if (indexPath)
        {
            [mutableIndexPaths addObject:indexPath];
        }
    }
    
    return [NSArray arrayWithArray:mutableIndexPaths];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Accessors
// ------------------------------------------------------------------------------------------
- (NSArray *)draggingItems
{
    return self.mutableDraggingItems.allObjects;
}


@end
