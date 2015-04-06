//
//  GNESectionedTableViewHeightTests.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 4/6/15.
//  Copyright (c) 2015 Gone East LLC. All rights reserved.
//

#import "GNESectionedTableViewTests.h"


// ------------------------------------------------------------------------------------------


@interface GNESectionedTableViewHeightTests : GNESectionedTableViewTests

@end


// ------------------------------------------------------------------------------------------


@implementation GNESectionedTableViewHeightTests


// ------------------------------------------------------------------------------------------
#pragma mark - Set Up & Tear Down
// ------------------------------------------------------------------------------------------
- (void)setUp
{
    [super setUp];

    __weak typeof(self) weakSelf = self;
    __weak typeof(self.tableView) weakTV = self.tableView;

    MockViewForRowBlock rowViewBlock = ^NSTableRowView *(NSIndexPath *indexPath)
    {
        NSString *identifier = @"RowViewIdentifier";
        NSTableRowView *rowView = [weakTV makeViewWithIdentifier:identifier owner:weakSelf];
        if (rowView == nil)
        {
            rowView = [[NSTableRowView alloc] initWithFrame:CGRectZero];
            rowView.identifier = identifier;
        }

        return rowView;
    };
    [self.delegate setBlock:(__bridge void *)rowViewBlock
                forSelector:@selector(tableView:rowViewForRowAtIndexPath:)];

    MockViewForRowBlock cellViewBlock = ^NSTableCellView *(NSIndexPath *indexPath)
    {
        NSString *identifier = @"CellViewIdentifier";
        NSTableCellView *cellView = [weakTV makeViewWithIdentifier:identifier owner:weakSelf];
        if (cellView == nil)
        {
            cellView = [[NSTableCellView alloc] initWithFrame:CGRectZero];
            cellView.identifier = identifier;
        }

        return cellView;
    };
    [self.delegate setBlock:(__bridge void *)cellViewBlock
                forSelector:@selector(tableView:cellViewForRowAtIndexPath:)];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Tests
// ------------------------------------------------------------------------------------------
- (void)testHeightOfSection_Header
{
    NSUInteger section = 0;
    NSUInteger sectionCount = 1;
    NSUInteger rowCount = 0;
    CGFloat height = 44.0;
    XCTSetNumberOfSections(sectionCount);
    XCTSetNumberOfRowsInSections(@[@(rowCount)]);
    XCTSetHeightOfHeader(section, height);
    [self.tableView reloadData];
    XCTAssertHeightOfHeader(section, height);
}


- (void)testHeightOfSection_HeaderAndRow
{
    NSUInteger section = 0;
    NSUInteger row = 0;

    NSUInteger sectionCount = 1;
    NSUInteger rowCount = 1;
    CGFloat headerHeight = 22.0;
    CGFloat rowHeight = 44.0;
    XCTSetNumberOfSections(sectionCount);
    XCTSetNumberOfRowsInSections(@[@(rowCount)]);
    XCTSetHeightOfHeader(section, headerHeight);
    XCTSetHeightOfRow([NSIndexPath gne_indexPathForRow:row inSection:section], rowHeight);
    [self.tableView reloadData];
    XCTAssertHeightOfHeader(section, headerHeight);
    XCTAssertHeightOfRow([NSIndexPath gne_indexPathForRow:row inSection:section], rowHeight);
}


@end
