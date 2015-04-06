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
    MockHeightForRowBlock block = [self blockForSelector:_cmd];

    return (block) ? block(indexPath) : 0.0;
}


- (CGFloat)tableView:(GNESectionedTableView *)tableView heightForHeaderInSection:(NSUInteger)section
{
    MockHeightForSectionBlock block = [self blockForSelector:_cmd];

    return (block) ? block(section) : 0.0;
}


- (CGFloat)tableView:(GNESectionedTableView *)tableView heightForFooterInSection:(NSUInteger)section
{
    MockHeightForSectionBlock block = [self blockForSelector:_cmd];

    return (block) ? block(section) : 0.0;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Views
// ------------------------------------------------------------------------------------------
- (NSTableRowView *)tableView:(GNESectionedTableView *)tableView rowViewForHeaderInSection:(NSUInteger)section
{
    MockViewForSectionBlock block = [self blockForSelector:_cmd];

    return (block) ? (NSTableRowView *)block(section) : nil;
}


- (NSTableCellView *)tableView:(GNESectionedTableView *)tableView cellViewForHeaderInSection:(NSUInteger)section
{
    MockViewForSectionBlock block = [self blockForSelector:_cmd];

    return (block) ? (NSTableCellView *)block(section) : nil;
}


- (NSTableRowView *)tableView:(GNESectionedTableView *)tableView rowViewForFooterInSection:(NSUInteger)section
{
    MockViewForSectionBlock block = [self blockForSelector:_cmd];

    return (block) ? (NSTableRowView *)block(section) : nil;
}


- (NSTableCellView *)tableView:(GNESectionedTableView *)tableView cellViewForFooterInSection:(NSUInteger)section
{
    MockViewForSectionBlock block = [self blockForSelector:_cmd];

    return (block) ? (NSTableCellView *)block(section) : nil;
}


- (NSTableRowView *)tableView:(GNESectionedTableView *)tableView rowViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MockViewForRowBlock block = [self blockForSelector:_cmd];

    return (block) ? (NSTableRowView *)block(indexPath) : nil;
}


- (NSTableCellView *)tableView:(GNESectionedTableView *)tableView cellViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MockViewForRowBlock block = [self blockForSelector:_cmd];

    return (block) ? (NSTableCellView *)block(indexPath) : nil;
}


-   (void)tableView:(GNESectionedTableView *)tableView
  didDisplayRowView:(NSTableRowView *)rowView
 forHeaderInSection:(NSUInteger)section
{
    MockViewUnsignedIntegerBlock block = [self blockForSelector:_cmd];
    if (block)
    {
        block(rowView, section);
    }
}


-   (void)tableView:(GNESectionedTableView *)tableView
  didDisplayRowView:(NSTableRowView *)rowView
 forFooterInSection:(NSUInteger)section
{
    MockViewUnsignedIntegerBlock block = [self blockForSelector:_cmd];
    if (block)
    {
        block(rowView, section);
    }
}


- (void)tableView:(GNESectionedTableView *)tableView
didDisplayRowView:(NSTableRowView *)rowView
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    MockViewIndexPathBlock block = [self blockForSelector:_cmd];
    if (block)
    {
        block(rowView, indexPath);
    }
}


-       (void)tableView:(GNESectionedTableView *)tableView
didEndDisplayingRowView:(NSTableRowView *)rowView
     forHeaderInSection:(NSUInteger)section
{
    MockViewUnsignedIntegerBlock block = [self blockForSelector:_cmd];
    if (block)
    {
        block(rowView, section);
    }
}


-       (void)tableView:(GNESectionedTableView *)tableView
didEndDisplayingRowView:(NSTableRowView *)rowView
     forFooterInSection:(NSUInteger)section
{
    MockViewUnsignedIntegerBlock block = [self blockForSelector:_cmd];
    if (block)
    {
        block(rowView, section);
    }
}


