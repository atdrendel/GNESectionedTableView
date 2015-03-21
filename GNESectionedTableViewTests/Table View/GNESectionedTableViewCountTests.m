//
//  GNESectionedTableViewCountTests.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 3/21/15.
//  Copyright (c) 2015 Gone East LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "GNESectionedTableViewTests.h"

// ------------------------------------------------------------------------------------------


@interface GNESectionedTableViewCountTests : XCTestCase

@property (nonatomic, strong) GNESectionedTableView *tableView;
@property (nonatomic, strong) GNEMockDataSource *dataSource;

@end


// ------------------------------------------------------------------------------------------


@implementation GNESectionedTableViewCountTests


// ------------------------------------------------------------------------------------------
#pragma mark - Set Up & Tear Down
// ------------------------------------------------------------------------------------------
- (void)setUp
{
    [super setUp];

    self.tableView = [[GNESectionedTableView alloc] initWithFrame:CGRectZero];
    self.dataSource = [[GNEMockDataSource alloc] init];

    self.tableView.tableViewDataSource = self.dataSource;
}

- (void)tearDown
{
    self.tableView.tableViewDataSource = nil;
    self.dataSource = nil;
    self.tableView = nil;

    [super tearDown];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Sections
// ------------------------------------------------------------------------------------------
- (void)testSectionCount_Zero
{
    NSUInteger count = 0;
    XCTSetNumberOfSections(count);
    [self.tableView reloadData];
    XCTAssertNumberOfSections(count);
}



@end
