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

// Sections
#define XCTSetNumberOfSections(count) \
{ \
    MockNumberOfSectionsBlock block = ^NSUInteger() \
    { \
        return count; \
    }; \
    NSString *methodName = @"numberOfSectionsInTableView:"; \
    [self.dataSource setBlock:(__bridge void *)[block copy] forSelector:NSSelectorFromString(methodName)]; \
}

#define XCTAssertNumberOfSections(count) \
    XCTAssertEqual(self.tableView.numberOfSections, count);


// Rows
#define XCTSetNumberOfRowsInSections(rows) \
{ \
    MockNumberOfRowsBlock block = ^NSUInteger(NSUInteger section) \
    { \
        NSParameterAssert([rows isKindOfClass:[NSArray class]]); \
        NSParameterAssert(section < ((NSArray *)rows).count); \
        return [rows[section] unsignedIntegerValue]; \
    }; \
    NSString *methodName = @"tableView:numberOfRowsInSection:"; \
    [self.dataSource setBlock:(__bridge void *)[block copy] forSelector:NSSelectorFromString(methodName)]; \
}

#define XCTAssertNumberOfRowsInSection(rows, section) \
    XCTAssertEqual([self.tableView numberOfRowsInSection:section], rows);


#endif
