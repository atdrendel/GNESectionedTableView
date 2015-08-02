//
//  GNEOrderedIndexSetTests.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 12/23/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GNEOrderedIndexSet.h"


// ------------------------------------------------------------------------------------------


static const NSUInteger kTestIndexSetMaxIndex = 10000;
static const NSUInteger kPerformanceTestIterations = 10000;

#ifndef GNEOrderedIndexSet_FoundationPerformanceTestsEnabled
    #define GNEOrderedIndexSet_FoundationPerformanceTestsEnabled 1
#endif

#define XCTAssertCount(indexSet, c) \
    XCTAssertEqual(indexSet.count, c)

#define XCTAssertContainsIndex(indexSet, i) \
    XCTAssertTrue([indexSet containsIndex:i])

#define XCTAssertNotContainsIndex(indexSet, i) \
    XCTAssertFalse([indexSet containsIndex:i])

#define XCTAssertIndexPosition(indexSet, i, p) \
    XCTAssertEqual([indexSet indexAtPosition:p], i); \
    XCTAssertEqual([indexSet positionOfIndex:i], p)


// ------------------------------------------------------------------------------------------


@interface GNEOrderedIndexSetTests : XCTestCase

@end


// ------------------------------------------------------------------------------------------


@implementation GNEOrderedIndexSetTests


// ------------------------------------------------------------------------------------------
#pragma mark - Set up/Tear Down
// ------------------------------------------------------------------------------------------
- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
- (void)testInitialization_Default
{
    GNEOrderedIndexSet *indexSet = [[GNEOrderedIndexSet alloc] init];
    
    XCTAssertNotNil(indexSet);
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, 0);
}


- (void)testInitialization_Class_Default
{
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertNotNil(indexSet);
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, 0);
}


- (void)testInitialization_WithIndex
{
    NSUInteger index = 1234;
    
    GNEOrderedIndexSet *indexSet = [[GNEOrderedIndexSet alloc] initWithIndex:index];
    
    XCTAssertNotNil(indexSet);
    XCTAssertCount(indexSet, 1);
    XCTAssertContainsIndex(indexSet, index);
    XCTAssertIndexPosition(indexSet, index, 0);
}


- (void)testInitialization_Class_WithIndex
{
    NSUInteger index = 1234;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSetWithIndex:index];
    
    XCTAssertNotNil(indexSet);
    XCTAssertCount(indexSet, 1);
    XCTAssertContainsIndex(indexSet, index);
    XCTAssertIndexPosition(indexSet, index, 0);
}


- (void)testInitialization_WithNSIndexSet_Nil
{
    NSIndexSet *nsIndexSet = [NSIndexSet indexSet];
    
    XCTAssertCount(nsIndexSet, 0);
    
    GNEOrderedIndexSet *indexSet = nil;
    
    XCTAssertNoThrow(indexSet = [[GNEOrderedIndexSet alloc] initWithNSIndexSet:nsIndexSet]);
    
    XCTAssertNotNil(indexSet);
    XCTAssertCount(indexSet, 0);
}


- (void)testInitialization_Class_WithNSIndexSet_Nil
{
    NSIndexSet *nsIndexSet = [NSIndexSet indexSet];
    
    XCTAssertCount(nsIndexSet, 0);
    
    GNEOrderedIndexSet *indexSet = nil;
    
    XCTAssertNoThrow(indexSet = [GNEOrderedIndexSet indexSetWithNSIndexSet:nsIndexSet]);
    
    XCTAssertNotNil(indexSet);
    XCTAssertCount(indexSet, 0);
}


- (void)testInitialization_WithNSIndexSet_Empty
{
    NSIndexSet *nsIndexSet = [NSIndexSet indexSet];
    
    XCTAssertCount(nsIndexSet, 0);
    
    GNEOrderedIndexSet *indexSet = nil;
    
    XCTAssertNoThrow(indexSet = [[GNEOrderedIndexSet alloc] initWithNSIndexSet:nsIndexSet]);
    
    XCTAssertNotNil(indexSet);
    XCTAssertCount(indexSet, 0);
}


- (void)testInitialization_Class_WithNSIndexSet_Empty
{
    NSIndexSet *nsIndexSet = [NSIndexSet indexSet];
    
    XCTAssertCount(nsIndexSet, 0);
    
    GNEOrderedIndexSet *indexSet = nil;
    
    XCTAssertNoThrow(indexSet = [GNEOrderedIndexSet indexSetWithNSIndexSet:nsIndexSet]);
    
    XCTAssertNotNil(indexSet);
    XCTAssertCount(indexSet, 0);
}


- (void)testInitialization_WithNSIndexSet_1
{
    NSUInteger count = 1;
    NSUInteger index = 432;
    
    NSIndexSet *nsIndexSet = [NSIndexSet indexSetWithIndex:index];
    
    XCTAssertCount(nsIndexSet, count);
    XCTAssertContainsIndex(nsIndexSet, index);
    
    GNEOrderedIndexSet *indexSet = nil;
    
    XCTAssertNoThrow(indexSet = [[GNEOrderedIndexSet alloc] initWithNSIndexSet:nsIndexSet]);
    
    XCTAssertNotNil(indexSet);
    XCTAssertCount(indexSet, count);
    XCTAssertContainsIndex(indexSet, index);
}


- (void)testInitialization_Class_WithNSIndexSet_1
{
    NSUInteger count = 1;
    NSUInteger index = 432;
    
    NSIndexSet *nsIndexSet = [NSIndexSet indexSetWithIndex:index];
    
    XCTAssertCount(nsIndexSet, count);
    XCTAssertContainsIndex(nsIndexSet, index);
    
    GNEOrderedIndexSet *indexSet = nil;
    
    XCTAssertNoThrow(indexSet = [GNEOrderedIndexSet indexSetWithNSIndexSet:nsIndexSet]);
    
    XCTAssertNotNil(indexSet);
    XCTAssertCount(indexSet, count);
    XCTAssertContainsIndex(indexSet, index);
}


- (void)testInitialization_WithNSIndexSet_10
{
    NSUInteger count = 10;
    NSUInteger indexes[] = { 432, 23, 43, 64, 8329743, 323, 57656, 6434, 654, 843 };
    
    NSMutableIndexSet *mutableNSIndexSet = [NSMutableIndexSet indexSet];
    for (NSUInteger i = 0; i < count; i++)
    {
        [mutableNSIndexSet addIndex:indexes[i]];
    }
    NSIndexSet *nsIndexSet = [[NSIndexSet alloc] initWithIndexSet:mutableNSIndexSet];
    
    XCTAssertCount(nsIndexSet, count);
    
    for (NSUInteger i = 0; i < count; i++)
    {
        XCTAssertContainsIndex(nsIndexSet, indexes[i]);
    }
    
    GNEOrderedIndexSet *indexSet = nil;
    
    XCTAssertNoThrow(indexSet = [[GNEOrderedIndexSet alloc] initWithNSIndexSet:nsIndexSet]);
    
    XCTAssertNotNil(indexSet);
    XCTAssertCount(indexSet, count);
    
    for (NSUInteger i = 0; i < count; i++)
    {
        XCTAssertContainsIndex(indexSet, indexes[i]);
    }
}


- (void)testInitialization_Class_WithNSIndexSet_10
{
    NSUInteger count = 10;
    NSUInteger indexes[] = { 432, 23, 43, 64, 8329743, 323, 57656, 6434, 654, 843 };
    
    NSMutableIndexSet *mutableNSIndexSet = [NSMutableIndexSet indexSet];
    for (NSUInteger i = 0; i < count; i++)
    {
        [mutableNSIndexSet addIndex:indexes[i]];
    }
    NSIndexSet *nsIndexSet = [[NSIndexSet alloc] initWithIndexSet:mutableNSIndexSet];
    
    XCTAssertCount(nsIndexSet, count);
    
    for (NSUInteger i = 0; i < count; i++)
    {
        XCTAssertContainsIndex(nsIndexSet, indexes[i]);
    }
    
    GNEOrderedIndexSet *indexSet = nil;
    
    XCTAssertNoThrow(indexSet = [GNEOrderedIndexSet indexSetWithNSIndexSet:nsIndexSet]);
    
    XCTAssertNotNil(indexSet);
    XCTAssertCount(indexSet, count);
    
    for (NSUInteger i = 0; i < count; i++)
    {
        XCTAssertContainsIndex(indexSet, indexes[i]);
    }
}


