//
//  GNEMockDelegate.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 3/22/15.
//  Copyright (c) 2015 Gone East LLC. All rights reserved.
//

#import "GNEMockDelegate.h"

@implementation GNEMockDelegate


// ------------------------------------------------------------------------------------------
#pragma mark - Sizing
// ------------------------------------------------------------------------------------------
- (CGFloat)tableView:(GNESectionedTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

}


- (CGFloat)tableView:(GNESectionedTableView *)tableView heightForHeaderInSection:(NSUInteger)section
{

}


- (CGFloat)tableView:(GNESectionedTableView *)tableView heightForFooterInSection:(NSUInteger)section
{

}


// ------------------------------------------------------------------------------------------
#pragma mark - Views
// ------------------------------------------------------------------------------------------
- (NSTableRowView *)tableView:(GNESectionedTableView *)tableView rowViewForHeaderInSection:(NSUInteger)section
{

}


- (NSTableCellView *)tableView:(GNESectionedTableView *)tableView cellViewForHeaderInSection:(NSUInteger)section
{

}


- (NSTableRowView *)tableView:(GNESectionedTableView *)tableView rowViewForFooterInSection:(NSUInteger)section
{

}


- (NSTableCellView *)tableView:(GNESectionedTableView *)tableView cellViewForFooterInSection:(NSUInteger)section
{

}


-   (void)tableView:(GNESectionedTableView *)tableView
  didDisplayRowView:(NSTableRowView *)rowView
 forHeaderInSection:(NSUInteger)section
{

}


-   (void)tableView:(GNESectionedTableView *)tableView
  didDisplayRowView:(NSTableRowView *)rowView
 forFooterInSection:(NSUInteger)section
{

}


- (void)tableView:(GNESectionedTableView *)tableView
didDisplayRowView:(NSTableRowView *)rowView
forRowAtIndexPath:(NSIndexPath *)indexPath
{

}


-       (void)tableView:(GNESectionedTableView *)tableView
didEndDisplayingRowView:(NSTableRowView *)rowView
     forHeaderInSection:(NSUInteger)section
{

}


-       (void)tableView:(GNESectionedTableView *)tableView
didEndDisplayingRowView:(NSTableRowView *)rowView
     forFooterInSection:(NSUInteger)section
{

}


-       (void)tableView:(GNESectionedTableView *)tableView
didEndDisplayingRowView:(NSTableRowView *)rowView
      forRowAtIndexPath:(NSIndexPath *)indexPath
{

}


// ------------------------------------------------------------------------------------------
#pragma mark - Expanding/Collapsing
// ------------------------------------------------------------------------------------------
- (BOOL)tableView:(GNESectionedTableView *)tableView shouldExpandSection:(NSUInteger)section
{

}


- (BOOL)tableView:(GNESectionedTableView *)tableView shouldCollapseSection:(NSUInteger)section
{

}


- (void)tableView:(GNESectionedTableView *)tableView willExpandSection:(NSUInteger)section
{

}


- (void)tableView:(GNESectionedTableView *)tableView willCollapseSection:(NSUInteger)section
{

}


- (void)tableView:(GNESectionedTableView *)tableView didExpandSection:(NSUInteger)section
{

}


- (void)tableView:(GNESectionedTableView *)tableView didCollapseSection:(NSUInteger)section
{

}


// ------------------------------------------------------------------------------------------
#pragma mark - Selection
// ------------------------------------------------------------------------------------------
- (BOOL)tableView:(GNESectionedTableView *)tableView shouldSelectHeaderInSection:(NSUInteger)section
{

}


- (BOOL)tableView:(GNESectionedTableView *)tableView shouldSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}


-                   (void)tableView:(GNESectionedTableView *)tableView
  proposedSelectedHeadersInSections:(NSIndexSet **)sectionIndexes
      proposedSelectedRowIndexPaths:(NSArray **)indexPaths
{

}


- (void)tableView:(GNESectionedTableView *)tableView didClickHeaderInSection:(NSUInteger)section
{

}


- (void)tableView:(GNESectionedTableView *)tableView didClickFooterInSection:(NSUInteger)section
{

}


- (void)tableView:(GNESectionedTableView *)tableView didDoubleClickHeaderInSection:(NSUInteger)section
{

}


- (void)tableView:(GNESectionedTableView *)tableView didDoubleClickFooterInSection:(NSUInteger)section
{

}


- (void)tableView:(GNESectionedTableView *)tableView didClickRowAtIndexPath:(NSIndexPath *)indexPath
{

}


- (void)tableView:(GNESectionedTableView *)tableView didDoubleClickRowAtIndexPath:(NSIndexPath *)indexPath
{

}


- (void)tableViewDidDeselectAllHeadersAndRows:(GNESectionedTableView *)tableView
{

}


- (void)tableView:(GNESectionedTableView *)tableView didSelectHeaderInSection:(NSUInteger)section
{

}


- (void)tableView:(GNESectionedTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}


- (void)tableView:(GNESectionedTableView *)tableView didSelectHeadersInSections:(NSIndexSet *)sections
{

}


- (void)tableView:(GNESectionedTableView *)tableView didSelectRowsAtIndexPaths:(NSArray *)indexPaths
{

}


@end
