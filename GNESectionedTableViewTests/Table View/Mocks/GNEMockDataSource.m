//
//  GNEMockDataSource.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 3/21/15.
//  Copyright (c) 2015 Gone East LLC. All rights reserved.
//

#import "GNEMockDataSource.h"


@implementation GNEMockDataSource


// ------------------------------------------------------------------------------------------
#pragma mark - Counts
// ------------------------------------------------------------------------------------------
- (NSUInteger)numberOfSectionsInTableView:(GNESectionedTableView *)tableView
{
    MockNumberOfSectionsBlock block = [self blockForSelector:_cmd];

    return (block) ? block() : 0;
}


- (NSUInteger)tableView:(GNESectionedTableView *)tableView numberOfRowsInSection:(NSUInteger)section
{
    MockNumberOfRowsBlock block = (__bridge MockNumberOfRowsBlock)[self blockForSelector:_cmd];

    return (block) ? block(section) : 0;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Views
// ------------------------------------------------------------------------------------------
- (NSTableRowView *)tableView:(GNESectionedTableView *)tableView rowViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MockViewAtIndexPathBlock block = [self blockForSelector:_cmd];

    return (NSTableRowView *)block(indexPath);
}


- (NSTableCellView *)tableView:(GNESectionedTableView *)tableView cellViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MockViewAtIndexPathBlock block = [self blockForSelector:_cmd];

    return (NSTableCellView *)block(indexPath);
}


// ------------------------------------------------------------------------------------------
#pragma mark - Drag and Drop
// ------------------------------------------------------------------------------------------
- (NSArray *)draggedTypesForTableView:(GNESectionedTableView *)tableView
{
    MockReturnArrayBlock block = [self blockForSelector:_cmd];

    return (block) ? block() : @[];
}


- (void)tableViewDraggingSessionWillBegin:(GNESectionedTableView *)tableView
{
    MockVoidBlock block = [self blockForSelector:_cmd];
    block();
}


- (void)tableView:(GNESectionedTableView *)tableView didUpdateDrag:(id <NSDraggingInfo>)info
{
    MockObjectBlock block = [self blockForSelector:_cmd];
    block(info);
}


- (BOOL)tableView:(GNESectionedTableView *)tableView canDragSection:(NSUInteger)section
{
    MockCanDragSectionBlock block = [self blockForSelector:_cmd];

    return block(section);
}


- (BOOL)tableView:(GNESectionedTableView *)tableView
   canDragSection:(NSUInteger)fromSection
        toSection:(NSUInteger)toSection
{
    MockCanDragSectionToSectionBlock block = [self blockForSelector:_cmd];

    return block(fromSection, toSection);
}


- (void)tableView:(GNESectionedTableView *)tableView
  didDragSections:(NSIndexSet *)fromSections
        toSection:(NSUInteger)toSection
{
    MockObjectUnsignedIntegerBlock block = [self blockForSelector:_cmd];
    block(fromSections, toSection);
}


- (BOOL)tableView:(GNESectionedTableView *)tableView canDragRowAtIndexPath:(NSIndexPath *)indexPath
{
    MockCanDragRowBlock block = [self blockForSelector:_cmd];

    return block(indexPath);
}


-       (BOOL)tableView:(GNESectionedTableView *)tableView
  canDropRowAtIndexPath:(NSIndexPath *)fromIndexPath
      onHeaderInSection:(NSUInteger)section
{
    MockCanDropRowOnSectionBlock block = [self blockForSelector:_cmd];

    return block(fromIndexPath, section);
}


-       (BOOL)tableView:(GNESectionedTableView *)tableView
  canDropRowAtIndexPath:(NSIndexPath *)fromIndexPath
       onRowAtIndexPath:(NSIndexPath *)toIndexPath
{
    MockCanDropRowOnRowBlock block = [self blockForSelector:_cmd];

    return block(fromIndexPath, toIndexPath);
}


-       (BOOL)tableView:(GNESectionedTableView *)tableView
  canDragRowAtIndexPath:(NSIndexPath *)fromIndexPath
            toIndexPath:(NSIndexPath *)toIndexPath
{
    MockCanDragRowToRowBlock block = [self blockForSelector:_cmd];

    return block(fromIndexPath, toIndexPath);
}


-       (void)tableView:(GNESectionedTableView *)tableView
didDropRowsAtIndexPaths:(NSArray *)fromIndexPaths
      onHeaderInSection:(NSUInteger)section
{
    MockObjectUnsignedIntegerBlock block = [self blockForSelector:_cmd];
    block(fromIndexPaths, section);
}


-       (void)tableView:(GNESectionedTableView *)tableView
didDropRowsAtIndexPaths:(NSArray *)fromIndexPaths
       onRowAtIndexPath:(NSIndexPath *)toIndexPath
{
    MockObjectObjectBlock block = [self blockForSelector:_cmd];
    block(fromIndexPaths, toIndexPath);
}


-       (void)tableView:(GNESectionedTableView *)tableView
didDragRowsAtIndexPaths:(NSArray *)fromIndexPaths
            toIndexPath:(NSIndexPath *)toIndexPath
{
    MockObjectObjectBlock block = [self blockForSelector:_cmd];
    block(fromIndexPaths, toIndexPath);
}


- (void)tableViewDraggingSessionDidEnd:(GNESectionedTableView *)tableView
{
    MockVoidBlock block = [self blockForSelector:_cmd];
    block();
}


@end