- (void)testInitialization_WithIndexes
{
    NSUInteger indexes[] = { 0, 1, 2, 3, 4 };
    NSUInteger count = 5;
    
    GNEOrderedIndexSet *indexSet = [[GNEOrderedIndexSet alloc] initWithIndexes:indexes
                                                                         count:count];
    
    XCTAssertNotNil(indexSet);
    XCTAssertCount(indexSet, count);
    
    XCTAssertContainsIndex(indexSet, 0);
    XCTAssertContainsIndex(indexSet, 1);
    XCTAssertContainsIndex(indexSet, 2);
    XCTAssertContainsIndex(indexSet, 3);
    XCTAssertContainsIndex(indexSet, 4);
    
    XCTAssertNotContainsIndex(indexSet, 5);
    
    XCTAssertIndexPosition(indexSet, indexes[0], 0);
    XCTAssertIndexPosition(indexSet, indexes[1], 1);
    XCTAssertIndexPosition(indexSet, indexes[2], 2);
    XCTAssertIndexPosition(indexSet, indexes[3], 3);
    XCTAssertIndexPosition(indexSet, indexes[4], 4);
}


- (void)testInitialization_Class_WithIndexes
{
    NSUInteger indexes[] = { 0, 1, 2, 3, 4 };
    NSUInteger count = 5;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSetWithIndexes:indexes count:count];
    
    XCTAssertNotNil(indexSet);
    XCTAssertCount(indexSet, count);
    
    XCTAssertContainsIndex(indexSet, 0);
    XCTAssertContainsIndex(indexSet, 1);
    XCTAssertContainsIndex(indexSet, 2);
    XCTAssertContainsIndex(indexSet, 3);
    XCTAssertContainsIndex(indexSet, 4);
    
    XCTAssertNotContainsIndex(indexSet, 5);
    
    XCTAssertIndexPosition(indexSet, indexes[0], 0);
    XCTAssertIndexPosition(indexSet, indexes[1], 1);
    XCTAssertIndexPosition(indexSet, indexes[2], 2);
    XCTAssertIndexPosition(indexSet, indexes[3], 3);
    XCTAssertIndexPosition(indexSet, indexes[4], 4);
}


- (void)testInitialization_WithIndexes_Duplicates
{
    NSUInteger indexes[] = { 0, 1, 2, 3, 4, 4, 51, 51, 1021, 1021 };
    NSUInteger count = 10;
    NSUInteger expectedCount = 7;
    
    GNEOrderedIndexSet *indexSet = [[GNEOrderedIndexSet alloc] initWithIndexes:indexes
                                                                         count:count];
    
    XCTAssertNotNil(indexSet);
    XCTAssertCount(indexSet, expectedCount);
    
    XCTAssertContainsIndex(indexSet, 0);
    XCTAssertContainsIndex(indexSet, 1);
    XCTAssertContainsIndex(indexSet, 2);
    XCTAssertContainsIndex(indexSet, 3);
    XCTAssertContainsIndex(indexSet, 4);
    XCTAssertContainsIndex(indexSet, 51);
    XCTAssertContainsIndex(indexSet, 1021);
    
    XCTAssertNotContainsIndex(indexSet, 5);
    XCTAssertNotContainsIndex(indexSet, 50);
    XCTAssertNotContainsIndex(indexSet, 52);
    XCTAssertNotContainsIndex(indexSet, 1020);
    XCTAssertNotContainsIndex(indexSet, 1022);
    
    XCTAssertIndexPosition(indexSet, indexes[0], 0);
    XCTAssertIndexPosition(indexSet, indexes[1], 1);
    XCTAssertIndexPosition(indexSet, indexes[2], 2);
    XCTAssertIndexPosition(indexSet, indexes[3], 3);
    XCTAssertIndexPosition(indexSet, indexes[4], 4);
    XCTAssertIndexPosition(indexSet, indexes[6], 5);
    XCTAssertIndexPosition(indexSet, indexes[8], 6);
}


- (void)testInitialization_Class_WithIndexes_Duplicates
{
    NSUInteger indexes[] = { 0, 1, 2, 3, 4, 4, 51, 51, 1021, 1021 };
    NSUInteger count = 10;
    NSUInteger expectedCount = 7;
    
    GNEOrderedIndexSet *indexSet = [[GNEOrderedIndexSet alloc] initWithIndexes:indexes
                                                                         count:count];
    
    XCTAssertNotNil(indexSet);
    XCTAssertCount(indexSet, expectedCount);
    
    XCTAssertContainsIndex(indexSet, 0);
    XCTAssertContainsIndex(indexSet, 1);
    XCTAssertContainsIndex(indexSet, 2);
    XCTAssertContainsIndex(indexSet, 3);
    XCTAssertContainsIndex(indexSet, 4);
    XCTAssertContainsIndex(indexSet, 51);
    XCTAssertContainsIndex(indexSet, 1021);
    
    XCTAssertNotContainsIndex(indexSet, 5);
    XCTAssertNotContainsIndex(indexSet, 50);
    XCTAssertNotContainsIndex(indexSet, 52);
    XCTAssertNotContainsIndex(indexSet, 1020);
    XCTAssertNotContainsIndex(indexSet, 1022);
    
    XCTAssertIndexPosition(indexSet, indexes[0], 0);
    XCTAssertIndexPosition(indexSet, indexes[1], 1);
    XCTAssertIndexPosition(indexSet, indexes[2], 2);
    XCTAssertIndexPosition(indexSet, indexes[3], 3);
    XCTAssertIndexPosition(indexSet, indexes[4], 4);
    XCTAssertIndexPosition(indexSet, indexes[6], 5);
    XCTAssertIndexPosition(indexSet, indexes[8], 6);
}


// ------------------------------------------------------------------------------------------
#pragma mark - Count
// ------------------------------------------------------------------------------------------
- (void)testCount_Empty
{
    NSUInteger count = 0;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, count);
    XCTAssertEqual(indexSet.count, count);
}


- (void)testCount_1
{
    NSUInteger count = 1;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSetWithIndex:1324212];
    
    XCTAssertCount(indexSet, count);
    XCTAssertEqual(indexSet.count, count);
}


- (void)testCount_10
{
    NSUInteger count = 10;
    NSUInteger indexes[] = { 2334, 3232, 6542, 5343433, 2, 43, 97, 4823821, 12, 21 };
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSetWithIndexes:indexes count:count];
    
    XCTAssertCount(indexSet, count);
    XCTAssertEqual(indexSet.count, count);
}


- (void)testCount_10_Duplicates
{
    NSUInteger count = 20;
    NSUInteger indexes[] = { 2334, 3232, 6542, 5343433, 2, 43, 97, 4823821, 12, 21,
                             2334, 3232, 6542, 5343433, 2, 43, 97, 4823821, 12, 21 };
    
    NSUInteger expectedCount = 10;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSetWithIndexes:indexes count:count];
    
    XCTAssertCount(indexSet, expectedCount);
    XCTAssertEqual(indexSet.count, expectedCount);
}


// ------------------------------------------------------------------------------------------
#pragma mark - Smallest/Largest Index
// ------------------------------------------------------------------------------------------
- (void)testSmallestLargestIndex_Empty
{
    NSUInteger count = 0;
    NSUInteger smallestIndex = NSNotFound;
    NSUInteger largestIndex = NSNotFound;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, count);
    
    XCTAssertEqual(indexSet.smallestIndex, smallestIndex);
    XCTAssertEqual(indexSet.largestIndex, largestIndex);
}


