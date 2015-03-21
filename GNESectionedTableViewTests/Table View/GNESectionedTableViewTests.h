//
//  GNESectionedTableViewTests.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 3/21/15.
//  Copyright (c) 2015 Gone East LLC. All rights reserved.
//

#ifndef GNESectionedTableView_GNESectionedTableViewTests_h
#define GNESectionedTableView_GNESectionedTableViewTests_h

#import "GNESectionedTableView.h"
#import "GNEMockDataSource.h"

// Sections
#define XCTSetNumberOfSections(count) \
{ \
    MockNumberOfSectionsBlock block = ^NSUInteger() \
    { \
        return count; \
    }; \
    NSString *methodName = @"numberOfSectionsInTableView:"; \
    [self.dataSource setBlock:(__bridge void *)block forSelector:NSSelectorFromString(methodName)]; \
}

#define XCTAssertNumberOfSections(count) XCTAssertEqual(self.tableView.numberOfSections, count);

#endif
