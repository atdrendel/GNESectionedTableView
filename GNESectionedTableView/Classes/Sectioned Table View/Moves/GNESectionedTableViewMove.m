//
//  GNESectionedTableViewMove.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 12/22/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

#import "GNESectionedTableViewMove.h"
#import "GNESectionedTableView.h"
#import "GNESectionedTableViewMovingItem.h"
#import "GNEOrderedIndexSet.h"


// ------------------------------------------------------------------------------------------


typedef BOOL(^TestPredicate)(GNESectionedTableViewMovingItem *movingItem, NSUInteger index __unused, BOOL *stop __unused);

typedef void(^MovingItemAnimationBlock)(NSIndexPath *fromIndexPath, NSUInteger indexPathIndex, BOOL *stop __unused);

typedef void(^IndexPathsAnimationBlock)(NSArray *fromIndexPaths, MovingItemAnimationBlock block);

typedef void(^CompletionBlock)();


// ------------------------------------------------------------------------------------------


@interface GNESectionedTableViewMove ()

@property (nonatomic, weak, readwrite) GNESectionedTableView *tableView;
@property (nonatomic, strong) NSMutableSet *mutableMovingItems;

@end


// ------------------------------------------------------------------------------------------


@implementation GNESectionedTableViewMove


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
- (instancetype)init
{
    NSAssert(NO, @"Use -[GNESectionedTableViewMove initWithTableView:]");
    
    return [self initWithTableView:nil];
}


