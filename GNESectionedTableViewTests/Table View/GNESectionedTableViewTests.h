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

#define XCTSetHeightOfHeader(section, height) \
{ \
    XCTSetHeightsOfHeaders([GNEOrderedIndexSet indexSetWithIndex:section], @[@(height)]);\
}

#define XCTSetHeightsOfHeaders(sections, heights) \
{ \
    NSParameterAssert([sections isKindOfClass:[GNEOrderedIndexSet class]]); \
    NSParameterAssert([heights isKindOfClass:[NSArray class]]); \
    MockHeightForSectionBlock block = ^CGFloat(NSUInteger s) \
    { \
        if ([sections containsIndex:s]) \
        { \
            NSUInteger position = [sections positionOfIndex:s]; \
            return [heights[position] doubleValue]; \
        } \
        return 0.0; \
    }; \
    NSString *methodName = @"tableView:heightForHeaderInSection:"; \
    [self.delegate setBlock:(__bridge void *)[block copy] forSelector:NSSelectorFromString(methodName)]; \
}

#define XCTAssertHeightOfHeader(s, h) \
{ \
    XCTAssertEqual([self.tableView frameOfViewAtIndexPath:\
        [self.tableView indexPathForHeaderInSection:s]].size.height, h); \
}

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

#define XCTSetHeightOfRow(ip, h) \
{ \
    XCTSetHeightsOfRows(@[ip], @[@(h)]);\
}

#define XCTSetHeightsOfRows(ips, hs) \
{ \
    NSParameterAssert([ips isKindOfClass:[NSArray class]]); \
    NSParameterAssert([hs isKindOfClass:[NSArray class]]); \
    MockHeightForRowBlock block = ^CGFloat(NSIndexPath *ip) \
    { \
        NSUInteger index = [ips indexOfObject:ip]; \
        if (index != NSNotFound) \
        { \
            return [hs[index] doubleValue]; \
        } \
        return 0.0; \
    }; \
    NSString *methodName = @"tableView:heightForRowAtIndexPath:"; \
    [self.delegate setBlock:(__bridge void *)[block copy] forSelector:NSSelectorFromString(methodName)]; \
}

#define XCTAssertHeightOfRow(ip, h) \
{ \
    XCTAssertEqual([self.tableView frameOfViewAtIndexPath:ip].size.height, h); \
}

#endif

// ------------------------------------------------------------------------------------------


@interface GNESectionedTableViewTests : XCTestCase

@property (nonatomic, strong, readonly) GNESectionedTableView *tableView;
@property (nonatomic, strong, readonly) GNEMockDataSource *dataSource;
@property (nonatomic, strong, readonly) GNEMockDelegate *delegate;

@end
