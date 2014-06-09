//
//  GNETableViewDataSource.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 6/9/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

#import "GNETableViewDataSource.h"


// ------------------------------------------------------------------------------------------


static NSString * const kRowViewIdentifier = @"com.goneeast.RowViewIdentifier";
static NSString * const kCellViewIdentifier = @"com.goneeast.CellViewIdentifier";

static NSString * const kHeaderRowViewIdentifier = @"com.goneeast.HeaderRowViewIdentifier";
static NSString * const kHeaderCellViewIdentifier = @"com.goneeast.HeaderCellViewIdentifier";


// ------------------------------------------------------------------------------------------


@interface GNETableViewDataSource ()


@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSMutableArray *rows;


@end


// ------------------------------------------------------------------------------------------


@implementation GNETableViewDataSource


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
- (instancetype)init
{
    if ((self = [super init]))
    {
        [self p_buildAndConfigureSectionsAndRows];
    }
    
    return self;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Private - Sections and Rows
// ------------------------------------------------------------------------------------------
- (void)p_buildAndConfigureSectionsAndRows
{
    NSUInteger sectionCount = arc4random_uniform(10);
    
    self.sections = [NSMutableArray arrayWithCapacity:sectionCount];
    self.rows = [NSMutableArray arrayWithCapacity:sectionCount];
    
    for (NSUInteger section = 0; section < sectionCount; section++)
    {
        [self.sections addObject:[NSString stringWithFormat:@"%lu", section]];
        
        NSUInteger rowCount = arc4random_uniform(10);
        NSMutableArray *rowsArray = [NSMutableArray arrayWithCapacity:rowCount];
        for (NSUInteger row = 0; row < rowCount; row++)
        {
            [rowsArray addObject:[NSString stringWithFormat:@"%lu", row]];
        }
        
        [self.rows addObject:rowsArray];
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableViewDataSource
// ------------------------------------------------------------------------------------------
- (NSUInteger)numberOfSectionsInTableView:(GNESectionedTableView * __unused)tableView
{
    return [self.sections count];
}


- (NSUInteger)tableView:(GNESectionedTableView * __unused)tableView numberOfRowsInSection:(NSUInteger)section
{
    return [self.rows[section] count];
}


- (NSTableRowView *)tableView:(GNESectionedTableView *)tableView
     rowViewForRowAtIndexPath:(NSIndexPath * __unused)indexPath
{
    NSTableRowView *rowView = [tableView makeViewWithIdentifier:kRowViewIdentifier owner:tableView];
    
    if (rowView == nil)
    {
        rowView = [[NSTableRowView alloc] initWithFrame:CGRectZero];
        [rowView setAutoresizingMask:NSViewWidthSizable];
        rowView.identifier = kRowViewIdentifier;
        rowView.backgroundColor = [NSColor blueColor];
    }
    
    return rowView;
}


- (NSTableCellView *)tableView:(GNESectionedTableView *)tableView
     cellViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:kCellViewIdentifier owner:tableView];
    
    if (cellView == nil)
    {
        cellView = [[NSTableCellView alloc] initWithFrame:CGRectZero];
        [cellView setAutoresizingMask:NSViewWidthSizable];
        cellView.identifier = kCellViewIdentifier;
        cellView.textField.stringValue = [NSString stringWithFormat:@"%lu, %lu",
                                          indexPath.gne_section,
                                          indexPath.gne_row];
    }
    
    return cellView;
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableViewDelegate
// ------------------------------------------------------------------------------------------
-       (CGFloat)tableView:(GNESectionedTableView * __unused)tableView
   heightForRowAtIndexPath:(NSIndexPath * __unused)indexPath
{
    return 40.0f;
}


-       (CGFloat)tableView:(GNESectionedTableView * __unused)tableView
  heightForHeaderInSection:(NSUInteger __unused)section
{
    return 22.0f;
}


- (NSTableRowView *)tableView:(GNESectionedTableView *)tableView
    rowViewForHeaderInSection:(NSUInteger __unused)section
{
    NSTableRowView *rowView = [tableView makeViewWithIdentifier:kHeaderRowViewIdentifier owner:tableView];
    
    if (rowView == nil)
    {
        rowView = [[NSTableRowView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 36.0f)];
        [rowView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        rowView.identifier = kHeaderRowViewIdentifier;
        rowView.backgroundColor = [NSColor greenColor];
    }
    
    return rowView;
}


- (NSTableCellView *)tableView:(GNESectionedTableView *)tableView
    cellViewForHeaderInSection:(NSUInteger __unused)section
{
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:kHeaderCellViewIdentifier owner:tableView];
    
    if (cellView == nil)
    {
        cellView = [[NSTableCellView alloc] initWithFrame:CGRectZero];
        [cellView setAutoresizingMask:NSViewWidthSizable];
        cellView.identifier = kHeaderCellViewIdentifier;
    }
    
    return cellView;
}


@end
