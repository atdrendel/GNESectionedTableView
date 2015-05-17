//
//  GNESectionedTableViewMove.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 12/22/14.
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

#import "GNESectionedTableViewMove.h"
#import "GNESectionedTableView.h"
#import "GNESectionedTableViewMovingItem.h"
#import "GNEOrderedIndexSet.h"
@import QuartzCore;


// ------------------------------------------------------------------------------------------


typedef BOOL(^TestPredicate)(GNESectionedTableViewMovingItem *movingItem, NSUInteger index __unused, BOOL *stop __unused);

typedef void(^AnimationBlock)(NSIndexPath *fromIndexPath, NSUInteger indexPathIndex, BOOL *stop __unused);


// ------------------------------------------------------------------------------------------


@interface GNESectionedTableViewMove ()

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
    
    [self p_updateIndexPathsToSelectForMovesFromSections:fromSections
                                              toSections:toSections];

    [self p_animateDeletionOfSections:fromSections
                  insertionOfSections:toSections];
    
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
- (void)p_animateDeletionOfSections:(GNEOrderedIndexSet *)deletedIndexes
                insertionOfSections:(GNEOrderedIndexSet *)insertedIndexes
{
    GNESectionedTableView *tableView = self.tableView;
    
    GNEParameterAssert(tableView);
    GNEParameterAssert(deletedIndexes.count == insertedIndexes.count);
    
    [tableView beginUpdates];
    [tableView deleteSections:deletedIndexes.ns_indexSet
                withAnimation:NSTableViewAnimationEffectFade];
    [insertedIndexes enumerateIndexesUsingBlock:^(NSUInteger section,
                                                  NSUInteger position __unused,
                                                  BOOL *stop __unused)
    {
        BOOL expanded = ([self.sectionsToExpand containsIndex:section]);
        [tableView insertSections:[NSIndexSet indexSetWithIndex:section]
                    withAnimation:NSTableViewAnimationEffectFade
                         expanded:expanded];
    }];
    [tableView endUpdates];
    
    [tableView selectRowsAtIndexPaths:self.indexPathsToSelect
                 byExtendingSelection:YES];
}


- (void)p_animateDeletionOfRowsAtIndexPaths:(NSArray *)deletedIndexPaths
                insertionOfRowsAtIndexPaths:(NSArray *)insertedIndexPaths
{
    GNESectionedTableView *tableView = self.tableView;
    
    GNEParameterAssert(tableView);
    GNEParameterAssert(deletedIndexPaths.count == insertedIndexPaths.count);
    
    NSIndexSet *selectedIndexPathIndexes = [self p_indexSetOfSelectedRowsInFromIndexPaths:deletedIndexPaths];
    
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:deletedIndexPaths withAnimation:NSTableViewAnimationEffectFade];
    [tableView insertRowsAtIndexPaths:insertedIndexPaths withAnimation:NSTableViewAnimationEffectFade];
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
    
    if (fromIndexPaths.count == toIndexPaths.count && fromIndexPaths.count > 0)
    {
        AnimationBlock block = [self p_sectionAnimationBlockWithTargetIndexPaths:toIndexPaths];
        [self p_animateMoveFromIndexPaths:fromIndexPaths
                           animationBlock:block];
    }
}


- (void)p_animateMoveOfMovingItemsAtIndexPaths:(NSArray *)fromIndexPaths
                                  toIndexPaths:(NSArray *)toIndexPaths
{
    GNEParameterAssert(fromIndexPaths.count == toIndexPaths.count);
    
    if (fromIndexPaths.count != toIndexPaths.count || fromIndexPaths.count == 0)
    {
        return;
    }
    
    AnimationBlock block = [self p_rowAnimationBlockWithTargetIndexPaths:toIndexPaths];
    [self p_animateMoveFromIndexPaths:fromIndexPaths
                       animationBlock:block];
}


- (void)p_animateMoveFromIndexPaths:(NSArray *)fromIndexPaths
                     animationBlock:(AnimationBlock)block
{
    NSArray *movingItems = self.movingItems;
    GNESectionedTableView *tableView = self.tableView;
    NSArray *indexPathsToSelect = [self.indexPathsToSelect copy];
    NSIndexSet *sectionsToExpand = [self.autoCollapsedSections copy];
    GNESectionedTableViewMoveCompletion completionBlock = [self.completion copy];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context)
    {
        context.duration = 0.4;
        [fromIndexPaths enumerateObjectsUsingBlock:block];
    } completionHandler:^()
    {
        for (GNESectionedTableViewMovingItem *movingItem in movingItems)
        {
            if (movingItem.view.superview)
            {
                [movingItem.view removeFromSuperview];
            }
        }
        
        [tableView expandSections:sectionsToExpand animated:YES];
        [tableView selectRowsAtIndexPaths:indexPathsToSelect
                     byExtendingSelection:YES];
        
        if (completionBlock)
        {
            completionBlock();
        }
    }];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Private - Selection