- (void)testSmallestLargestIndex_1
{
    NSUInteger count = 1;
    NSUInteger index = 53;
    NSUInteger smallestIndex = index;
    NSUInteger largestIndex = index;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSetWithIndex:index];
    
    XCTAssertCount(indexSet, count);
    
    XCTAssertEqual(indexSet.smallestIndex, smallestIndex);
    XCTAssertEqual(indexSet.largestIndex, largestIndex);
}


- (void)testSmallestLargestIndex_2
{
    NSUInteger count = 2;
    NSUInteger indexes[] = { 54, 53 };
    NSUInteger smallestIndex = indexes[1];
    NSUInteger largestIndex = indexes[0];
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSetWithIndexes:indexes count:count];
    
    XCTAssertCount(indexSet, count);
    
    XCTAssertEqual(indexSet.smallestIndex, smallestIndex);
    XCTAssertEqual(indexSet.largestIndex, largestIndex);
}


- (void)testSmallestLargestIndex_10
{
    NSUInteger count = 10;
    NSUInteger indexes[] = { 54, 53, 52, 55, 51, 56, 50, 123443224, 48, 49 };
    NSUInteger smallestIndex = indexes[8];
    NSUInteger largestIndex = indexes[7];
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSetWithIndexes:indexes count:count];
    
    XCTAssertCount(indexSet, count);
    
    XCTAssertEqual(indexSet.smallestIndex, smallestIndex);
    XCTAssertEqual(indexSet.largestIndex, largestIndex);
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSIndexSet
// ------------------------------------------------------------------------------------------
- (void)testNSIndexSet_Empty
{
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, 0);
    
    NSIndexSet *nsIndexSet = indexSet.ns_indexSet;
    
    XCTAssertNotNil(nsIndexSet);
    XCTAssertTrue([nsIndexSet isKindOfClass:[NSIndexSet class]]);
    
    XCTAssertCount(indexSet, 0);
    XCTAssertEqual(indexSet.count, nsIndexSet.count);
    
    XCTAssertNotContainsIndex(indexSet, 0);
    XCTAssertNotContainsIndex(nsIndexSet, 0);
    XCTAssertNotContainsIndex(indexSet, 1);
    XCTAssertNotContainsIndex(nsIndexSet, 1);
    XCTAssertNotContainsIndex(indexSet, 1234);
    XCTAssertNotContainsIndex(nsIndexSet, 1234);
    XCTAssertNotContainsIndex(indexSet, NSNotFound);
    XCTAssertNotContainsIndex(nsIndexSet, NSNotFound);
}


- (void)testNSIndexSet_0
{
    NSUInteger count = 1;
    NSUInteger index = 0;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSetWithIndex:index];
    
    XCTAssertCount(indexSet, count);
    
    NSIndexSet *nsIndexSet = indexSet.ns_indexSet;
    
    XCTAssertNotNil(nsIndexSet);
    XCTAssertTrue([nsIndexSet isKindOfClass:[NSIndexSet class]]);
    
    XCTAssertCount(indexSet, count);
    XCTAssertEqual(indexSet.count, nsIndexSet.count);
 
    XCTAssertContainsIndex(indexSet, index);
    XCTAssertContainsIndex(nsIndexSet, index);
    
    XCTAssertNotContainsIndex(indexSet, 1);
    XCTAssertNotContainsIndex(nsIndexSet, 1);
    XCTAssertNotContainsIndex(indexSet, 1234);
    XCTAssertNotContainsIndex(nsIndexSet, 1234);
    XCTAssertNotContainsIndex(indexSet, NSNotFound);
    XCTAssertNotContainsIndex(nsIndexSet, NSNotFound);
}


- (void)testNSIndexSet_1
{
    NSUInteger count = 1;
    NSUInteger index = 1;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSetWithIndex:index];
    
    XCTAssertCount(indexSet, count);
    
    NSIndexSet *nsIndexSet = indexSet.ns_indexSet;
    
    XCTAssertNotNil(nsIndexSet);
    XCTAssertTrue([nsIndexSet isKindOfClass:[NSIndexSet class]]);
    
    XCTAssertCount(indexSet, count);
    XCTAssertEqual(indexSet.count, nsIndexSet.count);
    
    XCTAssertContainsIndex(indexSet, index);
    XCTAssertContainsIndex(nsIndexSet, index);
    
    XCTAssertNotContainsIndex(indexSet, 0);
    XCTAssertNotContainsIndex(nsIndexSet, 0);
    XCTAssertNotContainsIndex(indexSet, 1234);
    XCTAssertNotContainsIndex(nsIndexSet, 1234);
    XCTAssertNotContainsIndex(indexSet, NSNotFound);
    XCTAssertNotContainsIndex(nsIndexSet, NSNotFound);
}


- (void)testNSIndexSet_10
{
    NSUInteger count = 10;
    NSUInteger indexes[] = { 2, 1, 54, 45, 44, 46, 432, 100001, 201, 200 };
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSetWithIndexes:indexes
                                                                     count:count];
    
    XCTAssertCount(indexSet, count);
    
    NSIndexSet *nsIndexSet = indexSet.ns_indexSet;
    
    XCTAssertNotNil(nsIndexSet);
    XCTAssertTrue([nsIndexSet isKindOfClass:[NSIndexSet class]]);
    
    XCTAssertCount(indexSet, count);
    XCTAssertEqual(indexSet.count, nsIndexSet.count);
    
    for (NSUInteger i = 0; i < count; i++)
    {
        XCTAssertContainsIndex(indexSet, indexes[i]);
        XCTAssertContainsIndex(nsIndexSet, indexes[i]);
    }
    
    XCTAssertNotContainsIndex(indexSet, 0);
    XCTAssertNotContainsIndex(nsIndexSet, 0);
    XCTAssertNotContainsIndex(indexSet, 1234);
    XCTAssertNotContainsIndex(nsIndexSet, 1234);
    XCTAssertNotContainsIndex(indexSet, NSNotFound);
    XCTAssertNotContainsIndex(nsIndexSet, NSNotFound);
}


// ------------------------------------------------------------------------------------------
#pragma mark - Equality
// ------------------------------------------------------------------------------------------
- (void)testEqual_Empty
{
    GNEOrderedIndexSet *indexSet1 = [GNEOrderedIndexSet indexSet];
    GNEOrderedIndexSet *indexSet2 = [[GNEOrderedIndexSet alloc] init];
    
    XCTAssertNotEqual((id)indexSet1, (id)indexSet2); // Pointers are different.
    
    XCTAssertEqualObjects(indexSet1, indexSet2);
    
    XCTAssertTrue([indexSet1 isEqual:indexSet2]);
    XCTAssertTrue([indexSet2 isEqual:indexSet1]);
    
    XCTAssertTrue([indexSet1 isEqualToIndexSet:indexSet2]);
    XCTAssertTrue([indexSet2 isEqualToIndexSet:indexSet1]);
}


- (void)testEqual_OneIndex
{
    NSUInteger index = 1234;
    
    GNEOrderedIndexSet *indexSet1 = [GNEOrderedIndexSet indexSetWithIndex:index];
    GNEOrderedIndexSet *indexSet2 = [[GNEOrderedIndexSet alloc] initWithIndex:index];
    
    XCTAssertNotEqual((id)indexSet1, (id)indexSet2); // Pointers are different.
    
    XCTAssertEqualObjects(indexSet1, indexSet2);
    
    XCTAssertTrue([indexSet1 isEqual:indexSet2]);
    XCTAssertTrue([indexSet2 isEqual:indexSet1]);
    
    XCTAssertTrue([indexSet1 isEqualToIndexSet:indexSet2]);
    XCTAssertTrue([indexSet2 isEqualToIndexSet:indexSet1]);
}


