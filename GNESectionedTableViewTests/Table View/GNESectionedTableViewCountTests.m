//
//  GNESectionedTableViewCountTests.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 3/21/15.
//  Copyright (c) 2015 Gone East LLC. All rights reserved.
//

#import "GNESectionedTableViewTests.h"


// ------------------------------------------------------------------------------------------


@interface GNESectionedTableViewCountTests : GNESectionedTableViewTests

@end


// ------------------------------------------------------------------------------------------


@implementation GNESectionedTableViewCountTests


// ------------------------------------------------------------------------------------------
#pragma mark - Sections
// ------------------------------------------------------------------------------------------
- (void)testSectionCount_Zero
{
    NSUInteger sectionCount = 0;
    XCTSetNumberOfSections(sectionCount);
    [self.tableView reloadData];
    XCTAssertNumberOfSections(sectionCount);
}


- (void)testSectionCount_One
{
    NSUInteger sectionCount = 1;
    XCTSetNumberOfSections(sectionCount);
    [self setRowCount:0 forNumberOfSections:sectionCount];
    [self.tableView reloadData];
    XCTAssertNumberOfSections(sectionCount);
}


- (void)testSectionCount_Two
{
    NSUInteger sectionCount = 2;
    XCTSetNumberOfSections(sectionCount);
    [self setRowCount:0 forNumberOfSections:sectionCount];
    [self.tableView reloadData];
    XCTAssertNumberOfSections(sectionCount);
}


- (void)testSectionCount_Ten
{
    NSUInteger sectionCount = 10;
    XCTSetNumberOfSections(sectionCount);
    [self setRowCount:0 forNumberOfSections:sectionCount];
    [self.tableView reloadData];
    XCTAssertNumberOfSections(sectionCount);
}


// ------------------------------------------------------------------------------------------
#pragma mark - Rows
// ------------------------------------------------------------------------------------------
- (void)testRowCount_NoSections
{
    NSUInteger sectionCount = 0;
    XCTSetNumberOfSections(sectionCount);
    [self setRowCount:0 forNumberOfSections:1];
    XCTAssertNumberOfSections(sectionCount);
    XCTAssertThrows([self.tableView numberOfRowsInSection:0]);
}


- (void)testRowCount_One
{
    NSUInteger sectionCount = 1;
    NSUInteger rowCount = 1;
    XCTSetNumberOfSections(sectionCount);
    [self setRowCount:rowCount forNumberOfSections:sectionCount];
    [self.tableView reloadData];
    XCTAssertNumberOfSections(sectionCount);
    XCTAssertNumberOfRowsInSection(rowCount, 0);
}


- (void)testRowCount_Multiple
{
    NSUInteger sectionCount = 3;
    XCTSetNumberOfSections(sectionCount);
    NSUInteger rowCounts[] = {0, 1, 2};
    [self setRowCounts:rowCounts forNumberOfSections:sectionCount];
    [self.tableView reloadData];
    XCTAssertNumberOfSections(sectionCount);
    XCTAssertNumberOfRowsInSection(rowCounts[0], 0);
    XCTAssertNumberOfRowsInSection(rowCounts[1], 1);
    XCTAssertNumberOfRowsInSection(rowCounts[2], 2);
}


// ------------------------------------------------------------------------------------------
#pragma mark - Helpers
// ------------------------------------------------------------------------------------------
- (void)setRowCount:(NSUInteger)rowCount forNumberOfSections:(NSUInteger)numberOfSections
{
    NSMutableArray *rows = [NSMutableArray array];

    for (NSUInteger i = 0; i < numberOfSections; i++)
    {
        rows[i] = @(rowCount);
    }

    XCTSetNumberOfRowsInSections([rows copy]);
}


- (void)setRowCounts:(NSUInteger *)rowCounts forNumberOfSections:(NSUInteger)numberOfSections
{
    NSMutableArray *rows = [NSMutableArray array];

    for (NSUInteger i = 0; i < numberOfSections; i++)
    {
        rows[i] = @(rowCounts[i]);
    }

    XCTSetNumberOfRowsInSections([rows copy]);
}


@end