// ------------------------------------------------------------------------------------------
- (void)p_updateIndexPathsToSelectForMovesFromSections:(GNEOrderedIndexSet *)fromSections
                                            toSections:(GNEOrderedIndexSet *)toSections
{
    NSArray *selectedFromIndexPaths = [self p_indexPathsOfSelectedRowsInSections:fromSections];
    NSArray *selectedToIndexPaths = [self p_indexPathsByConvertingIndexPaths:selectedFromIndexPaths
                                                           movedFromSections:fromSections
                                                                  toSections:toSections];
    
    self.indexPathsToSelect = selectedToIndexPaths;
}


- (NSArray *)p_indexPathsOfSelectedRowsInSections:(GNEOrderedIndexSet *)sections
{
    GNESectionedTableView *tableView = self.tableView;
    
    NSArray *selectedIndexPaths = tableView.selectedIndexPaths;
    selectedIndexPaths = [selectedIndexPaths arrayByAddingObjectsFromArray:self.indexPathsToSelect];
    
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


- (NSArray *)p_indexPathsByConvertingIndexPaths:(NSArray *)indexPaths
                              movedFromSections:(GNEOrderedIndexSet *)fromSections
                                     toSections:(GNEOrderedIndexSet *)toSections
{
    NSMutableArray *convertedIndexPaths = [NSMutableArray array];
    
    for (NSIndexPath *indexPath in indexPaths)
    {
        NSUInteger fromSection = indexPath.gne_section;
        NSUInteger position = [fromSections positionOfIndex:fromSection];
        NSUInteger toSection = [toSections indexAtPosition:position];
        if (toSection != NSNotFound)
        {
            NSIndexPath *newIndexPath = [NSIndexPath gne_indexPathForRow:indexPath.gne_row
                                                               inSection:toSection];
            [convertedIndexPaths addObject:newIndexPath];
        }
    }
    
    return convertedIndexPaths;
}


- (NSIndexSet *)p_indexSetOfSelectedRowsInFromIndexPaths:(NSArray *)fromIndexPaths
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
    GNESectionedTableView *tableView = self.tableView;
    if (tableView && indexes.count > 0)
    {
        NSArray *selectedIndexPaths = [toIndexPaths objectsAtIndexes:indexes];
        [tableView selectRowsAtIndexPaths:selectedIndexPaths byExtendingSelection:YES];
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


- (AnimationBlock)p_rowAnimationBlockWithTargetIndexPaths:(NSArray *)toIndexPaths
{
    GNESectionedTableView *tableView = self.tableView;
    NSArray *movingItems = self.movingItems;
    
    __weak typeof(self) weakSelf = self;
    AnimationBlock block = ^(NSIndexPath *fromIndexPath,
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
        if (CGRectEqualToRect(toFrame, CGRectZero))
        {
            return;
        }
        toFrame.size.height =   (toFrame.size.height <= GNESectionedTableViewInvisibleRowHeight) ?
                                    movingItem.view.bounds.size.height : toFrame.size.height;
        
        [tableView addSubview:movingItem.view];
        
        CABasicAnimation *frameAnimation = [CABasicAnimation animation];
        frameAnimation.fromValue = [NSValue valueWithRect:movingItem.view.frame];
        frameAnimation.toValue = [NSValue valueWithRect:toFrame];
        
        CAKeyframeAnimation *alphaAnimation = [CAKeyframeAnimation animation];
        alphaAnimation.timingFunction = [CAMediaTimingFunction
                                         functionWithName:kCAMediaTimingFunctionLinear];
        alphaAnimation.values = @[@1, @1, @0.3, @0.05, @0, @0];
        
        movingItem.view.animations = @{ @"frame" : frameAnimation,
                                        @"alphaValue" : alphaAnimation };
        movingItem.view.animator.frame = toFrame;
        movingItem.view.animator.alphaValue = 0.0f;
    };
    
    return block;
}


- (AnimationBlock)p_sectionAnimationBlockWithTargetIndexPaths:(NSArray *)toIndexPaths
{
    GNESectionedTableView *tableView = self.tableView;
    NSArray *movingItems = self.movingItems;
    
    __weak typeof(self) weakSelf = self;
    AnimationBlock block = ^(NSIndexPath *fromIndexPath,
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
        if (CGRectEqualToRect(toFrame, CGRectZero))
        {
            return;
        }
        toFrame.size.height =   (toFrame.size.height < movingItem.view.bounds.size.height) ?
                                    movingItem.view.bounds.size.height : toFrame.size.height;
        
        [tableView addSubview:movingItem.view];
        
        
        CABasicAnimation *frameAnimation = [CABasicAnimation animation];
        frameAnimation.fromValue = [NSValue valueWithRect:movingItem.view.frame];
        frameAnimation.toValue = [NSValue valueWithRect:toFrame];
        
        CAKeyframeAnimation *alphaAnimation = [CAKeyframeAnimation animation];
        alphaAnimation.timingFunction = [CAMediaTimingFunction
                                         functionWithName:kCAMediaTimingFunctionLinear];
        alphaAnimation.values = @[@1, @1, @0.3, @0.05, @0, @0];
        
        movingItem.view.animations = @{ @"frame" : frameAnimation,
                                        @"alphaValue" : alphaAnimation };
        movingItem.view.animator.frame = toFrame;
        movingItem.view.animator.alphaValue = 0.0f;
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
