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


#define XCTAssertCount(indexSet, c) \
    XCTAssertEqual(indexSet.count, c)

#define XCTAssertContainsIndex(indexSet, i) \
    XCTAssertTrue([indexSet containsIndex:i])

#define XCTAssertNotContainsIndex(indexSet, i) \
    XCTAssertFalse([indexSet containsIndex:i])

#define XCTAssertIndexPosition(i, p) \
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
    XCTAssertIndexPosition(index, 0);
}


- (void)testInitialization_Class_WithIndex
{
    NSUInteger index = 1234;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSetWithIndex:index];
    
    XCTAssertNotNil(indexSet);
    XCTAssertCount(indexSet, 1);
    XCTAssertContainsIndex(indexSet, index);
    XCTAssertIndexPosition(index, 0);
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
    
    XCTAssertIndexPosition(indexes[0], 0);
    XCTAssertIndexPosition(indexes[1], 1);
    XCTAssertIndexPosition(indexes[2], 2);
    XCTAssertIndexPosition(indexes[3], 3);
    XCTAssertIndexPosition(indexes[4], 4);
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
    
    XCTAssertIndexPosition(indexes[0], 0);
    XCTAssertIndexPosition(indexes[1], 1);
    XCTAssertIndexPosition(indexes[2], 2);
    XCTAssertIndexPosition(indexes[3], 3);
    XCTAssertIndexPosition(indexes[4], 4);
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
    
    XCTAssertIndexPosition(indexes[0], 0);
    XCTAssertIndexPosition(indexes[1], 1);
    XCTAssertIndexPosition(indexes[2], 2);
    XCTAssertIndexPosition(indexes[3], 3);
    XCTAssertIndexPosition(indexes[4], 4);
    XCTAssertIndexPosition(indexes[6], 5);
    XCTAssertIndexPosition(indexes[8], 6);
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
    
    XCTAssertIndexPosition(indexes[0], 0);
    XCTAssertIndexPosition(indexes[1], 1);
    XCTAssertIndexPosition(indexes[2], 2);
    XCTAssertIndexPosition(indexes[3], 3);
    XCTAssertIndexPosition(indexes[4], 4);
    XCTAssertIndexPosition(indexes[6], 5);
    XCTAssertIndexPosition(indexes[8], 6);
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
    
    XCTAssertCount(indexSet, kTestIndexSetMaxIndex / 2);
    
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
    
    XCTAssertCount(indexSet, kTestIndexSetMaxIndex / 2);
    
    for (NSUInteger i = 0; i < count; i++)
    {
        XCTAssertContainsIndex(indexSet, oddIndexes[i]);
        XCTAssertNotContainsIndex(indexSet, evenIndexes[i]);
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - Add Indexes
// ------------------------------------------------------------------------------------------
- (void)testAddIndex_0
{
    NSUInteger index = 0;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    XCTAssertCount(indexSet, 0);
    XCTAssertNotContainsIndex(indexSet, index);
    
    [indexSet addIndex:index];
    
    XCTAssertCount(indexSet, 1);
    XCTAssertContainsIndex(indexSet, index);
    XCTAssertIndexPosition(index, 0);
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
    XCTAssertIndexPosition(index, 0);
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
    XCTAssertIndexPosition(index, 0);
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
    XCTAssertIndexPosition(index0, 0);
    XCTAssertIndexPosition(index1, 1);
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
        XCTAssertIndexPosition(i, i);
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
        XCTAssertIndexPosition((count - 1 - i), i);
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
    XCTAssertIndexPosition(index0, 0);
    XCTAssertIndexPosition(index1, 1);
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
    
    XCTAssertIndexPosition(indexes[0], 0);
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
    
    XCTAssertIndexPosition(indexes[0], 0);
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
    
    XCTAssertIndexPosition(indexes[0], 0);
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
    
    XCTAssertIndexPosition(indexes[0], 0);
    XCTAssertIndexPosition(indexes[1], 1);
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
        XCTAssertIndexPosition(i, i);
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
        XCTAssertIndexPosition((count - 1 - i), i);
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
        XCTAssertIndexPosition(expectedIndexes[i], i);
    }
}


- (void)testAddIndexAtPosition_0
{
    NSUInteger index = 0;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Performance - GNEOrderedIndexSet
// ------------------------------------------------------------------------------------------
- (void)testPerformance_Contains
{
    NSUInteger count = kPerformanceTestIterations;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    [self p_addIndexesToIndexSet:indexSet count:count isPerformanceTest:NO];
    
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
    [self p_addIndexesToIndexSet:indexSet count:count isPerformanceTest:NO];
    
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


// ------------------------------------------------------------------------------------------
#pragma mark - Helpers
// ------------------------------------------------------------------------------------------
- (GNEOrderedIndexSet *)p_indexSetContainingEvenIndexes
{
    NSUInteger max = kTestIndexSetMaxIndex;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    for (NSUInteger i = 0; i < max; i += 2)
    {
        XCTAssertTrue((i % 2) == 0);
        [indexSet addIndex:i];
    }
    
    return indexSet;
}


- (GNEOrderedIndexSet *)p_indexSetContainingOddIndexes
{
    NSUInteger max = kTestIndexSetMaxIndex;
    
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    
    for (NSUInteger i = 1; i < max; i += 2)
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
            XCTAssertIndexPosition(i, i);
            NSUInteger previousIndex = (i > 0) ? (i - 1) : 0;
            XCTAssertIndexPosition(previousIndex, previousIndex);
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
