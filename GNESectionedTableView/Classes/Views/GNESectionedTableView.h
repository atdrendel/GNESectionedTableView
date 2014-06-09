//
//  GNESectionedTableView.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 5/27/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

@class GNESectionedTableView;


// ------------------------------------------------------------------------------------------


@protocol GNESectionedTableViewDataSource <NSObject>


/* Counts */
@required
- (NSUInteger)numberOfSectionsInTableView:(GNESectionedTableView *)tableView;
@required
- (NSUInteger)tableView:(GNESectionedTableView *)tableView numberOfRowsInSection:(NSUInteger)section;

/* Views */
@required
- (NSTableRowView *)tableView:(GNESectionedTableView *)tableView rowViewForRowAtIndexPath:(NSIndexPath *)indexPath;
@required
- (NSTableCellView *)tableView:(GNESectionedTableView *)tableView cellViewForRowAtIndexPath:(NSIndexPath *)indexPath;

/* Reordering */
@optional
- (BOOL)tableView:(GNESectionedTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (BOOL)tableView:(GNESectionedTableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath;


@end


// ------------------------------------------------------------------------------------------


@protocol GNESectionedTableViewDelegate <NSObject>


/* Sizing */
@required
- (CGFloat)tableView:(GNESectionedTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (CGFloat)tableView:(GNESectionedTableView *)tableView heightForHeaderInSection:(NSUInteger)section;

/* Views */
@optional
- (NSTableRowView *)tableView:(GNESectionedTableView *)tableView rowViewForHeaderInSection:(NSUInteger)section;
@optional
- (NSTableCellView *)tableView:(GNESectionedTableView *)tableView cellViewForHeaderInSection:(NSUInteger)section;


@end


// ------------------------------------------------------------------------------------------


@interface GNESectionedTableView : NSOutlineView


/// Table view's current data source, which must conform to GNESectionedTableViewDataSource.
@property (nonatomic, strong) id <GNESectionedTableViewDataSource> tableViewDataSource;

/// Table view's current delegate, which must conform to GNESectionedTableViewDelegate.
@property (nonatomic, strong) id <GNESectionedTableViewDelegate> tableViewDelegate;


#pragma mark - Initialization

/**
 Designated initializer.
 
 @param frameRect Frame of table view.
 @return Instance of GNESectionedTableView or one of its subclasses.
 */
- (instancetype)initWithFrame:(NSRect)frameRect;


#pragma mark - Frame of Table View Cells

/**
 Returns the frame of the table view cell at the specified index.
 
 @param indexPath Index path for the cell.
 @return Frame of the cell at the specified index path in the coordinate space of the table view.
 */
- (CGRect)frameOfCellAtIndexPath:(NSIndexPath *)indexPath;

@end