- (void)testEqual_MultipleIndexes
{
    NSUInteger indexes[] = { 0, 10, 20, 21, 22, 23 };
    NSUInteger count = 6;
    
    GNEOrderedIndexSet *indexSet1 = [GNEOrderedIndexSet indexSetWithIndexes:indexes count:count];
    GNEOrderedIndexSet *indexSet2 = [[GNEOrderedIndexSet alloc] initWithIndexes:indexes count:count];
    
    XCTAssertNotEqual((id)indexSet1, (id)indexSet2); // Pointers are different.
    
    XCTAssertEqualObjects(indexSet1, indexSet2);
    
    XCTAssertTrue([indexSet1 isEqual:indexSet2]);
    XCTAssertTrue([indexSet2 isEqual:indexSet1]);
    
    XCTAssertTrue([indexSet1 isEqualToIndexSet:indexSet2]);
    XCTAssertTrue([indexSet2 isEqualToIndexSet:indexSet1]);
}


- (void)testUnequal_OneToZeroIndexes
{
    GNEOrderedIndexSet *indexSet1 = [GNEOrderedIndexSet indexSetWithIndex:9];
    GNEOrderedIndexSet *indexSet2 = [GNEOrderedIndexSet indexSet];
    
    XCTAssertNotEqual((id)indexSet1, (id)indexSet2); // Pointers are different.
    
    XCTAssertNotEqualObjects(indexSet1, indexSet2);
    
    XCTAssertFalse([indexSet1 isEqual:indexSet2]);
    XCTAssertFalse([indexSet2 isEqual:indexSet1]);
    
    XCTAssertFalse([indexSet1 isEqualToIndexSet:indexSet2]);
    XCTAssertFalse([indexSet2 isEqualToIndexSet:indexSet1]);
}


- (void)testUnequal_OneToMultipleIndexes
{
    NSUInteger indexes[] = { 1, 20, 1001 };
    NSUInteger count = 3;
    
    GNEOrderedIndexSet *indexSet1 = [GNEOrderedIndexSet indexSetWithIndex:indexes[0]];
    GNEOrderedIndexSet *indexSet2 = [GNEOrderedIndexSet indexSetWithIndexes:indexes count:count];
    
    XCTAssertNotEqual((id)indexSet1, (id)indexSet2); // Pointers are different.
    
    XCTAssertNotEqualObjects(indexSet1, indexSet2);
    
    XCTAssertFalse([indexSet1 isEqual:indexSet2]);
    XCTAssertFalse([indexSet2 isEqual:indexSet1]);
    
    XCTAssertFalse([indexSet1 isEqualToIndexSet:indexSet2]);
    XCTAssertFalse([indexSet2 isEqualToIndexSet:indexSet1]);
}


- (void)testUnequal_MultipleToMultipleIndexes1
{
    NSUInteger indexes1[] = { 1, 20, 1001 };
    NSUInteger indexes2[] = { 1, 20, 1000 };
    NSUInteger count = 3;
    
    GNEOrderedIndexSet *indexSet1 = [GNEOrderedIndexSet indexSetWithIndexes:indexes1 count:count];
    GNEOrderedIndexSet *indexSet2 = [GNEOrderedIndexSet indexSetWithIndexes:indexes2 count:count];
    
    XCTAssertNotEqual((id)indexSet1, (id)indexSet2); // Pointers are different.
    
    XCTAssertNotEqualObjects(indexSet1, indexSet2);
    
    XCTAssertFalse([indexSet1 isEqual:indexSet2]);
    XCTAssertFalse([indexSet2 isEqual:indexSet1]);
    
    XCTAssertFalse([indexSet1 isEqualToIndexSet:indexSet2]);
    XCTAssertFalse([indexSet2 isEqualToIndexSet:indexSet1]);
}


- (void)testUnequal_MultipleToMultipleIndexes2
{
    NSUInteger indexes1[] = { 1, 20, 1000 };
    NSUInteger indexes2[] = { 1, 20, 1000, 1001 };
    NSUInteger count1 = 3;
    NSUInteger count2 = 4;
    
    GNEOrderedIndexSet *indexSet1 = [GNEOrderedIndexSet indexSetWithIndexes:indexes1 count:count1];
    GNEOrderedIndexSet *indexSet2 = [GNEOrderedIndexSet indexSetWithIndexes:indexes2 count:count2];
    
    XCTAssertNotEqual((id)indexSet1, (id)indexSet2); // Pointers are different.
    
    XCTAssertNotEqualObjects(indexSet1, indexSet2);
    
    XCTAssertFalse([indexSet1 isEqual:indexSet2]);
    XCTAssertFalse([indexSet2 isEqual:indexSet1]);
    
    XCTAssertFalse([indexSet1 isEqualToIndexSet:indexSet2]);
    XCTAssertFalse([indexSet2 isEqualToIndexSet:indexSet1]);
}


// ------------------------------------------------------------------------------------------
#pragma mark - Copying
// ------------------------------------------------------------------------------------------
- (void)testCopying_Empty
{
    GNEOrderedIndexSet *indexSet1 = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet1, 0);
    
    GNEOrderedIndexSet *indexSet2 = [indexSet1 copy];
    
    XCTAssertNotEqual((id)indexSet1, (id)indexSet2); // Different pointers (separate objects).
    XCTAssertEqualObjects(indexSet1, indexSet2); // Equal objects.
}


- (void)testCopying_1
{
    NSUInteger count = 1;
    NSUInteger index = 1;
    NSUInteger position = 0;
    
    GNEOrderedIndexSet *indexSet1 = [GNEOrderedIndexSet indexSetWithIndex:index];
    
    XCTAssertCount(indexSet1, count);
    XCTAssertIndexPosition(indexSet1, index, position);
    
    GNEOrderedIndexSet *indexSet2 = [indexSet1 copy];
    
    XCTAssertNotEqual((id)indexSet1, (id)indexSet2); // Different pointers (separate objects).
    XCTAssertEqualObjects(indexSet1, indexSet2); // Equal objects.
    
    XCTAssertIndexPosition(indexSet1, index, position);
    XCTAssertIndexPosition(indexSet2, index, position);
}


- (void)testCopying_Multiple
{
    NSUInteger count = 10;
    NSUInteger indexes[] = { 43, 42, 1081, 1082, 1080, 128, 256, 512, 64, 32 };
    
    GNEOrderedIndexSet *indexSet1 = [GNEOrderedIndexSet indexSetWithIndexes:indexes
                                                                      count:count];
    
    XCTAssertCount(indexSet1, count);
    XCTAssertIndexPosition(indexSet1, indexes[0], 0);
    XCTAssertIndexPosition(indexSet1, indexes[3], 3);
    XCTAssertIndexPosition(indexSet1, indexes[9], 9);
    
    GNEOrderedIndexSet *indexSet2 = [indexSet1 copy];
    
    XCTAssertNotEqual((id)indexSet1, (id)indexSet2); // Different pointers (separate objects).
    XCTAssertEqualObjects(indexSet1, indexSet2); // Equal objects.
    
    XCTAssertIndexPosition(indexSet1, indexes[0], 0);
    XCTAssertIndexPosition(indexSet2, indexes[0], 0);
    XCTAssertIndexPosition(indexSet1, indexes[3], 3);
    XCTAssertIndexPosition(indexSet2, indexes[3], 3);
    XCTAssertIndexPosition(indexSet1, indexes[9], 9);
    XCTAssertIndexPosition(indexSet2, indexes[9], 9);
}


// ------------------------------------------------------------------------------------------
#pragma mark - Contains
// ------------------------------------------------------------------------------------------
- (void)testContains_Empty
{
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, 0);
    
    XCTAssertNotContainsIndex(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, 1);
    XCTAssertNotContainsIndex(indexSet, 2);
    XCTAssertNotContainsIndex(indexSet, 123456);
    XCTAssertNotContainsIndex(indexSet, NSNotFound);
}


