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

@import Cocoa;
#import "GNEOutlineViewItem.h"
#import "GNEOutlineViewParentItem.h"
#import "GNEOrderedIndexSet.h"
#import "NSMutableArray+GNESectionedTableView.h"
#import "NSIndexPath+GNESectionedTableView.h"
#import "NSOutlineView+GNE_Additions.h"

@class GNESectionedTableView;


// ------------------------------------------------------------------------------------------


#ifndef GNE_ASSERT_ENABLED
    #if DEBUG
        #define GNE_ASSERT_ENABLED 1
    #else
        #define GNE_ASSERT_ENABLED 0
    #endif
#endif

#ifndef GNEParameterAssert
    #if GNE_ASSERT_ENABLED
        #define GNEParameterAssert(condition) NSParameterAssert(condition)
    #else
        #define GNEParameterAssert(condition) do { } while (0)
    #endif
#endif

#ifndef GNEAssert1
    #if GNE_ASSERT_ENABLED
        #define GNEAssert1(condition, desc, arg1) NSAssert1(condition, desc, arg1)
    #else
        #define GNEAssert1(condition, desc, arg1) do { } while (0)
    #endif
#endif

#ifndef GNEAssert2
    #if GNE_ASSERT_ENABLED
        #define GNEAssert2(condition, desc, arg1, arg2) NSAssert2(condition, desc, arg1, arg2)
    #else
        #define GNEAssert2(condition, desc, arg1, arg2) do { } while (0)
    #endif
#endif

#ifndef GNE_CRUD_LOGGING_ENABLED
    #if DEBUG
        #define GNE_CRUD_LOGGING_ENABLED 1
    #else
        #define GNE_CRUD_LOGGING_ENABLED 0
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
- (NSUInteger)numberOfSectionsInTableView:(GNESectionedTableView * __nonnull)tableView;
@required
- (NSUInteger)tableView:(GNESectionedTableView * __nonnull)tableView numberOfRowsInSection:(NSUInteger)section;

/* Views */
@required
- (NSTableRowView * __nonnull)tableView:(GNESectionedTableView * __nonnull)tableView
                rowViewForRowAtIndexPath:(NSIndexPath * __nonnull)indexPath;
@required
- (NSTableCellView * __nonnull)tableView:(GNESectionedTableView * __nonnull)tableView
                cellViewForRowAtIndexPath:(NSIndexPath * __nonnull)indexPath;

/* Drag-and-drop */
@optional
- (NSArray * __nullable)draggedTypesForTableView:(GNESectionedTableView * __nonnull)tableView;
@optional
- (void)tableViewDraggingSessionWillBegin:(GNESectionedTableView * __nonnull)tableView;
@optional
- (void)tableView:(GNESectionedTableView * __nonnull)tableView didUpdateDrag:(id <NSDraggingInfo> __nonnull)info;
@optional
- (BOOL)tableView:(GNESectionedTableView * __nonnull)tableView canDragSection:(NSUInteger)section;
@optional
- (BOOL)tableView:(GNESectionedTableView * __nonnull)tableView
   canDragSection:(NSUInteger)fromSection
        toSection:(NSUInteger)toSection;
@optional
- (void)tableView:(GNESectionedTableView * __nonnull)tableView
  didDragSections:(NSIndexSet * __nonnull)fromSections
        toSection:(NSUInteger)toSection;
@optional
-       (BOOL)tableView:(GNESectionedTableView * __nonnull)tableView
  canDragRowAtIndexPath:(NSIndexPath * __nonnull)indexPath;
@optional
-       (BOOL)tableView:(GNESectionedTableView * __nonnull)tableView
  canDropRowAtIndexPath:(NSIndexPath * __nonnull)fromIndexPath
      onHeaderInSection:(NSUInteger)section;
@optional
-       (BOOL)tableView:(GNESectionedTableView * __nonnull)tableView
  canDropRowAtIndexPath:(NSIndexPath * __nonnull)fromIndexPath
       onRowAtIndexPath:(NSIndexPath * __nonnull)toIndexPath;
@optional
-       (BOOL)tableView:(GNESectionedTableView * __nonnull)tableView
  canDragRowAtIndexPath:(NSIndexPath * __nonnull)fromIndexPath
            toIndexPath:(NSIndexPath * __nonnull)toIndexPath;