-       (void)tableView:(GNESectionedTableView *)tableView
didEndDisplayingRowView:(NSTableRowView *)rowView
      forRowAtIndexPath:(NSIndexPath *)indexPath
{
    MockViewIndexPathBlock block = [self blockForSelector:_cmd];
    if (block)
    {
        block(rowView, indexPath);
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - Expanding/Collapsing
// ------------------------------------------------------------------------------------------
- (BOOL)tableView:(GNESectionedTableView *)tableView shouldExpandSection:(NSUInteger)section
{
    MockShouldExpandCollapseSectionBlock block = [self blockForSelector:_cmd];

    return (block) ? block(section) : NO;
}


- (BOOL)tableView:(GNESectionedTableView *)tableView shouldCollapseSection:(NSUInteger)section
{
    MockShouldExpandCollapseSectionBlock block = [self blockForSelector:_cmd];

    return (block) ? block(section) : NO;
}


- (void)tableView:(GNESectionedTableView *)tableView willExpandSection:(NSUInteger)section
{
    MockUnsignedIntegerBlock block = [self blockForSelector:_cmd];
    if (block)
    {
        block(section);
    }
}


- (void)tableView:(GNESectionedTableView *)tableView willCollapseSection:(NSUInteger)section
{
    MockUnsignedIntegerBlock block = [self blockForSelector:_cmd];
    if (block)
    {
        block(section);
    }
}


- (void)tableView:(GNESectionedTableView *)tableView didExpandSection:(NSUInteger)section
{
    MockUnsignedIntegerBlock block = [self blockForSelector:_cmd];
    if (block)
    {
        block(section);
    }
}


- (void)tableView:(GNESectionedTableView *)tableView didCollapseSection:(NSUInteger)section
{
    MockUnsignedIntegerBlock block = [self blockForSelector:_cmd];
    if (block)
    {
        block(section);
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - Selection
// ------------------------------------------------------------------------------------------
- (BOOL)tableView:(GNESectionedTableView *)tableView shouldSelectHeaderInSection:(NSUInteger)section
{
    MockShouldSelectSectionBlock block = [self blockForSelector:_cmd];

    return (block) ? block(section) : NO;
}


- (BOOL)tableView:(GNESectionedTableView *)tableView shouldSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MockShouldSelectRowBlock block = [self blockForSelector:_cmd];

    return (block) ? block(indexPath) : NO;
}


-                   (void)tableView:(GNESectionedTableView *)tableView
  proposedSelectedHeadersInSections:(NSIndexSet **)sectionIndexes
      proposedSelectedRowIndexPaths:(NSArray **)indexPaths
{

}


- (void)tableView:(GNESectionedTableView *)tableView didClickHeaderInSection:(NSUInteger)section
{
    MockUnsignedIntegerBlock block = [self blockForSelector:_cmd];
    if (block)
    {
        block(section);
    }
}


- (void)tableView:(GNESectionedTableView *)tableView didClickFooterInSection:(NSUInteger)section
{
    MockUnsignedIntegerBlock block = [self blockForSelector:_cmd];
    if (block)
    {
        block(section);
    }
}


- (void)tableView:(GNESectionedTableView *)tableView didDoubleClickHeaderInSection:(NSUInteger)section
{
    MockUnsignedIntegerBlock block = [self blockForSelector:_cmd];
    if (block)
    {
        block(section);
    }
}


- (void)tableView:(GNESectionedTableView *)tableView didDoubleClickFooterInSection:(NSUInteger)section
{
    MockUnsignedIntegerBlock block = [self blockForSelector:_cmd];
    if (block)
    {
        block(section);
    }
}


- (void)tableView:(GNESectionedTableView *)tableView didClickRowAtIndexPath:(NSIndexPath *)indexPath
{
    MockObjectBlock block = [self blockForSelector:_cmd];
    if (block)
    {
        block(indexPath);
    }
}


- (void)tableView:(GNESectionedTableView *)tableView didDoubleClickRowAtIndexPath:(NSIndexPath *)indexPath
{
    MockObjectBlock block = [self blockForSelector:_cmd];
    if (block)
    {
        block(indexPath);
    }
}


- (void)tableViewDidDeselectAllHeadersAndRows:(GNESectionedTableView *)tableView
{
    MockVoidBlock block = [self blockForSelector:_cmd];
    if (block)
    {
        block();
    }
}


- (void)tableView:(GNESectionedTableView *)tableView didSelectHeaderInSection:(NSUInteger)section
{
    MockUnsignedIntegerBlock block = [self blockForSelector:_cmd];
    if (block)
    {
        block(section);
    }
}


- (void)tableView:(GNESectionedTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MockObjectBlock block = [self blockForSelector:_cmd];
    if (block)
    {
        block(indexPath);
    }
}


- (void)tableView:(GNESectionedTableView *)tableView didSelectHeadersInSections:(NSIndexSet *)sections
{
    MockObjectBlock block = [self blockForSelector:_cmd];
    if (block)
    {
        block(sections);
    }
}


- (void)tableView:(GNESectionedTableView *)tableView didSelectRowsAtIndexPaths:(NSArray *)indexPaths
{
    MockObjectBlock block = [self blockForSelector:_cmd];
    if (block)
    {
        block(indexPaths);
    }
}


@end
