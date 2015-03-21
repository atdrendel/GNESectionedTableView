//
//  GNEMockDataSource.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 3/21/15.
//  Copyright (c) 2015 Gone East LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GNEMockObject.h"
#import "GNESectionedTableViewTests.h"


// ------------------------------------------------------------------------------------------


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


// ------------------------------------------------------------------------------------------


@interface GNEMockDataSource : GNEMockObject <GNESectionedTableViewDataSource>

@end