@optional
-       (void)tableView:(GNESectionedTableView * __nonnull)tableView
didDropRowsAtIndexPaths:(NSArray * __nonnull)fromIndexPaths
      onHeaderInSection:(NSUInteger)section;
@optional
-       (void)tableView:(GNESectionedTableView * __nonnull)tableView
didDropRowsAtIndexPaths:(NSArray * __nonnull)fromIndexPaths
       onRowAtIndexPath:(NSIndexPath * __nonnull)toIndexPath;
@optional
-       (void)tableView:(GNESectionedTableView * __nonnull)tableView
didDragRowsAtIndexPaths:(NSArray * __nonnull)fromIndexPaths
            toIndexPath:(NSIndexPath * __nonnull)toIndexPath;
@optional
- (void)tableViewDraggingSessionDidEnd:(GNESectionedTableView * __nonnull)tableView;

@end


// ------------------------------------------------------------------------------------------


@protocol GNESectionedTableViewDelegate <NSObject>

/* Sizing */
@required
-       (CGFloat)tableView:(GNESectionedTableView * __nonnull)tableView
   heightForRowAtIndexPath:(NSIndexPath * __nonnull)indexPath;
@optional
/// Required if the table view includes headers.
- (CGFloat)tableView:(GNESectionedTableView * __nonnull)tableView heightForHeaderInSection:(NSUInteger)section;
@optional
/// Required if the table view includes footers.
- (CGFloat)tableView:(GNESectionedTableView * __nonnull)tableView heightForFooterInSection:(NSUInteger)section;

/* Views */
@required
- (NSTableRowView * __nonnull)tableView:(GNESectionedTableView * __nonnull)tableView
               rowViewForRowAtIndexPath:(NSIndexPath * __nonnull)indexPath;
@required
- (NSTableCellView * __nonnull)tableView:(GNESectionedTableView * __nonnull)tableView
               cellViewForRowAtIndexPath:(NSIndexPath * __nonnull)indexPath;
@optional
/// Required if the table view includes headers.
- (NSTableRowView * __nonnull)tableView:(GNESectionedTableView * __nonnull)tableView
              rowViewForHeaderInSection:(NSUInteger)section;
@optional
/// Required if the table view includes headers.
- (NSTableCellView * __nonnull)tableView:(GNESectionedTableView * __nonnull)tableView
              cellViewForHeaderInSection:(NSUInteger)section;
@optional
/// Required if the table view includes footers.
- (NSTableRowView * __nonnull)tableView:(GNESectionedTableView * __nonnull)tableView
              rowViewForFooterInSection:(NSUInteger)section;
@optional
/// Required if the table view includes footers.
- (NSTableCellView * __nonnull)tableView:(GNESectionedTableView * __nonnull)tableView
              cellViewForFooterInSection:(NSUInteger)section;
@optional
-   (void)tableView:(GNESectionedTableView * __nonnull)tableView
  didDisplayRowView:(NSTableRowView * __nonnull)rowView
 forHeaderInSection:(NSUInteger)section;
@optional
-   (void)tableView:(GNESectionedTableView * __nonnull)tableView
  didDisplayRowView:(NSTableRowView * __nonnull)rowView
 forFooterInSection:(NSUInteger)section;
@optional
- (void)tableView:(GNESectionedTableView * __nonnull)tableView
didDisplayRowView:(NSTableRowView * __nonnull)rowView
forRowAtIndexPath:(NSIndexPath * __nonnull)indexPath;
@optional
-       (void)tableView:(GNESectionedTableView * __nonnull)tableView
didEndDisplayingRowView:(NSTableRowView * __nonnull)rowView
     forHeaderInSection:(NSUInteger)section;
@optional
-       (void)tableView:(GNESectionedTableView * __nonnull)tableView
didEndDisplayingRowView:(NSTableRowView * __nonnull)rowView
     forFooterInSection:(NSUInteger)section;
@optional
-       (void)tableView:(GNESectionedTableView * __nonnull)tableView
didEndDisplayingRowView:(NSTableRowView * __nonnull)rowView
      forRowAtIndexPath:(NSIndexPath * __nonnull)indexPath;

