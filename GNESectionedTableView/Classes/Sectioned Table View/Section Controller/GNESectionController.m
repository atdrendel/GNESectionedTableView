//
//  GNESectionController.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 8/2/15.
//  Copyright © 2015 Gone East LLC. All rights reserved.
//

#import "GNESectionController.h"


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


- (nonnull instancetype)initWithTableViewDataSource:(id<GNESectionedTableViewDataSource>)dataSource
                                  tableViewDelegate:(id<GNESectionedTableViewDelegate>)delegate;
{
    if ((self = [self init]))
    {
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
    _tableViewDataSource = nil;
    _tableViewDelegate = nil;
}


@end