- (instancetype)initWithTableView:(GNESectionedTableView *)tableView
{
    NSParameterAssert(tableView);
    if (tableView == nil)
    {
        return nil;
    }
    
    if ((self = [super init]))
    {
        _tableView = tableView;
        _mutableMovingItems = [NSMutableSet set];
    }
    
    return self;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Dealloc
// ------------------------------------------------------------------------------------------
- (void)dealloc
{
    _tableView = nil;
    
    [_mutableMovingItems removeAllObjects];
    _mutableMovingItems = nil;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Public - Adding Dragging Items
// ------------------------------------------------------------------------------------------
- (void)addMovingItem:(GNESectionedTableViewMovingItem *)movingItem
{
    if (movingItem)
    {
        [self.mutableMovingItems addObject:movingItem];
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - Public - Move
// ------------------------------------------------------------------------------------------
- (void)moveSections:(GNEOrderedIndexSet *)fromSections toSections:(GNEOrderedIndexSet *)toSections
{
    GNEParameterAssert(fromSections.count == toSections.count);

    [self p_animateDeletionOfSections:fromSections.ns_indexSet
                  insertionOfSections:toSections.ns_indexSet];
    
    [self p_animateMoveOfMovingItemsInSections:fromSections
                                    toSections:toSections];
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

    [self p_animateMoveOfMovingItemsAtIndexPaths:fromIndexPaths
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


- (void)p_animateMoveOfMovingItemsInSections:(GNEOrderedIndexSet *)fromSections
                                  toSections:(GNEOrderedIndexSet *)toSections
{
    GNEParameterAssert(fromSections.count == toSections.count);
    
    if (fromSections.count != toSections.count)
    {
        return;
    }
    
    NSArray *fromIndexPaths = [self p_indexPathsForSections:fromSections];
    NSArray *toIndexPaths = [self p_indexPathsForSections:toSections];
    
    MovingItemAnimationBlock block = [self p_sectionAnimationBlockWithTargetIndexPaths:toIndexPaths];
    [self p_animateMoveFromIndexPaths:fromIndexPaths animationBlock:block];
}


- (void)p_animateMoveOfMovingItemsAtIndexPaths:(NSArray *)fromIndexPaths
                                  toIndexPaths:(NSArray *)toIndexPaths
{
    GNEParameterAssert(fromIndexPaths.count == toIndexPaths.count);
    
    if (fromIndexPaths.count != toIndexPaths.count)
    {
        return;
    }
    
    MovingItemAnimationBlock block = [self p_rowAnimationBlockWithTargetIndexPaths:toIndexPaths];
    [self p_animateMoveFromIndexPaths:fromIndexPaths animationBlock:block];
}


- (void)p_animateMoveFromIndexPaths:(NSArray *)fromIndexPaths
                     animationBlock:(MovingItemAnimationBlock)block
{
    NSArray *movingItems = self.movingItems;
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context)
    {
        context.duration = 0.24;
        [fromIndexPaths enumerateObjectsUsingBlock:block];
    } completionHandler:^()
    {
        for (GNESectionedTableViewMovingItem *movingItem in movingItems)
        {
            [movingItem.view removeFromSuperview];
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
#pragma mark - Private - Moving Items
// ------------------------------------------------------------------------------------------
- (TestPredicate)p_movingItemPredicateWithIndexPath:(NSIndexPath *)indexPath
{
    TestPredicate predicate = ^BOOL(GNESectionedTableViewMovingItem *movingItem,
                                    NSUInteger index __unused,
                                    BOOL *stop __unused)
    {
        NSIndexPath *itemIndexPath = movingItem.indexPath;
        
        return (indexPath && itemIndexPath &&
                [indexPath compare:itemIndexPath] == NSOrderedSame);
    };
    
    return predicate;
}


- (MovingItemAnimationBlock)p_rowAnimationBlockWithTargetIndexPaths:(NSArray *)toIndexPaths
{
    GNESectionedTableView *tableView = self.tableView;
    NSArray *movingItems = self.movingItems;
    
    __weak typeof(self) weakSelf = self;
    MovingItemAnimationBlock block = ^(NSIndexPath *fromIndexPath,
                                       NSUInteger indexPathIndex,
                                       BOOL *stop __unused)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil)
        {
            return;
        }
        
        TestPredicate predicate = [strongSelf p_movingItemPredicateWithIndexPath:fromIndexPath];
        NSUInteger movingItemIndex = [movingItems indexOfObjectPassingTest:predicate];
        
        if (movingItemIndex == NSNotFound)
        {
            return;
        }
        
        GNESectionedTableViewMovingItem *movingItem = movingItems[movingItemIndex];
        NSIndexPath *toIndexPath = toIndexPaths[indexPathIndex];
        CGRect toFrame = [tableView frameOfViewAtIndexPath:toIndexPath];
        toFrame.size.height =   (toFrame.size.height <= GNESectionedTableViewInvisibleRowHeight) ?
                                    movingItem.view.bounds.size.height : toFrame.size.height;
        
        [tableView addSubview:movingItem.view];
        movingItem.view.animator.frame = toFrame;
    };
    
    return block;
}


- (MovingItemAnimationBlock)p_sectionAnimationBlockWithTargetIndexPaths:(NSArray *)toIndexPaths
{
    GNESectionedTableView *tableView = self.tableView;
    NSArray *movingItems = self.movingItems;
    
    __weak typeof(self) weakSelf = self;
    MovingItemAnimationBlock block = ^(NSIndexPath *fromIndexPath,
                                       NSUInteger indexPathIndex,
                                       BOOL *stop __unused)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil)
        {
            return;
        }
        
        TestPredicate predicate = [strongSelf p_movingItemPredicateWithIndexPath:fromIndexPath];
        NSUInteger movingItemIndex = [movingItems indexOfObjectPassingTest:predicate];
        
        if (movingItemIndex == NSNotFound)
        {
            return;
        }
        
        GNESectionedTableViewMovingItem *movingItem = movingItems[movingItemIndex];
        NSIndexPath *toIndexPath = toIndexPaths[indexPathIndex];
        CGRect toFrame = [tableView frameOfSection:toIndexPath.gne_section];
        toFrame.size.height =   (toFrame.size.height < movingItem.view.bounds.size.height) ?
                                    movingItem.view.bounds.size.height : toFrame.size.height;
        
        [tableView addSubview:movingItem.view];
        movingItem.view.animator.frame = toFrame;
    };
    
    return block;
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESections
// ------------------------------------------------------------------------------------------
/// Returns an array of properly-formatted section header index paths for the specified sections.
- (NSArray *)p_indexPathsForSections:(GNEOrderedIndexSet *)sections
{
    NSMutableArray *mutableIndexPaths = [NSMutableArray array];
    
    GNESectionedTableView *tableView = self.tableView;
    
    [sections enumerateIndexesUsingBlock:^(NSUInteger section,
                                           NSUInteger position __unused,
                                           BOOL *stop __unused)
    {
        NSIndexPath *indexPath = [tableView indexPathForHeaderInSection:section];
        if (indexPath)
        {
            [mutableIndexPaths addObject:indexPath];
        }
    }];
    
    return [NSArray arrayWithArray:mutableIndexPaths];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Accessors
// ------------------------------------------------------------------------------------------
- (NSArray *)movingItems
{
    return self.mutableMovingItems.allObjects;
}


@end