/* Expand/Collapse */
@optional
- (BOOL)tableView:(GNESectionedTableView * __nonnull)tableView shouldExpandSection:(NSUInteger)section;
@optional
- (BOOL)tableView:(GNESectionedTableView * __nonnull)tableView shouldCollapseSection:(NSUInteger)section;
@optional
- (void)tableView:(GNESectionedTableView * __nonnull)tableView willExpandSection:(NSUInteger)section;
@optional
- (void)tableView:(GNESectionedTableView * __nonnull)tableView willCollapseSection:(NSUInteger)section;
@optional
- (void)tableView:(GNESectionedTableView * __nonnull)tableView didExpandSection:(NSUInteger)section;
@optional
- (void)tableView:(GNESectionedTableView * __nonnull)tableView didCollapseSection:(NSUInteger)section;

/* Selection */
@optional
- (BOOL)tableView:(GNESectionedTableView * __nonnull)tableView shouldSelectHeaderInSection:(NSUInteger)section;
@optional
-           (BOOL)tableView:(GNESectionedTableView * __nonnull)tableView
 shouldSelectRowAtIndexPath:(NSIndexPath * __nonnull)indexPath;
@optional
-                   (void)tableView:(GNESectionedTableView * __nonnull)tableView
  proposedSelectedHeadersInSections:(NSIndexSet * __nonnull * __nonnull)sectionIndexes
      proposedSelectedRowIndexPaths:(NSArray * __nonnull * __nonnull)indexPaths;
@optional
- (void)tableView:(GNESectionedTableView * __nonnull)tableView didClickHeaderInSection:(NSUInteger)section;
@optional
- (void)tableView:(GNESectionedTableView * __nonnull)tableView didClickFooterInSection:(NSUInteger)section;
@optional
- (void)tableView:(GNESectionedTableView * __nonnull)tableView didDoubleClickHeaderInSection:(NSUInteger)section;
@optional
- (void)tableView:(GNESectionedTableView * __nonnull)tableView didDoubleClickFooterInSection:(NSUInteger)section;
@optional
-       (void)tableView:(GNESectionedTableView * __nonnull)tableView
 didClickRowAtIndexPath:(NSIndexPath * __nonnull)indexPath;
@optional
-               (void)tableView:(GNESectionedTableView * __nonnull)tableView
   didDoubleClickRowAtIndexPath:(NSIndexPath * __nonnull)indexPath;
@optional
- (void)tableViewDidDeselectAllHeadersAndRows:(GNESectionedTableView * __nonnull)tableView;
@optional
- (void)tableView:(GNESectionedTableView * __nonnull)tableView didSelectHeaderInSection:(NSUInteger)section;
@optional
-       (void)tableView:(GNESectionedTableView * __nonnull)tableView
didSelectRowAtIndexPath:(NSIndexPath * __nonnull)indexPath;
@optional
-           (void)tableView:(GNESectionedTableView * __nonnull)tableView
 didSelectHeadersInSections:(NSIndexSet * __nonnull)sections;
@optional
-           (void)tableView:(GNESectionedTableView * __nonnull)tableView
  didSelectRowsAtIndexPaths:(NSArray * __nonnull)indexPaths;

@end


// ------------------------------------------------------------------------------------------

@interface GNESectionedTableView : NSOutlineView

/// Table view's current data source, which must conform to GNESectionedTableViewDataSource.
@property (nonatomic, strong, nullable) id <GNESectionedTableViewDataSource> tableViewDataSource;

/// Table view's current delegate, which must conform to GNESectionedTableViewDelegate.
@property (nonatomic, strong, nullable) id <GNESectionedTableViewDelegate> tableViewDelegate;

/// YES if the table view automatically expands sections when reloading data, otherwise NO.
/// Default: YES.
@property (nonatomic, assign) BOOL autoExpandSections;

/// Returns the number of sections in the table view.
@property (nonatomic, assign, readonly) NSUInteger numberOfSections;

/// Returns the index path for the currently-selected row or nil if nothing is selected.
@property (nonatomic, strong, readonly, nullable) NSIndexPath *selectedIndexPath;

/**
 Returns an array of index paths for the currently-selected rows or nil if nothing is selected.
 
 @discussion The index paths are returned sorted in ascending (section-first) order.
 */
@property (nonatomic, strong, readonly, nonnull) NSArray *selectedIndexPaths;

/// Returns YES if the table view is in an -beginUpdate/-endUpdates block, otherwise NO.
@property (nonatomic, assign, readonly) BOOL isUpdating;