- (void)testContains_0
{
    NSUInteger index = 0;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSetWithIndex:index];
    
    XCTAssertCount(indexSet, 1);
    XCTAssertContainsIndex(indexSet, index);
    
    XCTAssertNotContainsIndex(indexSet, 1);
    XCTAssertNotContainsIndex(indexSet, 2);
    XCTAssertNotContainsIndex(indexSet, 123456);
    XCTAssertNotContainsIndex(indexSet, NSNotFound);
}


- (void)testContains_1
{
    NSUInteger index = 1;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSetWithIndex:index];
    
    XCTAssertCount(indexSet, 1);
    XCTAssertContainsIndex(indexSet, index);
    
    XCTAssertNotContainsIndex(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, 2);
    XCTAssertNotContainsIndex(indexSet, 123456);
    XCTAssertNotContainsIndex(indexSet, NSNotFound);
}


- (void)testContains_2
{
    NSUInteger index = 2;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSetWithIndex:index];
    
    XCTAssertCount(indexSet, 1);
    XCTAssertContainsIndex(indexSet, index);
    
    XCTAssertNotContainsIndex(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, 1);
    XCTAssertNotContainsIndex(indexSet, 123456);
    XCTAssertNotContainsIndex(indexSet, NSNotFound);
}


- (void)testContains_Even
{
    NSUInteger evenIndexes[] = { 0, 2, 8, 1532, 9998 };
    NSUInteger oddIndexes[] = { 1, 3, 9, 987, 9999 };
    NSUInteger count = 5;
    
    GNEOrderedIndexSet *indexSet = [self p_indexSetContainingEvenIndexes];
    
    BOOL isLastIndexEven = (kTestIndexSetMaxIndex % 2) == 0;
    NSUInteger countModifier = (isLastIndexEven) ? 1 : 0;
    XCTAssertCount(indexSet, ((kTestIndexSetMaxIndex + 1) / 2) + countModifier);
    
    for (NSUInteger i = 0; i < count; i++)
    {
        XCTAssertContainsIndex(indexSet, evenIndexes[i]);
        XCTAssertNotContainsIndex(indexSet, oddIndexes[i]);
    }
}


- (void)testContains_Odd
{
    NSUInteger evenIndexes[] = { 0, 2, 8, 1532, 9998 };
    NSUInteger oddIndexes[] = { 1, 3, 9, 987, 9999 };
    NSUInteger count = 5;
    
    GNEOrderedIndexSet *indexSet = [self p_indexSetContainingOddIndexes];
    
    XCTAssertCount(indexSet, ((kTestIndexSetMaxIndex + 1) / 2));
    
    for (NSUInteger i = 0; i < count; i++)
    {
        XCTAssertContainsIndex(indexSet, oddIndexes[i]);
        XCTAssertNotContainsIndex(indexSet, evenIndexes[i]);
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - Enumeration
// ------------------------------------------------------------------------------------------
- (void)testEnumeration_Empty
{
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, 0);
    
    __block NSUInteger iterations = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, NSUInteger position, BOOL *stop)
    {
        iterations++;
    }];
    
    XCTAssertEqual(iterations, 0);
}


- (void)testEnumeration_1
{
    NSUInteger index = 0;
    NSUInteger count = 1;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSetWithIndex:index];
    
    XCTAssertCount(indexSet, count);
    XCTAssertContainsIndex(indexSet, 0);
    
    __block NSUInteger iterations = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, NSUInteger position, BOOL *stop)
    {
        XCTAssertEqual(idx, position);

        iterations++;
    }];
    
    XCTAssertCount(indexSet, count);
    XCTAssertEqual(iterations, count);
}


- (void)testEnumeration_10
{
    NSUInteger count = 10;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    [self p_addIndexesToIndexSet:indexSet count:count isPerformanceTest:NO];
    
    XCTAssertCount(indexSet, count);
    XCTAssertContainsIndex(indexSet, 0);
    XCTAssertContainsIndex(indexSet, 1);
    XCTAssertContainsIndex(indexSet, 9);
    XCTAssertNotContainsIndex(indexSet, 10);
    
    __block NSUInteger iterations = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, NSUInteger position, BOOL *stop)
    {
        XCTAssertEqual(idx, position);

        iterations++;
    }];
    
    XCTAssertCount(indexSet, count);
    XCTAssertEqual(iterations, count);
}


- (void)testEnumeration_Reverse_10
{
    NSUInteger count = 10;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    [self p_addIndexesToIndexSet:indexSet count:count isPerformanceTest:NO];
    
    XCTAssertCount(indexSet, count);
    XCTAssertContainsIndex(indexSet, 0);
    XCTAssertContainsIndex(indexSet, 1);
    XCTAssertContainsIndex(indexSet, 9);
    XCTAssertNotContainsIndex(indexSet, 10);
    
    __block NSUInteger iterations = 0;
    [indexSet enumerateIndexesWithOptions:NSEnumerationReverse
                               usingBlock:^(NSUInteger idx, NSUInteger position, BOOL *stop)
    {
        XCTAssertEqual(idx, count - 1 - position);

        iterations++;
    }];
    
    XCTAssertCount(indexSet, count);
    XCTAssertEqual(iterations, count);
}


// ------------------------------------------------------------------------------------------
#pragma mark - Add Indexes
// ------------------------------------------------------------------------------------------
- (void)testAddIndex_NSNotFound
{
    NSUInteger index = NSNotFound;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, index);
    
    XCTAssertThrows([indexSet addIndex:index]);
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, index);
}


- (void)testAddIndex_0
{
    NSUInteger index = 0;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, index);
    
    [indexSet addIndex:index];
    
    XCTAssertCount(indexSet, 1);
    XCTAssertContainsIndex(indexSet, index);
    XCTAssertIndexPosition(indexSet, index, 0);
}


- (void)testAddIndex_1
{
    NSUInteger index = 1;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, index);
    
    [indexSet addIndex:index];
    
    XCTAssertCount(indexSet, 1);
    XCTAssertContainsIndex(indexSet, index);
    XCTAssertIndexPosition(indexSet, index, 0);
}


- (void)testAddIndex_1234567
{
    NSUInteger index = 1234567;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, index);
    
    [indexSet addIndex:index];
    
    XCTAssertCount(indexSet, 1);
    XCTAssertContainsIndex(indexSet, index);
    XCTAssertIndexPosition(indexSet, index, 0);
}


- (void)testAddIndex_0_1
{
    NSUInteger index0 = 0;
    NSUInteger index1 = 1;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, index0);
    XCTAssertNotContainsIndex(indexSet, index1);
    
    [indexSet addIndex:index0];
    [indexSet addIndex:index1];
    
    XCTAssertCount(indexSet, 2);
    XCTAssertContainsIndex(indexSet, index0);
    XCTAssertContainsIndex(indexSet, index1);
    XCTAssertIndexPosition(indexSet, index0, 0);
    XCTAssertIndexPosition(indexSet, index1, 1);
}


- (void)testAddIndex_0_to_9999
{
    NSUInteger count = 1000;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, 0);
    
    [self p_addIndexesToIndexSet:indexSet count:count isPerformanceTest:NO];
    
    XCTAssertCount(indexSet, count);
    
    for (NSUInteger i = 0; i < count; i++)
    {
        XCTAssertIndexPosition(indexSet, i, i);
    }
}


- (void)testAddIndex_999_to_0
{
    NSUInteger count = 1000;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, 0);
    
    for (NSUInteger i = 0; i < count; i++)
    {
        [indexSet addIndex:(count - 1 - i)];
    }
    
    XCTAssertCount(indexSet, count);
    
    for (NSUInteger i = 0; i < count; i++)
    {
        XCTAssertIndexPosition(indexSet, (count - 1 - i), i);
    }
}


- (void)testAddIndex_Duplicates1
{
    NSUInteger index0 = 0;
    NSUInteger index1 = 1;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, index0);
    XCTAssertNotContainsIndex(indexSet, index1);
    
    [indexSet addIndex:index0];
    [indexSet addIndex:index0];
    [indexSet addIndex:index1];
    [indexSet addIndex:index1];
    
    XCTAssertCount(indexSet, 2);
    XCTAssertContainsIndex(indexSet, index0);
    XCTAssertContainsIndex(indexSet, index1);
    XCTAssertIndexPosition(indexSet, index0, 0);
    XCTAssertIndexPosition(indexSet, index1, 1);
}


