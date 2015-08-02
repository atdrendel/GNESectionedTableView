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

    [self setUpRowViewBlock];
    [self setUpCellViewBlock];
}


- (void)setUpRowViewBlock
{
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
}


- (void)setUpCellViewBlock
{
    __weak typeof(self) weakSelf = self;
    __weak typeof(self.tableView) weakTV = self.tableView;

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


- (void)testHeightOfSections_HeadersAndRows
{
    NSUInteger sectionCount = 2;
    NSUInteger rowCount = 2; // Per section
    NSUInteger heights[2] = {0, 1};
    GNEOrderedIndexSet *sections = [GNEOrderedIndexSet indexSetWithIndexes:heights count:2];
    NSArray *headerHeights = @[@10.0, @20.0];
    NSArray *rowHeights = @[@30.0, @40.0];
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSMutableArray *rowHeightsForIndexPaths = [NSMutableArray array];
    for (NSUInteger section = 0; section < sectionCount; section++)
    {
        for (NSUInteger row = 0; row < rowCount; row++)
        {
            NSIndexPath *indexPath = [NSIndexPath gne_indexPathForRow:row inSection:section];
            NSNumber *heightNumber = rowHeights[section];
            [indexPaths addObject:indexPath];
            [rowHeightsForIndexPaths addObject:heightNumber];
        }
    }
    XCTSetNumberOfSections(sectionCount);
    XCTSetNumberOfRowsInSections((@[@(rowCount), @(rowCount)]));
    XCTSetHeightsOfHeaders(sections, headerHeights);
    XCTSetHeightsOfRows(indexPaths, rowHeightsForIndexPaths);
    [self.tableView reloadData];

    for (NSUInteger i = 0; i < indexPaths.count; i++)
    {
        NSUInteger section = [indexPaths[i] gne_section];
        XCTAssertHeightOfHeader(section, [headerHeights[section] doubleValue]);
        XCTAssertHeightOfRow(indexPaths[i], [rowHeightsForIndexPaths[i] doubleValue]);
    }
}


- (void)testHeightOfSections_HeaderRowAndFooter
{

}


@end
