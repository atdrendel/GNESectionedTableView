//
//  GNEOrderedIndexSet.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 12/22/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

@interface GNEOrderedIndexSet : NSObject

@property (nonatomic, assign, readonly) NSUInteger count;

#pragma mark - Class initializers
+ (instancetype)indexSet;
+ (instancetype)indexSetWithIndex:(NSUInteger)index;
+ (instancetype)indexSetWithIndexes:(NSUInteger *)indexes count:(NSUInteger)count;

#pragma mark - Initializers
- (instancetype)init;
- (instancetype)initWithIndex:(NSUInteger)index;
- (instancetype)initWithIndexes:(NSUInteger *)indexes count:(NSUInteger)count NS_DESIGNATED_INITIALIZER;

#pragma mark - Add/Remove Indexes
- (void)addIndex:(NSUInteger)index;
- (void)addIndexes:(NSUInteger *)indexes count:(NSUInteger)count;
- (void)addIndex:(NSUInteger)index atPosition:(NSUInteger)position;
- (void)removeIndex:(NSUInteger)index;
- (void)removeIndexAtPosition:(NSUInteger)position;

#pragma mark - Finding Indexes
- (NSUInteger)indexAtPosition:(NSUInteger)position;
- (NSUInteger)positionOfIndex:(NSUInteger)index;
- (BOOL)containsIndex:(NSUInteger)index;

#pragma mark - Enumerating Indexes
- (void)enumerateIndexesUsingBlock:(void (^)(NSUInteger index, NSUInteger position, BOOL *stop))block;

#pragma mark - Equality
- (BOOL)isEqualToIndexSet:(GNEOrderedIndexSet *)indexSet;

@end
