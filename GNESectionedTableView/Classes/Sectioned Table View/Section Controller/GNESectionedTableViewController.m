//
//  GNESectionController.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 8/2/15.
//  Copyright © 2015 Gone East LLC. All rights reserved.
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

#import "GNESectionedTableViewController.h"
#import "GNEOutlineViewRowItem.h"
#import "GNEOutlineViewSectionItem.h"


// ------------------------------------------------------------------------------------------


typedef void(^SectionAnimationBlock)(NSArray *);


// ------------------------------------------------------------------------------------------


@interface GNESectionedTableViewController ()

@property (nonatomic, strong) NSArray *sectionItems;

@end


// ------------------------------------------------------------------------------------------


@implementation GNESectionedTableViewController


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
- (nonnull instancetype)init
{
    if ((self = [super init]))
    {
        _tableView = nil;
        _tableViewDataSource = nil;
        _tableViewDelegate = nil;
    }

    return self;
}


- (instancetype)initWithTableView:(GNESectionedTableView *)tableView
                       dataSource:(id<GNESectionedTableViewDataSource>)dataSource
                         delegate:(id<GNESectionedTableViewDelegate>)delegate
{
    if ((self = [self init]))
    {
        _tableView = tableView;
        _tableViewDataSource = dataSource;
        _tableViewDelegate = delegate;
        [self p_buildSectionItems];
    }

    return self;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Dealloc
// ------------------------------------------------------------------------------------------
- (void)dealloc
{
    _tableView = nil;
    _tableViewDataSource = nil;
    _tableViewDelegate = nil;
    _sectionItems = nil;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Section Items
// ------------------------------------------------------------------------------------------
- (void)p_buildSectionItems
{
    [self p_assertDataSourceDelegateAreValid];
    NSMutableArray *parentItems = [NSMutableArray array];
    NSUInteger sectionCount = [self.tableViewDataSource numberOfSectionsInTableView:self.tableView];
    for (NSUInteger section = 0; section < sectionCount; section++)
    {
        GNEOutlineViewSectionItem *sectionItem = [self p_newSectionItemWithSection:section];
        [parentItems addObject:sectionItem];
    }
    
    self.sectionItems = [parentItems copy];
}


- (GNEOutlineViewSectionItem *)p_newSectionItemWithSection:(NSUInteger)section
{
    GNEOutlineViewSectionItem *parentItem = [[GNEOutlineViewSectionItem alloc] initWithSection:section
                                                                                     tableView:self.tableView
                                                                                    dataSource:self.tableViewDataSource
                                                                                      delegate:self.tableViewDelegate];

    return parentItem;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Expand/Collapse Sections - Public
// ------------------------------------------------------------------------------------------
- (BOOL)isSectionExpanded:(NSUInteger)section
{
    return [self p_sectionItemAtIndex:section].isExpanded;
}


- (void)expandAllSections:(BOOL)animated
{
    [self expandSections:[self p_indexSetForAllSections] animated:animated];
}


- (void)expandSection:(NSUInteger)section animated:(BOOL)animated
{
    [self expandSections:[NSIndexSet indexSetWithIndex:section] animated:animated];
}


- (void)expandSections:(NSIndexSet *)sections animated:(BOOL)animated
{
    SectionAnimationBlock block = ^(NSArray *items)
    {
        for (GNEOutlineViewSectionItem *item in items)
        {
            [item expand:animated];
        }
    };
    NSArray *items = [self.sectionItems objectsAtIndexes:sections];
    [self p_performBlock:block withSectionItems:items animated:animated completion:nil];
}


- (void)collapseAllSections:(BOOL)animated
{
    [self collapseSections:[self p_indexSetForAllSections] animated:animated];
}


- (void)collapseSection:(NSUInteger)section animated:(BOOL)animated
{
    [self collapseSections:[NSIndexSet indexSetWithIndex:section] animated:animated];
}


- (void)collapseSections:(NSIndexSet *)sections animated:(BOOL)animated
{
    SectionAnimationBlock block = ^(NSArray *items)
    {
        for (GNEOutlineViewSectionItem *item in items)
        {
            [item collapse:animated];
        }
    };
    NSArray *items = [self.sectionItems objectsAtIndexes:sections];
    [self p_performBlock:block withSectionItems:items animated:animated completion:nil];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Insert, Delete, and Update Sections - Public
// ------------------------------------------------------------------------------------------
- (void)insertSections:(NSIndexSet *)sections
         withAnimation:(NSTableViewAnimationOptions)animationOptions
{
    [self insertSections:sections withAnimation:animationOptions expanded:YES];
}


- (void)insertSections:(NSIndexSet *)sections
         withAnimation:(NSTableViewAnimationOptions)animationOptions
              expanded:(BOOL)expanded
{
    NSMutableArray *mutableSectionItems = [NSMutableArray arrayWithArray:self.sectionItems];
    [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop __unused)
    {
        GNEParameterAssert(section <= mutableSectionItems.count);
        GNEOutlineViewSectionItem *item = [self p_newSectionItemWithSection:section];
        if (section <= mutableSectionItems.count)
        {
            [mutableSectionItems insertObject:item atIndex:section];
        }
        else
        {
            [mutableSectionItems addObject:item];
        }
    }];
    self.sectionItems = [mutableSectionItems copy];
    [self p_updateSectionOfSectionItems];
    [self.tableView insertItemsAtIndexes:sections inParent:nil withAnimation:animationOptions];
    if (expanded)
    {
        [self expandSections:sections animated:NO];
    }
}


- (void)deleteSections:(NSIndexSet *)sections
         withAnimation:(NSTableViewAnimationOptions)animationOptions
{
    NSMutableArray *mutableSectionItems = [NSMutableArray arrayWithArray:self.sectionItems];
    [sections enumerateIndexesWithOptions:NSEnumerationReverse
                               usingBlock:^(NSUInteger section, BOOL *stop __unused)
    {
        GNEParameterAssert(section < mutableSectionItems.count);
        if (section < mutableSectionItems.count)
        {
            [mutableSectionItems removeObjectAtIndex:section];
        }
    }];
    self.sectionItems = [mutableSectionItems copy];
    [self p_updateSectionOfSectionItems];
    [self.tableView removeItemsAtIndexes:[self p_safeIndexSetForSections:sections]
                                inParent:nil
                           withAnimation:animationOptions];
}


- (void)moveSections:(GNEOrderedIndexSet *)fromSections
          toSections:(GNEOrderedIndexSet *)toSections
{
    GNESectionedTableView *tableView = self.tableView;

    NSArray *movingSectionItems = [self p_sectionItemsAtOrderedIndexes:fromSections];
    [self deleteSections:fromSections.ns_indexSet withAnimation:NSTableViewAnimationEffectFade];

    NSIndexSet *toIndexes = toSections.ns_indexSet;
    NSMutableIndexSet *sectionsToExpand = [NSMutableIndexSet indexSet];
    NSMutableArray *headersToSelect = [NSMutableArray array];
    NSMutableArray *mutableSectionItems = [NSMutableArray arrayWithArray:self.sectionItems];
    [toIndexes enumerateIndexesUsingBlock:^(NSUInteger toSection, BOOL *stop __unused)
    {
        NSUInteger position = [toSections positionOfIndex:toSection];

        GNEParameterAssert(position != NSNotFound && position < movingSectionItems.count);
        if (position == NSNotFound || position >= movingSectionItems.count)
        {
            return;
        }

        GNEOutlineViewSectionItem *item = movingSectionItems[position];
        if (item.isExpanded)
        {
            [sectionsToExpand addIndex:toSection];
        }
        if (item.isSelected)
        {
            [headersToSelect addObject:GNEHeaderIndexPathForSection(toSection)];
        }

        GNEParameterAssert(toSection <= mutableSectionItems.count);
        if (toSection <= mutableSectionItems.count)
        {
            [mutableSectionItems insertObject:item atIndex:toSection];
        }
        else
        {
            [mutableSectionItems addObject:item];
        }
    }];
    self.sectionItems = [mutableSectionItems copy];
    [tableView insertItemsAtIndexes:toSections.ns_indexSet
                                inParent:nil
                           withAnimation:NSTableViewAnimationEffectFade];
    [self expandSections:sectionsToExpand animated:YES];
    [tableView selectRowsAtIndexPaths:headersToSelect byExtendingSelection:YES];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Insert, Delete, and Update Rows - Public
// ------------------------------------------------------------------------------------------
- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths
                 withAnimation:(NSTableViewAnimationOptions)animationOptions
{

}


- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths
                 withAnimation:(NSTableViewAnimationOptions)animationOptions
{

}


- (void)moveRowsAtIndexPaths:(NSArray *)fromIndexPaths
                toIndexPaths:(NSArray *)toIndexPaths
{

}


- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths
{
    
}


// ------------------------------------------------------------------------------------------
#pragma mark - Section Items - Private
// ------------------------------------------------------------------------------------------
- (GNEOutlineViewSectionItem *)p_sectionItemAtIndex:(NSUInteger)index
{
    NSUInteger count = self.sectionItems.count;

    return (index < count) ? self.sectionItems[index] : nil;
}


- (NSArray *)p_sectionItemsAtIndexes:(NSIndexSet *)sections
{
    return [self p_sectionItemsAtOrderedIndexes:[GNEOrderedIndexSet indexSetWithNSIndexSet:sections]];
}


- (NSArray *)p_sectionItemsAtOrderedIndexes:(GNEOrderedIndexSet *)sections
{
    NSMutableArray *items = [NSMutableArray array];
    [sections enumerateIndexesUsingBlock:^(NSUInteger index,
                                           NSUInteger position __unused,
                                           BOOL *stop __unused)
    {
        GNEOutlineViewSectionItem *item = [self p_sectionItemAtIndex:index];
        if (item)
        {
            [items addObject:item];
        }
    }];
    
    return [items copy];
}


- (NSIndexSet *)p_indexSetForAllSections
{
    NSRange range = NSMakeRange(0, self.sectionItems.count);

    return [NSIndexSet indexSetWithIndexesInRange:range];
}


- (NSIndexSet *)p_safeIndexSetForSections:(NSIndexSet *)sections
{
    NSUInteger count = (NSUInteger)[self.tableView numberOfChildrenOfItem:nil];

    return [sections indexesPassingTest:^BOOL(NSUInteger section, BOOL *stop __unused)
    {
        return (section < count);
    }];
}


- (void)p_updateSectionOfSectionItems
{
    NSUInteger section = 0;
    for (GNEOutlineViewSectionItem *item in self.sectionItems)
    {
        item.section = section;
        section++;
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - Animation - Private
// ------------------------------------------------------------------------------------------
- (void)p_performBlock:(SectionAnimationBlock)block
      withSectionItems:(NSArray *)sectionItems
              animated:(BOOL)animated
            completion:(GNECompletionBlock)completion
{
    GNEParameterAssert(block);
    GNEParameterAssert(sectionItems);

    if (block == nil || sectionItems.count == 0)
    {
        return;
    }

    if (animated)
    {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context __unused)
        {
            block(sectionItems);
        } completionHandler:completion];
    }
    else
    {
        block(sectionItems);
        if (completion)
        {
            completion();
        }
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - Data Source / Delegate
// ------------------------------------------------------------------------------------------
- (void)p_assertDataSourceDelegateAreValid
{
    GNEParameterAssert([self.tableViewDataSource conformsToProtocol:@protocol(GNESectionedTableViewDataSource)]);
    GNEParameterAssert([self.tableViewDelegate conformsToProtocol:@protocol(GNESectionedTableViewDelegate)]);
}


// ------------------------------------------------------------------------------------------
#pragma mark - Accessors
// ------------------------------------------------------------------------------------------
- (NSUInteger)numberOfSections
{
    return self.sectionItems.count;
}


@end
