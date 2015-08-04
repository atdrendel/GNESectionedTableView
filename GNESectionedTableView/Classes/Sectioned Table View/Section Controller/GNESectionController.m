//
//  GNESectionController.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 8/2/15.
//  Copyright © 2015 Gone East LLC. All rights reserved.
//

#import "GNESectionController.h"
#import "GNEOutlineViewItem.h"
#import "GNEOutlineViewParentItem.h"


// ------------------------------------------------------------------------------------------


@interface GNESectionController ()

@property (nonatomic, strong) NSArray *parentItems;

@end


// ------------------------------------------------------------------------------------------


@implementation GNESectionController


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
- (nonnull instancetype)init
{
    if ((self = [super init]))
    {
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
    _parentItems = nil;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Parent Items
// ------------------------------------------------------------------------------------------
- (void)p_buildParentItems
{
    [self p_assertDataSourceDelegateAreValid];
    NSMutableArray *parentItems = [NSMutableArray array];
    NSUInteger sectionCount = [self.tableViewDataSource numberOfSectionsInTableView:self.tableView];
    for (NSUInteger section = 0; section < sectionCount; section++)
    {
        GNEOutlineViewParentItem *parentItem = [self p_newParentItemWithSection:section];
        [parentItems addObject:parentItem];
    }
    
    self.parentItems = [parentItems copy];
}


- (GNEOutlineViewParentItem *)p_newParentItemWithSection:(NSUInteger)section
{
    GNEOutlineViewParentItem *parentItem = [[GNEOutlineViewParentItem alloc] initWithSection:section
                                                                                   tableView:self.tableView
                                                                                  dataSource:self.tableViewDataSource
                                                                                    delegate:self.tableViewDelegate];

    return parentItem;
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
    return self.parentItems.count;
}


@end
