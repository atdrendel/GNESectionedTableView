//
//  GNESectionedTableView.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 5/27/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 Gone East LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "GNEOutlineViewItem.h"
#import "GNEOutlineViewParentItem.h"
#import "NSMutableArray+GNESectionedTableView.h"
#import "NSIndexPath+GNESectionedTableView.h"
#import "NSOutlineView+GNE_Additions.h"

@class GNESectionedTableView;


// ------------------------------------------------------------------------------------------


// By default, unsafe row heights are allowed. They work in 10.9 and above, but not 10.8.
#ifndef UNSAFE_ROW_HEIGHT_ALLOWED
    #define UNSAFE_ROW_HEIGHT_ALLOWED 1
#endif

#if UNSAFE_ROW_HEIGHT_ALLOWED
static const CGFloat WLSectionedTableViewInvisibleRowHeight = 0.00001f;
#else
static const CGFloat WLSectionedTableViewInvisibleRowHeight = 1.0f;
#endif


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

/* Drag-and-drop */
@optional
- (NSArray *)draggedTypesForTableView:(GNESectionedTableView *)tableView;
@optional
- (BOOL)tableView:(GNESectionedTableView *)tableView canDragSection:(NSUInteger)section;
@optional
- (BOOL)tableView:(GNESectionedTableView *)tableView
   canDragSection:(NSUInteger)fromSection
        toSection:(NSUInteger)toSection;
@optional
- (void)tableView:(GNESectionedTableView *)tableView
  didDragSections:(NSIndexSet *)fromSections
        toSection:(NSUInteger)toSection;
@optional
- (BOOL)tableView:(GNESectionedTableView *)tableView canDragRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
-       (BOOL)tableView:(GNESectionedTableView *)tableView
  canDragRowAtIndexPath:(NSIndexPath *)fromIndexPath
              toSection:(NSUInteger)toSection;
@optional
-       (BOOL)tableView:(GNESectionedTableView *)tableView
  canDragRowAtIndexPath:(NSIndexPath *)fromIndexPath
            toIndexPath:(NSIndexPath *)toIndexPath;
@optional
-       (void)tableView:(GNESectionedTableView *)tableView
didDragRowsAtIndexPaths:(NSArray *)fromIndexPaths
            toIndexPath:(NSIndexPath *)toIndexPath;
@optional
-       (void)tableView:(GNESectionedTableView *)tableView
didDragRowsAtIndexPaths:(NSArray *)fromIndexPaths
              toSection:(NSUInteger)toSection;


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
@optional
- (void)tableView:(GNESectionedTableView *)tableView didDisplayRowView:(NSTableRowView *)rowView forRow:(NSUInteger)row;
@optional
- (void)tableView:(GNESectionedTableView *)tableView didDisplayCellView:(NSTableCellView *)cellView forRow:(NSUInteger)row;
@optional
        - (void)tableView:(GNESectionedTableView *)tableView
  didEndDisplayingRowView:(NSTableRowView *)rowView
                   forRow:(NSUInteger)row;
@optional
        - (void)tableView:(GNESectionedTableView *)tableView
 didEndDisplayingCellView:(NSTableCellView *)cellView
                   forRow:(NSUInteger)row;

/* Expand/Collapse */
@optional
- (BOOL)tableView:(GNESectionedTableView *)tableView shouldExpandSection:(NSUInteger)section;
@optional
- (BOOL)tableView:(GNESectionedTableView *)tableView shouldCollapseSection:(NSUInteger)section;

/* Selection */
@optional
- (BOOL)tableView:(GNESectionedTableView *)tableView shouldSelectHeaderInSection:(NSUInteger)section;
@optional
- (BOOL)tableView:(GNESectionedTableView *)tableView shouldSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (void)tableView:(GNESectionedTableView *)tableView didClickHeaderInSection:(NSUInteger)section;
@optional
- (void)tableView:(GNESectionedTableView *)tableView didDoubleClickHeaderInSection:(NSUInteger)section;
@optional
- (void)tableView:(GNESectionedTableView *)tableView didClickRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (void)tableView:(GNESectionedTableView *)tableView didDoubleClickRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (void)tableViewDidDeselectAllHeadersAndRows:(GNESectionedTableView *)tableView;
@optional
- (void)tableView:(GNESectionedTableView *)tableView didSelectHeaderInSection:(NSUInteger)section;
@optional
- (void)tableView:(GNESectionedTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (void)tableView:(GNESectionedTableView *)tableView didSelectHeadersInSections:(NSIndexSet *)sections;
@optional
- (void)tableView:(GNESectionedTableView *)tableView didSelectRowsAtIndexPaths:(NSArray *)indexPaths;


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


#pragma mark - Insertion, Deletion, Move, and Update
- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withAnimation:(NSTableViewAnimationOptions)animationOptions;
- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withAnimation:(NSTableViewAnimationOptions)animationOptions;
- (void)moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
- (void)moveRowsAtIndexPaths:(NSArray *)fromIndexPaths toIndexPaths:(NSArray *)toIndexPaths;
/**
 Moves the rows at the specified from index paths to the specified to index path and maintains the
 order of the rows.
 */
- (void)moveRowsAtIndexPaths:(NSArray *)fromIndexPaths toIndexPath:(NSIndexPath *)toIndexPath;
- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths;

- (void)insertSections:(NSIndexSet *)sections withAnimation:(NSTableViewAnimationOptions)animationOptions;
- (void)deleteSections:(NSIndexSet *)sections withAnimation:(NSTableViewAnimationOptions)animationOptions;
- (void)moveSection:(NSUInteger)fromSection toSection:(NSUInteger)toSection;

/**
 Moves the specified sections to the specified section index. The order of the from sections is maintained.
 
 @discussion This method can be used to move multiple sections to a different section index. If the sections
 are intended to be moved to the end of the table view, then the toSection should equal the number of sections
 in the table view.
 @param fromSections Indexes of sections to be moved.
 @param toSection Index of section to move the specified sections to.
 */
- (void)moveSections:(NSIndexSet *)fromSections toSection:(NSUInteger)toSection;

- (void)reloadSections:(NSIndexSet *)sections;


#pragma mark - Expand/Collapse Sections
- (BOOL)isSectionExpanded:(NSUInteger)section;
- (void)expandSection:(NSUInteger)section animated:(BOOL)animated;
- (void)collapseSection:(NSUInteger)section animated:(BOOL)animated;


#pragma mark - Selection
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath byExtendingSelection:(BOOL)extend;


#pragma mark - Frame of Table View Cells
/**
 Returns the frame of the table view cell at the specified index.
 
 @param indexPath Index path for the cell.
 @return Frame of the cell at the specified index path in the coordinate space of the table view.
 */
- (CGRect)frameOfCellAtIndexPath:(NSIndexPath *)indexPath;

@end
