//
//  GNESectionedTableViewTests.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 4/5/15.
//  Copyright (c) 2015 Gone East LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "GNESectionedTableView.h"
#import "GNEMockBlocks.h"
#import "GNEMockDataSource.h"
#import "GNEMockDelegate.h"


@class GNEMockDataSource, GNEMockDelegate;


// ------------------------------------------------------------------------------------------
#pragma mark - Sections
// ------------------------------------------------------------------------------------------
#ifndef GNESectionedTableViewTests_Sections
#define GNESectionedTableViewTests_Sections

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

#endif

// ------------------------------------------------------------------------------------------
#pragma mark - Rows
// ------------------------------------------------------------------------------------------
#ifndef GNESectionedTableViewTests_Rows
#define GNESectionedTableViewTests_Rows

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

// ------------------------------------------------------------------------------------------


@interface GNESectionedTableViewTests : XCTestCase

@property (nonatomic, strong, readonly) GNESectionedTableView *tableView;
@property (nonatomic, strong, readonly) GNEMockDataSource *dataSource;
@property (nonatomic, strong, readonly) GNEMockDelegate *delegate;

@end
