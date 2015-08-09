//
//  GNESectionedTableViewController.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 8/2/15.
//  Copyright © 2015 Gone East LLC. All rights reserved.
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

#import "GNESectionedTableView.h"

@interface GNESectionedTableViewController : NSObject

@property (nonatomic, weak) GNESectionedTableView *tableView;
@property (nonatomic, weak) id<GNESectionedTableViewDataSource> tableViewDataSource;
@property (nonatomic, weak) id<GNESectionedTableViewDelegate> tableViewDelegate;

@property (nonatomic, assign, readonly) NSUInteger numberOfSections;

- (nonnull instancetype)init NS_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithTableView:(GNESectionedTableView * _Nonnull)tableView
                               dataSource:(id<GNESectionedTableViewDataSource> _Nonnull)dataSource
                                 delegate:(id<GNESectionedTableViewDelegate> _Nonnull)delegate;

#pragma mark - Expand/Collapse Sections
- (BOOL)isSectionExpanded:(NSUInteger)section;
- (void)expandAllSections:(BOOL)animated;
- (void)expandSection:(NSUInteger)section animated:(BOOL)animated;
- (void)expandSections:(NSIndexSet * __nonnull)sections animated:(BOOL)animated;
- (void)collapseAllSections:(BOOL)animated;
- (void)collapseSection:(NSUInteger)section animated:(BOOL)animated;
- (void)collapseSections:(NSIndexSet * __nonnull)sections animated:(BOOL)animated;

#pragma mark - Insert, Delete, and Update Sections
- (void)insertSections:(NSIndexSet * __nonnull)sections
         withAnimation:(NSTableViewAnimationOptions)animationOptions;
- (void)insertSections:(NSIndexSet * __nonnull)sections
         withAnimation:(NSTableViewAnimationOptions)animationOptions
              expanded:(BOOL)expanded;
- (void)deleteSections:(NSIndexSet * __nonnull)sections
         withAnimation:(NSTableViewAnimationOptions)animationOptions;
- (void)moveSections:(GNEOrderedIndexSet * __nonnull)fromSections
          toSections:(GNEOrderedIndexSet * __nonnull)toSections;

#pragma mark - Insert, Delete, and Update Rows
- (void)insertRowsAtIndexPaths:(NSArray * __nonnull)indexPaths
                 withAnimation:(NSTableViewAnimationOptions)animationOptions;
- (void)deleteRowsAtIndexPaths:(NSArray * __nonnull)indexPaths
                 withAnimation:(NSTableViewAnimationOptions)animationOptions;
- (void)moveRowsAtIndexPaths:(NSArray * __nonnull)fromIndexPaths
                toIndexPaths:(NSArray * __nonnull)toIndexPaths;
- (void)reloadRowsAtIndexPaths:(NSArray * __nonnull)indexPaths;

@end
