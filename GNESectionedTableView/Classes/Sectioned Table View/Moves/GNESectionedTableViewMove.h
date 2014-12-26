//
//  GNESectionedTableViewMove.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 12/22/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

@class GNESectionedTableView, GNESectionedTableViewDraggingItem, GNEOrderedIndexSet;


// ------------------------------------------------------------------------------------------


@interface GNESectionedTableViewMove : NSObject

@property (nonatomic, weak, readonly) GNESectionedTableView *tableView;
@property (nonatomic, copy, readonly) NSArray *draggingItems;

/// Returns an instance of GNESectionedTableViewMove or one of its subclasses.
- (instancetype)initWithTableView:(GNESectionedTableView *)tableView;

- (void)addDraggingItem:(GNESectionedTableViewDraggingItem *)draggingItem;

- (void)moveSections:(GNEOrderedIndexSet *)fromSections toSections:(GNEOrderedIndexSet *)toSections;

- (void)moveRowsAtIndexPaths:(NSArray *)fromIndexPaths toIndexPaths:(NSArray *)toIndexPaths;

@end
