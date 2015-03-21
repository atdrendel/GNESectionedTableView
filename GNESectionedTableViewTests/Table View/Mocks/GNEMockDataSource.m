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
    MockNumberOfSectionsBlock block = (__bridge MockNumberOfSectionsBlock)[self blockForSelector:_cmd];

    return block();
}


- (NSUInteger)tableView:(GNESectionedTableView *)tableView numberOfRowsInSection:(NSUInteger)section
{
    MockNumberOfRowsBlock block = (__bridge MockNumberOfRowsBlock)[self blockForSelector:_cmd];

    return block(section);
}


// ------------------------------------------------------------------------------------------
#pragma mark - Views
// ------------------------------------------------------------------------------------------
- (NSTableRowView *)tableView:(GNESectionedTableView *)tableView rowViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MockViewAtIndexPathBlock block = (__bridge MockViewAtIndexPathBlock)[self blockForSelector:_cmd];

    return (NSTableRowView *)block(indexPath);
}


- (NSTableCellView *)tableView:(GNESectionedTableView *)tableView cellViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MockViewAtIndexPathBlock block = (__bridge MockViewAtIndexPathBlock)[self blockForSelector:_cmd];

    return (NSTableCellView *)block(indexPath);
}


// ------------------------------------------------------------------------------------------
#pragma mark - Drag and Drop
// ------------------------------------------------------------------------------------------
- (NSArray *)draggedTypesForTableView:(GNESectionedTableView *)tableView
{
    MockReturnArrayBlock block = (__bridge MockReturnArrayBlock)[self blockForSelector:_cmd];

    return block();
}


- (void)tableViewDraggingSessionWillBegin:(GNESectionedTableView *)tableView
{
    MockVoidBlock block = (__bridge MockVoidBlock)[self blockForSelector:_cmd];
    block();
}


- (void)tableView:(GNESectionedTableView *)tableView didUpdateDrag:(id <NSDraggingInfo>)info
{
    MockObjectBlock block = (__bridge MockObjectBlock)[self blockForSelector:_cmd];
    block(info);
}


- (BOOL)tableView:(GNESectionedTableView *)tableView canDragSection:(NSUInteger)section
{
    MockCanDragSectionBlock block = (__bridge MockCanDragSectionBlock)[self blockForSelector:_cmd];

    return block(section);
}


- (BOOL)tableView:(GNESectionedTableView *)tableView
   canDragSection:(NSUInteger)fromSection
        toSection:(NSUInteger)toSection
{
    MockCanDragSectionToSectionBlock block = (__bridge MockCanDragSectionToSectionBlock)[self blockForSelector:_cmd];

    return block(fromSection, toSection);
}


- (void)tableView:(GNESectionedTableView *)tableView
  didDragSections:(NSIndexSet *)fromSections
        toSection:(NSUInteger)toSection
{
    MockObjectUnsignedIntegerBlock block = (__bridge MockObjectUnsignedIntegerBlock)[self blockForSelector:_cmd];
    block(fromSections, toSection);
}


- (BOOL)tableView:(GNESectionedTableView *)tableView canDragRowAtIndexPath:(NSIndexPath *)indexPath
{
    MockCanDragRowBlock block = (__bridge MockCanDragRowBlock)[self blockForSelector:_cmd];

    return block(indexPath);
}


-       (BOOL)tableView:(GNESectionedTableView *)tableView
  canDropRowAtIndexPath:(NSIndexPath *)fromIndexPath
      onHeaderInSection:(NSUInteger)section
{
    MockCanDropRowOnSectionBlock block = (__bridge MockCanDropRowOnSectionBlock)[self blockForSelector:_cmd];

    return block(fromIndexPath, section);
}


-       (BOOL)tableView:(GNESectionedTableView *)tableView
  canDropRowAtIndexPath:(NSIndexPath *)fromIndexPath
       onRowAtIndexPath:(NSIndexPath *)toIndexPath
{
    MockCanDropRowOnRowBlock block = (__bridge MockCanDropRowOnRowBlock)[self blockForSelector:_cmd];

    return block(fromIndexPath, toIndexPath);
}


-       (BOOL)tableView:(GNESectionedTableView *)tableView
  canDragRowAtIndexPath:(NSIndexPath *)fromIndexPath
            toIndexPath:(NSIndexPath *)toIndexPath
{
    MockCanDragRowToRowBlock block = (__bridge MockCanDragRowToRowBlock)[self blockForSelector:_cmd];

    return block(fromIndexPath, toIndexPath);
}


-       (void)tableView:(GNESectionedTableView *)tableView
didDropRowsAtIndexPaths:(NSArray *)fromIndexPaths
      onHeaderInSection:(NSUInteger)section
{
    MockObjectUnsignedIntegerBlock block = (__bridge MockObjectUnsignedIntegerBlock)[self blockForSelector:_cmd];
    block(fromIndexPaths, section);
}


-       (void)tableView:(GNESectionedTableView *)tableView
didDropRowsAtIndexPaths:(NSArray *)fromIndexPaths
       onRowAtIndexPath:(NSIndexPath *)toIndexPath
{
    MockObjectObjectBlock block = (__bridge MockObjectObjectBlock)[self blockForSelector:_cmd];
    block(fromIndexPaths, toIndexPath);
}


-       (void)tableView:(GNESectionedTableView *)tableView
didDragRowsAtIndexPaths:(NSArray *)fromIndexPaths
            toIndexPath:(NSIndexPath *)toIndexPath
{
    MockObjectObjectBlock block = (__bridge MockObjectObjectBlock)[self blockForSelector:_cmd];
    block(fromIndexPaths, toIndexPath);
}


- (void)tableViewDraggingSessionDidEnd:(GNESectionedTableView *)tableView
{
    MockVoidBlock block = (__bridge MockVoidBlock)[self blockForSelector:_cmd];
    block();
}


@end