- (void)testAddIndexes_0
{
    NSUInteger indexes[] = { 0 };
    NSUInteger count = 1;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, indexes[0]);
    
    [indexSet addIndexes:indexes count:count];
    
    XCTAssertCount(indexSet, count);
    XCTAssertContainsIndex(indexSet, indexes[0]);
    
    XCTAssertIndexPosition(indexSet, indexes[0], 0);
}


- (void)testAddIndexes_1
{
    NSUInteger indexes[] = { 1 };
    NSUInteger count = 1;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, indexes[0]);
    
    [indexSet addIndexes:indexes count:count];
    
    XCTAssertCount(indexSet, count);
    XCTAssertContainsIndex(indexSet, indexes[0]);
    
    XCTAssertIndexPosition(indexSet, indexes[0], 0);
}


- (void)testAddIndexes_54321
{
    NSUInteger indexes[] = { 54321 };
    NSUInteger count = 1;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, indexes[0]);
    
    [indexSet addIndexes:indexes count:count];
    
    XCTAssertCount(indexSet, count);
    XCTAssertContainsIndex(indexSet, indexes[0]);
    
    XCTAssertIndexPosition(indexSet, indexes[0], 0);
}


- (void)testAddIndexes_0_99
{
    NSUInteger indexes[] = { 0, 99 };
    NSUInteger count = 2;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, indexes[0]);
    XCTAssertNotContainsIndex(indexSet, indexes[1]);
    
    [indexSet addIndexes:indexes count:count];
    
    XCTAssertCount(indexSet, count);
    XCTAssertContainsIndex(indexSet, indexes[0]);
    XCTAssertContainsIndex(indexSet, indexes[1]);
    
    XCTAssertIndexPosition(indexSet, indexes[0], 0);
    XCTAssertIndexPosition(indexSet, indexes[1], 1);
}


- (void)testAddIndexes_0_to_9999
{
    NSUInteger count = 1000;
    
    NSUInteger indexes[count];
    for (NSUInteger i = 0; i < count; i++)
    {
        indexes[i] = i;
    }
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, 0);
    
    [indexSet addIndexes:indexes count:count];
    
    XCTAssertCount(indexSet, count);
    
    for (NSUInteger i = 0; i < count; i++)
    {
        XCTAssertIndexPosition(indexSet, i, i);
    }
}


- (void)testAddIndexes_999_to_0
{
    NSUInteger count = 1000;
    
    NSUInteger indexes[count];
    for (NSUInteger i = 0; i < count; i++)
    {
        indexes[i] = (count - 1 - i);
    }
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, 0);
    
    [indexSet addIndexes:indexes count:count];
    
    XCTAssertCount(indexSet, count);
    
    for (NSUInteger i = 0; i < count; i++)
    {
        XCTAssertIndexPosition(indexSet, (count - 1 - i), i);
    }
}


- (void)testAddIndexes_Duplicates
{
    NSUInteger count = 10;
    NSUInteger expectedCount = 7;
    
    NSUInteger indexes[] = { 101, 3, 37, 94, 3, 123456, 7, 10000000, 37, 3 };
    NSUInteger expectedIndexes[] = { 101, 3, 37, 94, 123456, 7, 10000000 };
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, 0);
    for (NSUInteger i = 0; i < count; i++)
    {
        XCTAssertNotContainsIndex(indexSet, indexes[i]);
    }
    
    [indexSet addIndexes:indexes count:count];
    
    XCTAssertCount(indexSet, expectedCount);
    
    for (NSUInteger i = 0; i < expectedCount; i++)
    {
        XCTAssertIndexPosition(indexSet, expectedIndexes[i], i);
    }
}


- (void)testAddIndexAtPosition_0
{
    NSUInteger index = 0;
    NSUInteger position = 0;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, index);
    
    [indexSet addIndex:index atPosition:position];
    
    XCTAssertCount(indexSet, 1);
    XCTAssertContainsIndex(indexSet, index);
    XCTAssertIndexPosition(indexSet, index, position);
}


- (void)testAddIndexAtPosition_OutOfBounds
{
    NSUInteger count = 10;
    
    NSUInteger index = 11;
    NSUInteger position = 11;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    [self p_addIndexesToIndexSet:indexSet count:count isPerformanceTest:NO];
    
    XCTAssertCount(indexSet, count);
    XCTAssertContainsIndex(indexSet, 0);
    XCTAssertContainsIndex(indexSet, 9);
    XCTAssertNotContainsIndex(indexSet, 10);
    
    XCTAssertThrows([indexSet addIndex:index atPosition:position]);
    
    XCTAssertCount(indexSet, count);
    XCTAssertNotContainsIndex(indexSet, index);
}


- (void)testAddIndexAtPosition_Beginning
{
    NSUInteger index = 654321;
    NSUInteger position = 0;
    
    NSUInteger count = 10;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    [self p_addIndexesToIndexSet:indexSet count:count isPerformanceTest:NO];
    
    XCTAssertCount(indexSet, count);
    XCTAssertContainsIndex(indexSet, 0);
    XCTAssertContainsIndex(indexSet, 9);
    XCTAssertNotContainsIndex(indexSet, 10);
    
    XCTAssertNoThrow([indexSet addIndex:index atPosition:position]);
    
    XCTAssertCount(indexSet, (count + 1));
    XCTAssertContainsIndex(indexSet, index);
    XCTAssertIndexPosition(indexSet, index, position);
    XCTAssertIndexPosition(indexSet, position, position + 1);
}


- (void)testAddIndexAtPosition_Middle
{
    NSUInteger index = 654321;
    NSUInteger position = 4;
    
    NSUInteger count = 10;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    [self p_addIndexesToIndexSet:indexSet count:count isPerformanceTest:NO];
    
    XCTAssertCount(indexSet, count);
    XCTAssertContainsIndex(indexSet, 0);
    XCTAssertContainsIndex(indexSet, 9);
    XCTAssertNotContainsIndex(indexSet, 10);
    
    XCTAssertNoThrow([indexSet addIndex:index atPosition:position]);
    
    XCTAssertCount(indexSet, (count + 1));
    XCTAssertContainsIndex(indexSet, index);
    XCTAssertIndexPosition(indexSet, index, position);
    XCTAssertIndexPosition(indexSet, position - 1, position - 1);
    XCTAssertIndexPosition(indexSet, position, position + 1);
}


- (void)testAddIndexAtPosition_End
{
    NSUInteger index = 654321;
    NSUInteger position = 10;
    
    NSUInteger count = 10;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    [self p_addIndexesToIndexSet:indexSet count:count isPerformanceTest:NO];
    
    XCTAssertCount(indexSet, count);
    XCTAssertContainsIndex(indexSet, 0);
    XCTAssertContainsIndex(indexSet, 9);
    XCTAssertNotContainsIndex(indexSet, 10);
    
    XCTAssertNoThrow([indexSet addIndex:index atPosition:position]);
    
    XCTAssertCount(indexSet, (count + 1));
    XCTAssertContainsIndex(indexSet, index);
    XCTAssertIndexPosition(indexSet, index, position);
    XCTAssertIndexPosition(indexSet, position - 1, position - 1);
}


// ------------------------------------------------------------------------------------------
#pragma mark - Remove Indexes
// ------------------------------------------------------------------------------------------
- (void)testRemoveIndex_Empty
{
    NSUInteger index = 0;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, index);
    
    XCTAssertNoThrow([indexSet removeIndex:index]);
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, index);
}


- (void)testRemoveIndex_NSNotFound
{
    NSUInteger index = NSNotFound;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, index);
    
    XCTAssertThrows([indexSet removeIndex:index]);
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, index);
}