#pragma mark - Initialization
/**
 Designated initializer.
 
 @param frameRect Frame of table view.
 @return Instance of GNESectionedTableView or one of its subclasses.
 */
- (nonnull instancetype)initWithFrame:(NSRect)frameRect NS_DESIGNATED_INITIALIZER;


/**
 Designated initializer. **Currently not fully implemented**
 
 @param coder An unarchiver object.
 @return Instance of GNESectionedTableView or one of its subclasses or nil.
 */
- (nullable instancetype)initWithCoder:(NSCoder * __nonnull)coder NS_DESIGNATED_INITIALIZER;


#pragma mark - Reload data
/**
 Reloads the table view. This deletes all of the stored section, row, and selection data and queries the data
 source and delegates to rebuild the table.
 
 @discussion This method replaces reloadItem: and reloadItem:reloadChildren: in NSOutlineView. It is strongly
 advised to not call those methods.
 */
- (void)reloadData;


#pragma mark - Views
/**
 Returns the index path corresponding to the specified view or nil if the view is not an instance
 of NSTableRowView or a subview of an instance of NSTableRowView.
 
 @param view Instance of NSTableRowView or a subview of an instance of NSTableRowView that is
 currently present in the table view.
 @return Index path corresponding to the specified view or nil.
 */
- (NSIndexPath * __nullable)indexPathForView:(NSView * __nullable)view;

/**
 Returns the table cell view at the specified index path, if one exists.
 
 @discussion The index path can correspond to a header, normal row, or footer. This method does not
 create the view if it hasn't already been created.
 @param indexPath Index path of a header, cell, or footer.
 @return Cell view at the specified index path, or nil.
 */
- (NSTableCellView * __nullable)cellViewAtIndexPath:(NSIndexPath * __nullable)indexPath;


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
 Returns YES if the specified index path points to a section header or footer or if the index
 path's section is less than the total number of sections in the table view and the row is less
 than the total number of rows in the section, otherwise NO.
 */
- (BOOL)isIndexPathValid:(NSIndexPath * __nullable)indexPath;

/// Returns YES if the specified index path belongs to a section header, otherwise NO.
- (BOOL)isIndexPathHeader:(NSIndexPath * __nullable)indexPath;

/// Returns YES if the specified index path belongs to a section footer, otherwise NO.
- (BOOL)isIndexPathFooter:(NSIndexPath * __nullable)indexPath;

/**
 Returns the index path for the specified section header, or nil if the section isn't valid.
 
 @discussion This method is the preferred way of retrieving index paths for section headers.
 @param section Section index to generate a header index path for.
 @return Index path corresponding to the specified section header, or nil if the
 section is invalid.
 */
- (NSIndexPath * __nullable)indexPathForHeaderInSection:(NSUInteger)section;

/**
 Returns the index path for the specified section footer, or nil if the section isn't valid.
 
 @discussion This method is the preferred way of retrieving index paths for section footers.
 @param section Section index to generate a footer index path for.
 @return Index path corresponding to the specified section footer, or nil if the
 section is invalid.
 */
- (NSIndexPath * __nullable)indexPathForFooterInSection:(NSUInteger)section;

/**
 Returns the index path mapped to the underlying NSTableView row, or nil if the row isn't valid.
 
 @discussion If the specified row maps to a section header, the index path will have the correct
 section, but the row will equal NSNotFound.
 @param row NSTableView row corresponding to a section header or row in the table view.
 @return Index path corresponding to the specified table view row or nil.
 */
- (NSIndexPath * __nullable)indexPathForTableViewRow:(NSInteger)row;

/**
 Returns the NSTableView row for the specified index path, if the index path maps to a valid
 row, otherwise -1.
 
 @param indexPath Index path to match to a table view row.
 @return The NSTableView row mapped to the specified index path or -1.
 */
- (NSInteger)tableViewRowForIndexPath:(NSIndexPath * __nullable)indexPath;


#pragma mark - Insertion, Deletion, Move, and Update
- (void)insertRowsAtIndexPaths:(NSArray * __nonnull)indexPaths
                 withAnimation:(NSTableViewAnimationOptions)animationOptions;
- (void)deleteRowsAtIndexPaths:(NSArray * __nonnull)indexPaths
                 withAnimation:(NSTableViewAnimationOptions)animationOptions;
