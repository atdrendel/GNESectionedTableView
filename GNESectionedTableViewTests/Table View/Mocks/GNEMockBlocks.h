//
//  GNEMockBlocks.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 4/5/15.
//  Copyright (c) 2015 Gone East LLC. All rights reserved.
//

#ifndef GNESectionedTableView_GNEMockBlocks_h
#define GNESectionedTableView_GNEMockBlocks_h

#pragma mark - GNESectionedTableViewDataSource

typedef void(^MockVoidBlock)();
typedef NSArray *(^MockReturnArrayBlock)();
typedef void(^MockUnsignedIntegerBlock)(NSUInteger unsignedInteger);
typedef void(^MockObjectBlock)(id object);
typedef void(^MockObjectObjectBlock)(id object1, id object2);
typedef void(^MockObjectUnsignedIntegerBlock)(id object, NSUInteger unsignedInteger);
typedef void(^MockViewUnsignedIntegerBlock)(NSView *view, NSUInteger section);
typedef void(^MockViewIndexPathBlock)(NSView *view, NSIndexPath *indexPath);

typedef NSUInteger(^MockNumberOfSectionsBlock)();
typedef NSUInteger(^MockNumberOfRowsBlock)(NSUInteger section);
typedef NSView *(^MockViewAtIndexPathBlock)(NSIndexPath *indexPath);

typedef BOOL(^MockCanDragSectionBlock)(NSUInteger section);
typedef BOOL(^MockCanDragSectionToSectionBlock)(NSUInteger fromSection, NSUInteger toSection);
typedef BOOL(^MockCanDragSectionsToSectionBlock)(NSIndexSet *fromSections, NSUInteger toSection);
typedef BOOL(^MockCanDragRowBlock)(NSIndexPath *indexPath);
typedef BOOL(^MockCanDragRowToRowBlock)(NSIndexPath *fromIndexPath, NSIndexPath *toIndexPath);
typedef BOOL(^MockCanDropRowOnSectionBlock)(NSIndexPath *fromIndexPath, NSUInteger toSection);
typedef BOOL(^MockCanDropRowOnRowBlock)(NSIndexPath *fromIndexPath, NSIndexPath *toIndexPath);

#pragma mark - GNESectionedTableViewDelegate

typedef CGFloat(^MockHeightForSectionBlock)(NSUInteger section);
typedef CGFloat(^MockHeightForRowBlock)(NSIndexPath *indexPath);
typedef NSView *(^MockViewForSectionBlock)(NSUInteger section);
typedef NSView *(^MockViewForRowBlock)(NSIndexPath *indexPath);
typedef BOOL(^MockShouldExpandCollapseSectionBlock)(NSUInteger section);
typedef BOOL(^MockShouldSelectSectionBlock)(NSUInteger section);
typedef BOOL(^MockShouldSelectRowBlock)(NSIndexPath *indexPath);

#endif
