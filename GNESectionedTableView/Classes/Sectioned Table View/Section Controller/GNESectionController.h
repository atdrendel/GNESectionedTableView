//
//  GNESectionController.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 8/2/15.
//  Copyright © 2015 Gone East LLC. All rights reserved.
//

#import "GNESectionedTableView.h"

@interface GNESectionController : NSObject

@property (nonatomic, weak) GNESectionedTableView *tableView;
@property (nonatomic, weak) id<GNESectionedTableViewDataSource> tableViewDataSource;
@property (nonatomic, weak) id<GNESectionedTableViewDelegate> tableViewDelegate;

@property (nonatomic, assign, readonly) NSUInteger numberOfSections;

- (nonnull instancetype)init NS_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithTableView:(GNESectionedTableView * _Nonnull)tableView
                               dataSource:(id<GNESectionedTableViewDataSource> _Nonnull)dataSource
                                 delegate:(id<GNESectionedTableViewDelegate> _Nonnull)delegate;

#pragma mark - Item Accessors
- (GNEOutlineViewParentItem * _Nullable)itemForSection:(NSUInteger)section;
- (NSArray * _Nonnull)itemsForSections:(NSIndexSet * _Nonnull)sections;

#pragma mark - Insert, Delete, and Update Rows
- (void)insertRowsAtIndexPaths:(NSArray * __nonnull)indexPaths
                 withAnimation:(NSTableViewAnimationOptions)animationOptions;
- (void)deleteRowsAtIndexPaths:(NSArray * __nonnull)indexPaths
                 withAnimation:(NSTableViewAnimationOptions)animationOptions;
- (void)moveRowsAtIndexPaths:(NSArray * __nonnull)fromIndexPaths
                toIndexPaths:(NSArray * __nonnull)toIndexPaths;
- (void)reloadRowsAtIndexPaths:(NSArray * __nonnull)indexPaths;

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

@end
