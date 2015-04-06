//
//  GNESectionedTableViewTests.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 4/5/15.
//  Copyright (c) 2015 Gone East LLC. All rights reserved.
//

#import "GNESectionedTableViewTests.h"
#import "GNEMockDataSource.h"
#import "GNEMockDelegate.h"

// ------------------------------------------------------------------------------------------


@interface GNESectionedTableViewTests ()

@property (nonatomic, strong, readwrite) GNESectionedTableView *tableView;
@property (nonatomic, strong, readwrite) GNEMockDataSource *dataSource;
@property (nonatomic, strong, readwrite) GNEMockDelegate *delegate;

@end


// ------------------------------------------------------------------------------------------


@implementation GNESectionedTableViewTests


// ------------------------------------------------------------------------------------------
#pragma mark - Set Up & Tear Down
// ------------------------------------------------------------------------------------------
- (void)setUp
{
    [super setUp];

    self.tableView = [[GNESectionedTableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 0.0)];
    self.dataSource = [[GNEMockDataSource alloc] init];
    self.delegate = [[GNEMockDelegate alloc] init];

    self.tableView.intercellSpacing = CGSizeZero;
    self.tableView.tableViewDataSource = self.dataSource;
    self.tableView.tableViewDelegate = self.delegate;
    self.dataSource.didFinishSettingUp = YES;
}


- (void)tearDown
{
    self.tableView.tableViewDataSource = nil;
    self.tableView.tableViewDelegate = nil;
    self.dataSource = nil;
    self.tableView = nil;

    [super tearDown];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Properties
// ------------------------------------------------------------------------------------------
- (void)testTableViewDataSourceIsSelf
{
    XCTAssertNotNil(self.tableView.dataSource);
    XCTAssertEqualObjects(self.tableView.dataSource, self.tableView);
}


- (void)testTableViewDelegateIsSelf
{
    XCTAssertNotNil(self.tableView.delegate);
    XCTAssertEqualObjects(self.tableView.delegate, self.tableView);
}


- (void)testTableViewHasTableViewDataSource
{
    XCTAssertTrue([self.tableView isKindOfClass:[GNESectionedTableView class]]);
    XCTAssertNotNil(self.dataSource);
    XCTAssertEqualObjects(self.dataSource, self.tableView.tableViewDataSource);
}


- (void)testTableViewHasTableViewDelegate
{
    XCTAssertTrue([self.tableView isKindOfClass:[GNESectionedTableView class]]);
    XCTAssertNotNil(self.delegate);
    XCTAssertEqualObjects(self.delegate, self.tableView.tableViewDelegate);
}


@end