- (void)testRemoveIndex_0
{
    NSUInteger index = 0;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSetWithIndex:index];
    
    XCTAssertCount(indexSet, 1);
    XCTAssertContainsIndex(indexSet, index);
    
    XCTAssertNoThrow([indexSet removeIndex:index]);
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, index);
    
    NSUInteger count = 10;
    [self p_addIndexesToIndexSet:indexSet count:count isPerformanceTest:NO];
    
    XCTAssertCount(indexSet, count);
    XCTAssertIndexPosition(indexSet, 0, 0);
    XCTAssertIndexPosition(indexSet, 9, 9);
    XCTAssertNotContainsIndex(indexSet, count);
    XCTAssertContainsIndex(indexSet, index);
    
    [indexSet addIndex:index];
    
    XCTAssertCount(indexSet, count);
    XCTAssertContainsIndex(indexSet, index);
    XCTAssertIndexPosition(indexSet, index, 0);
    
    XCTAssertNoThrow([indexSet removeIndex:index]);
    
    XCTAssertCount(indexSet, count - 1);
    XCTAssertIndexPosition(indexSet, 1, 0);
    XCTAssertIndexPosition(indexSet, 9, 8);
    XCTAssertNotContainsIndex(indexSet, count);
    XCTAssertNotContainsIndex(indexSet, index);
}


- (void)testRemoveIndex_1
{
    NSUInteger index = 1;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSetWithIndex:index];
    
    XCTAssertCount(indexSet, 1);
    XCTAssertContainsIndex(indexSet, index);
    
    XCTAssertNoThrow([indexSet removeIndex:index]);
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, index);
    
    NSUInteger count = 10;
    [self p_addIndexesToIndexSet:indexSet count:count isPerformanceTest:NO];
    
    XCTAssertCount(indexSet, count);
    XCTAssertIndexPosition(indexSet, 0, 0);
    XCTAssertIndexPosition(indexSet, 9, 9);
    XCTAssertNotContainsIndex(indexSet, count);
    XCTAssertContainsIndex(indexSet, index);
    
    [indexSet addIndex:index];
    
    XCTAssertCount(indexSet, count);
    XCTAssertContainsIndex(indexSet, index);
    XCTAssertIndexPosition(indexSet, index, 1);
    
    XCTAssertNoThrow([indexSet removeIndex:index]);
    
    XCTAssertCount(indexSet, count - 1);
    XCTAssertIndexPosition(indexSet, 0, 0);
    XCTAssertIndexPosition(indexSet, 2, 1);
    XCTAssertIndexPosition(indexSet, 9, 8);
    XCTAssertNotContainsIndex(indexSet, count);
    XCTAssertNotContainsIndex(indexSet, index);
}


- (void)testRemoveIndex_654321
{
    NSUInteger index = 654321;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSetWithIndex:index];
    
    XCTAssertCount(indexSet, 1);
    XCTAssertContainsIndex(indexSet, index);
    
    XCTAssertNoThrow([indexSet removeIndex:index]);
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, index);
    
    NSUInteger count = 10;
    [self p_addIndexesToIndexSet:indexSet count:count isPerformanceTest:NO];
    
    XCTAssertCount(indexSet, count);
    XCTAssertIndexPosition(indexSet, 0, 0);
    XCTAssertIndexPosition(indexSet, 9, 9);
    XCTAssertNotContainsIndex(indexSet, count);
    XCTAssertNotContainsIndex(indexSet, index);
    
    [indexSet addIndex:index];
    
    XCTAssertCount(indexSet, count + 1);
    XCTAssertContainsIndex(indexSet, index);
    XCTAssertIndexPosition(indexSet, index, count);
    
    XCTAssertNoThrow([indexSet removeIndex:index]);
    
    XCTAssertCount(indexSet, count);
    XCTAssertIndexPosition(indexSet, 0, 0);
    XCTAssertIndexPosition(indexSet, 9, 9);
    XCTAssertNotContainsIndex(indexSet, count);
    XCTAssertNotContainsIndex(indexSet, index);
}


- (void)testRemoveIndexAtPosition_Empty
{
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, 0);
    
    XCTAssertThrows([indexSet removeIndexAtPosition:0]);
}


- (void)testRemoveIndexAtPosition_0
{
    NSUInteger index = 0;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSetWithIndex:index];
    
    XCTAssertCount(indexSet, 1);
    XCTAssertContainsIndex(indexSet, index);
    
    XCTAssertNoThrow([indexSet removeIndexAtPosition:0]);
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, index);
}


- (void)testRemoveIndexAtPosition_first
{
    NSUInteger index = 7890;
    
    NSUInteger indexes[] = { index, 123123423, 2, 1, 0, 1234, 43 };
    NSUInteger count = 7;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSetWithIndexes:indexes count:count];
    
    XCTAssertCount(indexSet, count);
    XCTAssertContainsIndex(indexSet, index);
    XCTAssertIndexPosition(indexSet, index, 0);
    XCTAssertIndexPosition(indexSet, indexes[1], 1);
    XCTAssertIndexPosition(indexSet, indexes[2], 2);
    XCTAssertIndexPosition(indexSet, indexes[3], 3);
    XCTAssertIndexPosition(indexSet, indexes[4], 4);
    XCTAssertIndexPosition(indexSet, indexes[5], 5);
    XCTAssertIndexPosition(indexSet, indexes[6], 6);
    
    XCTAssertNoThrow([indexSet removeIndexAtPosition:0]);
    
    XCTAssertCount(indexSet, count - 1);
    XCTAssertNotContainsIndex(indexSet, index);
    
    XCTAssertIndexPosition(indexSet, indexes[1], 0);
    XCTAssertIndexPosition(indexSet, indexes[2], 1);
    XCTAssertIndexPosition(indexSet, indexes[3], 2);
    XCTAssertIndexPosition(indexSet, indexes[4], 3);
    XCTAssertIndexPosition(indexSet, indexes[5], 4);
    XCTAssertIndexPosition(indexSet, indexes[6], 5);
}


- (void)testRemoveIndexAtPosition_last
{
    NSUInteger index = 7890;
    
    NSUInteger indexes[] = { 123123423, 2, 1, 0, 1234, 43, index };
    NSUInteger count = 7;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSetWithIndexes:indexes count:count];
    
    XCTAssertCount(indexSet, count);
    XCTAssertContainsIndex(indexSet, index);
    XCTAssertIndexPosition(indexSet, indexes[0], 0);
    XCTAssertIndexPosition(indexSet, indexes[1], 1);
    XCTAssertIndexPosition(indexSet, indexes[2], 2);
    XCTAssertIndexPosition(indexSet, indexes[3], 3);
    XCTAssertIndexPosition(indexSet, indexes[4], 4);
    XCTAssertIndexPosition(indexSet, indexes[5], 5);
    XCTAssertIndexPosition(indexSet, index, 6);
    
    XCTAssertNoThrow([indexSet removeIndexAtPosition:(count - 1)]);
    
    XCTAssertCount(indexSet, count - 1);
    XCTAssertNotContainsIndex(indexSet, index);
    
    XCTAssertIndexPosition(indexSet, indexes[0], 0);
    XCTAssertIndexPosition(indexSet, indexes[1], 1);
    XCTAssertIndexPosition(indexSet, indexes[2], 2);
    XCTAssertIndexPosition(indexSet, indexes[3], 3);
    XCTAssertIndexPosition(indexSet, indexes[4], 4);
    XCTAssertIndexPosition(indexSet, indexes[5], 5);
}


