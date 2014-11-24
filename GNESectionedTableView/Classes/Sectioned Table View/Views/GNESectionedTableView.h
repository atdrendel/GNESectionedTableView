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


#ifndef GNE_PARAMETER_ASSERT_ENABLED
    #if DEBUG
        #define GNE_PARAMETER_ASSERT_ENABLED 1
    #else
        #define GNE_PARAMETER_ASSERT_ENABLED 0
    #endif
#endif

#ifndef GNEParameterAssert
    #if GNE_PARAMETER_ASSERT_ENABLED
        #define GNEParameterAssert(condition) NSParameterAssert(condition)
    #else
        #define GNEParameterAssert(condition) do { } while (0)
    #endif
#endif


// By default, unsafe row heights are allowed. They work in 10.9 and above, but not 10.8.
#ifndef UNSAFE_ROW_HEIGHT_ALLOWED
    #define UNSAFE_ROW_HEIGHT_ALLOWED 1
#endif

#if UNSAFE_ROW_HEIGHT_ALLOWED
static const CGFloat GNESectionedTableViewInvisibleRowHeight = 0.00001f;
#else
static const CGFloat GNESectionedTableViewInvisibleRowHeight = 1.0f;
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
  canDropRowAtIndexPath:(NSIndexPath *)fromIndexPath
       onRowAtIndexPath:(NSIndexPath *)toIndexPath;
@optional
-       (BOOL)tableView:(GNESectionedTableView *)tableView
  canDragRowAtIndexPath:(NSIndexPath *)fromIndexPath
            toIndexPath:(NSIndexPath *)toIndexPath;
@optional
-       (void)tableView:(GNESectionedTableView *)tableView
didDropRowsAtIndexPaths:(NSArray *)fromIndexPaths
       onRowAtIndexPath:(NSIndexPath *)toIndexPath;
@optional
-       (void)tableView:(GNESectionedTableView *)tableView
didDragRowsAtIndexPaths:(NSArray *)fromIndexPaths
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
@optional
- (void)tableView:(GNESectionedTableView *)tableView
didDisplayRowView:(NSTableRowView *)rowView
      atIndexPath:(NSIndexPath *)indexPath;
@optional
-   (void)tableView:(GNESectionedTableView *)tableView
 didDisplayCellView:(NSTableCellView *)cellView
        atIndexPath:(NSIndexPath *)indexPath;
@optional
-       (void)tableView:(GNESectionedTableView *)tableView
didEndDisplayingRowView:(NSTableRowView *)rowView
            atIndexPath:(NSIndexPath *)indexPath;
@optional
-           (void)tableView:(GNESectionedTableView *)tableView
   didEndDisplayingCellView:(NSTableCellView *)cellView
                atIndexPath:(NSIndexPath *)indexPath;

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

/// Returns the number of sections in the table view.
@property (nonatomic, assign, readonly) NSUInteger numberOfSections;

/// Returns the index path for the currently-selected row or nil if nothing is selected.
@property (nonatomic, strong, readonly) NSIndexPath *selectedIndexPath;

/**
 Returns an array of index paths for the currently-selected rows or nil if nothing is selected.
 
 @discussion The index paths are returned sorted in ascending (section-first) order.
 */
@property (nonatomic, strong, readonly) NSArray *selectedIndexPaths;


#pragma mark - Initialization
/**
 Designated initializer.
 
 @param frameRect Frame of table view.
 @return Instance of GNESectionedTableView or one of its subclasses.
 */
- (instancetype)initWithFrame:(NSRect)frameRect;


#pragma mark - Views
/**
 Returns the index path corresponding to the specified view or nil if the view is not an instance
 of NSTableRowView or a subview of an instance of NSTableRowView.
 
 @param view Instance of NSTableRowView or a subview of an instance of NSTableRowView that is
 currently present in the table view.
 @return Index path corresponding to the specified view or nil.
 */
- (NSIndexPath *)indexPathForView:(NSView *)view;


#pragma mark - Counts
/**
 Returns the number of rows in the specified section.
 
 @discussion When exceptions are enabled, if the specified section is greater than or equal to the
 number of sections in the table view, an exception is thrown. Otherwise, NSNotFound is returned.
 @param section Section index to find the number of rows of.
 @return Number of rows in the specified section.
 */
- (NSUInteger)numberOfRowsInSection:(NSUInteger)section;


#pragma mark - Index Paths / NSTableView Rows
/**
 Returns YES if the specified index path's section is less than the total number of sections in the table
 view and the row is less than the total number of rows in the section, otherwise NO.
 */
- (BOOL)isValidIndexPath:(NSIndexPath *)indexPath;

/**
 Returns the index path for the specified section, or nil if the section isn't valid.
 
 @discussion Section index paths have a value of section = section and row = NSNotFound.
 @param section Section index to generate an index path for.
 @return Index path corresponding to the specified section, or nil if the section is invalid.
 */
- (NSIndexPath *)indexPathForSection:(NSUInteger)section;

/**
 Returns the index path mapped to the underlying NSTableView row, or nil if the row isn't valid.
 
 @discussion If the specified row maps to a section header, the index path will have the correct
 section, but the row will equal NSNotFound.
 @param row NSTableView row corresponding to a section header or row in the table view.
 @return Index path corresponding to the specified table view row or nil.
 */
- (NSIndexPath *)indexPathForTableViewRow:(NSInteger)row;

/**
 Returns the NSTableView row for the specified index path, if the index path maps to a valid
 row, otherwise -1.
 
 @param indexPath Index path to match to a table view row.
 @return The NSTableView row mapped to the specified index path or -1.
 */
- (NSInteger)tableViewRowForIndexPath:(NSIndexPath *)indexPath;


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
- (void)expandAllSections:(BOOL)animated;
- (void)expandSection:(NSUInteger)section animated:(BOOL)animated;
- (void)expandSections:(NSIndexSet *)sections animated:(BOOL)animated;
- (void)collapseAllSections:(BOOL)animated;
- (void)collapseSection:(NSUInteger)section animated:(BOOL)animated;
- (void)collapseSections:(NSIndexSet *)sections animated:(BOOL)animated;


#pragma mark - Selection
- (BOOL)isIndexPathSelected:(NSIndexPath *)indexPath;
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath byExtendingSelection:(BOOL)extend;


#pragma mark - Layout Support
/**
 Returns the index path for the section header or row at the specified point or nil if the point
 does not correspond to a subview of the table view.
 
 @param point Point in the coordinate system of the receiver.
 @return Index path for the section header or row at the specified point or nil.
 */
- (NSIndexPath *)indexPathForViewAtPoint:(CGPoint)point;


/**
 Returns the frame of the section header or row at the specified index path.
 
 @discussion As with the rest of this project, this method assumes that the table view only has one
 column. If the table view has more than one column, this method returns the frame for the last
 column in the row.
 @param indexPath Index path for the section header or row.
 @return Frame of the view at the specified index path in the coordinate space of the table view.
 */
- (CGRect)frameOfViewAtIndexPath:(NSIndexPath *)indexPath;


/**
 Returns the frame for the section header and all expanded rows of specified section.
 
 @param section Section index.
 @return Frame encompassing the section header and all expanded rows of the specified section.
 */
- (CGRect)frameOfSection:(NSUInteger)section;


#pragma mark - Scrolling
- (void)scrollRowAtIndexPathToVisible:(NSIndexPath *)indexPath;

@end
