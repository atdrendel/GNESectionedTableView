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
    _sectionItems = nil;
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
        GNEOutlineViewSectionItem *parentItem = [self p_newParentItemWithSection:section];
        [parentItems addObject:parentItem];
    }
    
    self.sectionItems = [parentItems copy];
}


- (GNEOutlineViewSectionItem *)p_newParentItemWithSection:(NSUInteger)section
{
    GNEOutlineViewSectionItem *parentItem = [[GNEOutlineViewSectionItem alloc] initWithSection:section
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
    return self.sectionItems.count;
}


@end