- (void)moveRowAtIndexPath:(NSIndexPath * __nonnull)fromIndexPath
               toIndexPath:(NSIndexPath * __nonnull)toIndexPath;
- (void)moveRowsAtIndexPaths:(NSArray * __nonnull)fromIndexPaths
                toIndexPaths:(NSArray * __nonnull)toIndexPaths;
/**
 Moves the rows at the specified from index paths to the specified to index path and maintains the
 order of the rows.
 */
- (void)moveRowsAtIndexPaths:(NSArray * __nonnull)fromIndexPaths toIndexPath:(NSIndexPath * __nonnull)toIndexPath;
- (void)reloadRowsAtIndexPaths:(NSArray * __nonnull)indexPaths;

/// Inserts the specified sections with the specified animation and expands them.
- (void)insertSections:(NSIndexSet * __nonnull)sections
         withAnimation:(NSTableViewAnimationOptions)animationOptions;
/// Inserts the specified sections with the specified animation and expands or collapses them as specified.
- (void)insertSections:(NSIndexSet * __nonnull)sections
         withAnimation:(NSTableViewAnimationOptions)animationOptions
             expanded:(BOOL)expanded;
- (void)deleteSections:(NSIndexSet * __nonnull)sections
         withAnimation:(NSTableViewAnimationOptions)animationOptions;
- (void)moveSection:(NSUInteger)fromSection toSection:(NSUInteger)toSection;
- (void)moveSections:(GNEOrderedIndexSet * __nonnull)fromSections
          toSections:(GNEOrderedIndexSet * __nonnull)toSections;
/**
 Moves the specified sections to the specified section index. The order of the from sections is maintained.
 
 @discussion This method can be used to move multiple sections to a different section index. If the sections
 are intended to be moved to the end of the table view, then the toSection should equal the number of sections
 in the table view.
 @param fromSections Indexes of sections to be moved.
 @param toSection Index of section to move the specified sections to.
 */
- (void)moveSections:(GNEOrderedIndexSet * __nonnull)fromSections toSection:(NSUInteger)toSection;

- (void)reloadSections:(NSIndexSet * __nonnull)sections;


#pragma mark - Expand/Collapse Sections
- (BOOL)isSectionExpanded:(NSUInteger)section;
- (void)expandAllSections:(BOOL)animated;
- (void)expandSection:(NSUInteger)section animated:(BOOL)animated;
- (void)expandSections:(NSIndexSet * __nonnull)sections animated:(BOOL)animated;
- (void)collapseAllSections:(BOOL)animated;
- (void)collapseSection:(NSUInteger)section animated:(BOOL)animated;
- (void)collapseSections:(NSIndexSet * __nonnull)sections animated:(BOOL)animated;


#pragma mark - Selection
- (BOOL)isIndexPathSelected:(NSIndexPath * __nonnull)indexPath;
- (void)selectRowAtIndexPath:(NSIndexPath * __nullable)indexPath byExtendingSelection:(BOOL)extend;
- (void)selectRowsAtIndexPaths:(NSArray * __nullable)indexPaths byExtendingSelection:(BOOL)extend;


#pragma mark - Layout Support
/**
 Returns the index path for the section header or row at the specified point or nil if the point
 does not correspond to a subview of the table view.
 
 @param point Point in the coordinate system of the receiver.
 @return Index path for the section header or row at the specified point or nil.
 */
- (NSIndexPath * __nullable)indexPathForViewAtPoint:(CGPoint)point;


/**
 Returns the frame of the section header or row at the specified index path.
 
 @discussion As with the rest of this project, this method assumes that the table view only has one
 column. If the table view has more than one column, this method returns the frame for the last
 column in the row.
 @param indexPath Index path for the section header or row.
 @return Frame of the view at the specified index path in the coordinate space of the table view.
 */
- (CGRect)frameOfViewAtIndexPath:(NSIndexPath * __nonnull)indexPath;


/**
 Returns the frame for the section header and all expanded rows of specified section.
 
 @param section Section index.
 @return Frame encompassing the section header and all expanded rows of the specified section.
 */
- (CGRect)frameOfSection:(NSUInteger)section;


#pragma mark - Scrolling
- (void)scrollRowAtIndexPathToVisible:(NSIndexPath * __nonnull)indexPath;

@end