- (void)testRemoveIndexAtPosition_middle
{
    NSUInteger index = 7890;
    
    NSUInteger indexes[] = { 123123423, 2, 1, index, 0, 1234, 43 };
    NSUInteger count = 7;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSetWithIndexes:indexes count:count];
    
    XCTAssertCount(indexSet, count);
    XCTAssertContainsIndex(indexSet, index);
    XCTAssertIndexPosition(indexSet, indexes[0], 0);
    XCTAssertIndexPosition(indexSet, indexes[1], 1);
    XCTAssertIndexPosition(indexSet, indexes[2], 2);
    XCTAssertIndexPosition(indexSet, index, 3);
    XCTAssertIndexPosition(indexSet, indexes[4], 4);
    XCTAssertIndexPosition(indexSet, indexes[5], 5);
    XCTAssertIndexPosition(indexSet, indexes[6], 6);
    
    XCTAssertNoThrow([indexSet removeIndexAtPosition:3]);
    
    XCTAssertCount(indexSet, count - 1);
    XCTAssertNotContainsIndex(indexSet, index);
    
    XCTAssertIndexPosition(indexSet, indexes[0], 0);
    XCTAssertIndexPosition(indexSet, indexes[1], 1);
    XCTAssertIndexPosition(indexSet, indexes[2], 2);
    XCTAssertIndexPosition(indexSet, indexes[4], 3);
    XCTAssertIndexPosition(indexSet, indexes[5], 4);
    XCTAssertIndexPosition(indexSet, indexes[6], 5);
}


// ------------------------------------------------------------------------------------------
#pragma mark - Performance - GNEOrderedIndexSet
// ------------------------------------------------------------------------------------------
- (void)testPerformance_Contains
{
    NSUInteger count = kPerformanceTestIterations;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    [self p_addIndexesToIndexSet:indexSet count:count isPerformanceTest:YES];
    
    XCTAssertCount(indexSet, count);
    
    [self measureBlock:^()
    {
        BOOL contains = NO;
        for (NSUInteger i = 0; i < count; i++)
        {
            contains = [indexSet containsIndex:i];
            XCTAssertTrue(contains);
        }
    }];
}


- (void)testPerformance_NaiveContains
{
    NSUInteger count = kPerformanceTestIterations;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    [self p_addIndexesToIndexSet:indexSet count:count isPerformanceTest:YES];
    
    XCTAssertCount(indexSet, count);
    
    [self measureBlock:^()
    {
        BOOL contains = NO;
        for (NSUInteger i = 0; i < count; i++)
        {
            contains = [self p_indexSet:indexSet containsIndex:i];
            XCTAssertTrue(contains);
        }
    }];
}


- (void)testPerformance_AddIndexes
{
    NSUInteger count = kPerformanceTestIterations;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    [self measureBlock:^()
    {
        [self p_addIndexesToIndexSet:indexSet count:count isPerformanceTest:YES];
    }];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Performance - Foundation
// ------------------------------------------------------------------------------------------
#if GNEOrderedIndexSet_FoundationPerformanceTestsEnabled

- (void)testPerformance_NSMutableIndexSet_AddIndexes
{
    NSUInteger count = kPerformanceTestIterations;
    
    NSMutableIndexSet *mutableIndexSet = [NSMutableIndexSet indexSet];
    
    [self measureBlock:^()
    {
        [self p_addIndexesToNSMutableIndexSet:mutableIndexSet count:count];
    }];
}


- (void)testPerformance_NSMutableArray_AddNumbers
{
    NSUInteger count = kPerformanceTestIterations;
    NSArray *numbers = [self p_arrayWithNumbers:count];
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    [self measureBlock:^()
    {
        [self p_addNumbersInArray:numbers toNSMutableArray:mutableArray];
    }];
}


- (void)testPerformance_NSMutableArray_Contains
{
    NSUInteger count = kPerformanceTestIterations;
    NSArray *array = [self p_arrayWithNumbers:count];
    
    [self measureBlock:^()
    {
        BOOL contains = NO;
        for (NSUInteger i = 0; i < count; i++)
        {
            contains = [array containsObject:array[i]];
            XCTAssertTrue(contains);
        }
    }];
}


- (void)testPerformance_NSMutableSet_AddNumbers
{
    NSUInteger count = kPerformanceTestIterations;
    NSArray *numbers = [self p_arrayWithNumbers:count];
    
    NSMutableSet *mutableSet = [NSMutableSet set];
    
    [self measureBlock:^()
    {
        [self p_addNumbersInArray:numbers toNSMutableSet:mutableSet];
    }];
}

#endif


// ------------------------------------------------------------------------------------------
#pragma mark - Helpers
// ------------------------------------------------------------------------------------------
/// Returns an index set containing all indexes from 0 through kTestIndexSetMaxIndex.
- (GNEOrderedIndexSet *)p_indexSetContainingAllIndexes
{
    NSUInteger max = kTestIndexSetMaxIndex;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    [self p_addIndexesToIndexSet:indexSet count:(max + 1) isPerformanceTest:NO];
    
    return indexSet;
}


/// Returns an index set containing all even indexes from 0 through kTestIndexSetMaxIndex.
- (GNEOrderedIndexSet *)p_indexSetContainingEvenIndexes
{
    NSUInteger max = kTestIndexSetMaxIndex;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    for (NSUInteger i = 0; i <= max; i += 2)
    {
        XCTAssertTrue((i % 2) == 0);
        [indexSet addIndex:i];
    }
    
    return indexSet;
}


/// Returns an index set containing all odd indexes from 0 through kTestIndexSetMaxIndex.
- (GNEOrderedIndexSet *)p_indexSetContainingOddIndexes
{
    NSUInteger max = kTestIndexSetMaxIndex;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    for (NSUInteger i = 1; i <= max; i += 2)
    {
        XCTAssertTrue((i % 2) == 1);
        [indexSet addIndex:i];
    }
    
    return indexSet;
}


/// Iterates through the specified index set to find the specified index. Returns
/// YES if the index was found, otherwise NO.
- (BOOL)p_indexSet:(GNEOrderedIndexSet *)indexSet containsIndex:(NSUInteger)index
{
    NSUInteger count = indexSet.count;
    
    for (NSUInteger i = 0; i < count; i++)
    {
        NSUInteger anIndex = [indexSet indexAtPosition:i];
        if (index == anIndex)
        {
            return YES;
        }
    }
    
    return NO;
}


- (void)p_addIndexesToIndexSet:(GNEOrderedIndexSet *)indexSet
                         count:(NSUInteger)count
             isPerformanceTest:(BOOL)isPerformanceTest
{
    for (NSUInteger i = 0; i < count; i++)
    {
        [indexSet addIndex:i];
        
        if (isPerformanceTest == NO)
        {
            XCTAssertCount(indexSet, i + 1);
            XCTAssertContainsIndex(indexSet, i);
            XCTAssertIndexPosition(indexSet, i, i);
            NSUInteger previousIndex = (i > 0) ? (i - 1) : 0;
            XCTAssertIndexPosition(indexSet, previousIndex, previousIndex);
        }
    }
    
    if (isPerformanceTest == NO)
    {
        XCTAssertCount(indexSet, count);
    }
}


- (void)p_addIndexesToNSMutableIndexSet:(NSMutableIndexSet *)mutableIndexSet count:(NSUInteger)count
{
    for (NSUInteger i = 0; i < count; i++)
    {
        [mutableIndexSet addIndex:i];
    }
}


- (void)p_addNumbersInArray:(NSArray *)numbers toNSMutableArray:(NSMutableArray *)mutableArray
{
    NSUInteger count = numbers.count;
    
    for (NSUInteger i = 0; i < count; i++)
    {
        [mutableArray addObject:numbers[i]];
    }
}


- (void)p_addNumbersInArray:(NSArray *)numbers toNSMutableSet:(NSMutableSet *)mutableSet
{
    NSUInteger count = numbers.count;
    
    for (NSUInteger i = 0; i < count; i++)
    {
        [mutableSet addObject:numbers[i]];
    }
}


- (NSArray *)p_arrayWithNumbers:(NSUInteger)count
{
    NSMutableArray *numbers = [NSMutableArray array];
    for (NSUInteger i = 0; i < count; i++)
    {
        [numbers addObject:@(i)];
    }
    
    return [NSArray arrayWithArray:numbers];
}



@end
