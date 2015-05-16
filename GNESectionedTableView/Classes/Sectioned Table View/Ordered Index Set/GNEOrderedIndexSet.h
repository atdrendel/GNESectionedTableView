//
//  GNEOrderedIndexSet.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 12/22/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
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

@import Cocoa;


@interface GNEOrderedIndexSet : NSObject <NSCopying>

/// Returns the number of indexes contained in the receiver.
@property (nonatomic, assign, readonly) NSUInteger count;

/// Returns the smallest index in the set or NSNotFound if there are no indexes in the set. O(1)
@property (nonatomic, assign, readonly) NSUInteger smallestIndex;

/// Returns the largest index in the set or NSNotFound if there are no indexes in the set. O(1)
@property (nonatomic, assign, readonly) NSUInteger largestIndex;

/// Returns an unordered index set (NSIndexSet) representation of the receiver.
@property (nonatomic, assign, readonly) NSIndexSet *ns_indexSet;

#pragma mark - Class initializers
+ (instancetype)indexSet;
+ (instancetype)indexSetWithIndex:(NSUInteger)index;
+ (instancetype)indexSetWithNSIndexSet:(NSIndexSet *)indexSet;
+ (instancetype)indexSetWithIndexes:(NSUInteger *)indexes count:(NSUInteger)count;

#pragma mark - Initializers
- (instancetype)init;
- (instancetype)initWithIndex:(NSUInteger)index;
- (instancetype)initWithNSIndexSet:(NSIndexSet *)indexSet;
- (instancetype)initWithIndexes:(NSUInteger *)indexes count:(NSUInteger)count NS_DESIGNATED_INITIALIZER;

#pragma mark - Add/Remove Indexes
/// Adds the specified index to the receiver if the receiver does not already
/// contain it. O(lg n)
- (void)addIndex:(NSUInteger)index;
/// Adds the specified indexes to the receiver if the receiver does not already
/// contain them. O(lg n)
- (void)addIndexes:(NSUInteger *)indexes count:(NSUInteger)count;
/// Adds the specified index to the receiver at the specified position if the receiver
/// does not already contain it. Throws an exception if position is greater than
/// the receiver's count. O(n)
- (void)addIndex:(NSUInteger)index atPosition:(NSUInteger)position;
/// Removes the specified index from the receiver, if the receiver contains it. Throws an
/// exception if the specified index is greater than or equal to NSNotFound. O(n)
- (void)removeIndex:(NSUInteger)index;
/// Removes the index located at the specified position. Throws an exception if the specified
/// position is greater than the receiver's count - 1. O(lg n)
- (void)removeIndexAtPosition:(NSUInteger)position;

#pragma mark - Finding Indexes
/// Returns the index at the specified position or NSNotFound if the position is beyond the
/// bounds of the receiver. O(1)
- (NSUInteger)indexAtPosition:(NSUInteger)position;
/// Returns the position of the specified index or NSNotFound if the receiver doesn't
/// contain the specified index. O(n)
- (NSUInteger)positionOfIndex:(NSUInteger)index;
/// Returns YES if the receiver contains the specified index, otherwise NO. O(lg n)
- (BOOL)containsIndex:(NSUInteger)index;

#pragma mark - Enumerating Indexes
/// Executes a given block using each object in the receiver.
- (void)enumerateIndexesUsingBlock:(void (^)(NSUInteger index, NSUInteger position, BOOL *stop))block;
/// Executes a given block using each object in the receiver using the specified options (currently,
/// NSEnumerationReverse is the only option supported).
- (void)enumerateIndexesWithOptions:(NSEnumerationOptions)options
                         usingBlock:(void (^)(NSUInteger index, NSUInteger position, BOOL *stop))block;

#pragma mark - Equality
/// Returns YES if the receiver is equal to the specified index set, otherwise NO.
/// Equality is determined by the count of the index sets and the
- (BOOL)isEqualToIndexSet:(GNEOrderedIndexSet *)indexSet;

@end
