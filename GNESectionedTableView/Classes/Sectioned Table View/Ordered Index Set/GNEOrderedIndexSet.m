//
//  GNEOrderedIndexSet.m
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

#import "GNEOrderedIndexSet.h"


// ------------------------------------------------------------------------------------------


static const NSUInteger kMinimumCount = 100;
static const NSUInteger kCountIncrementLength = 50;

static NSString * const kMemoryAllocationAssertionName = @"Memory Allocation Failure";
static NSString * const kMemoryAllocationAssertionReason = @"Calloc failed";


// ------------------------------------------------------------------------------------------


@interface GNEOrderedIndexSet ()

/// Contains the number of actual indexes stored in indexes and orderedIndexes.
@property (nonatomic, assign) NSUInteger indexesCount;
/// Contains the count of the memory buffers for indexes and orderedIndexes.
@property (nonatomic, assign) NSUInteger memoryCount;

@property (nonatomic, assign) NSUInteger *indexes;
@property (nonatomic, assign) NSUInteger *sortedIndexes;

@end


// ------------------------------------------------------------------------------------------


@implementation GNEOrderedIndexSet


// ------------------------------------------------------------------------------------------
#pragma mark - Class Initialization
// ------------------------------------------------------------------------------------------
+ (instancetype)indexSet
{
    return [[self class] indexSetWithIndexes:NULL count:0];
}


+ (instancetype)indexSetWithIndex:(NSUInteger)index
{
    NSUInteger indexes[] = {index};
    
    return [[self class] indexSetWithIndexes:indexes count:1];
}


+ (instancetype)indexSetWithNSIndexSet:(NSIndexSet *)indexSet
{
    return [[[self class] alloc] initWithNSIndexSet:indexSet];
}


+ (instancetype)indexSetWithIndexes:(NSUInteger *)indexes
                              count:(NSUInteger)count
{
    return [[[self class] alloc] initWithIndexes:indexes count:count];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
- (instancetype)init
{
    return [self initWithIndexes:NULL count:0];
}


- (instancetype)initWithIndex:(NSUInteger)index
{
    NSUInteger indexes[] = {index};
    
    return [self initWithIndexes:indexes count:1];
}


- (instancetype)initWithNSIndexSet:(NSIndexSet *)indexSet
{
    NSParameterAssert(indexSet == nil || [indexSet isKindOfClass:[NSIndexSet class]]);
    
    NSUInteger count = indexSet.count;
    
    NSUInteger indexes[count];
    [indexSet getIndexes:indexes maxCount:count inIndexRange:NULL];
    
    return [self initWithIndexes:indexes count:count];
}


- (instancetype)initWithIndexes:(NSUInteger *)indexes count:(NSUInteger)count
{
    if ((self = [super init]))
    {
        _indexesCount = 0;
        _memoryCount = (kMinimumCount > count) ? kMinimumCount : count + kCountIncrementLength;
        _indexes = calloc(_memoryCount, sizeof(NSUInteger));
        _sortedIndexes = calloc(_memoryCount, sizeof(NSUInteger));
        
        [self addIndexes:indexes count:count];
    }
    
    return self;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Dealloc
// ------------------------------------------------------------------------------------------
- (void)dealloc
{
    if (_indexes)
    {
        free(_indexes);
    }
    _indexes = NULL;
    
    if (_sortedIndexes)
    {
        free(_sortedIndexes);
    }
    _sortedIndexes = NULL;
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSObject
// ------------------------------------------------------------------------------------------
- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[GNEOrderedIndexSet class]])
    {
        return [self isEqualToIndexSet:(GNEOrderedIndexSet *)object];
    }
    
    return NO;
}


- (NSUInteger)hash
{
    NSUInteger hash = 0;
    
    for (NSUInteger i = 0; i < self.indexesCount; i++)
    {
        hash += self.indexes[i];
    }
    
    return hash;
}


- (NSString *)description
{
    NSUInteger count = self.indexesCount;
    
    NSString *commaSpace = @", ";
    
    NSMutableString *mutableIndexesString = [NSMutableString stringWithString:@"{ "];
    for (NSUInteger i = 0; i < count; i++)
    {
        [mutableIndexesString appendFormat:@"%llu%@", (unsigned long long)self.indexes[i], commaSpace];
    }
    if ([mutableIndexesString hasSuffix:commaSpace])
    {
        [mutableIndexesString deleteCharactersInRange:NSMakeRange(mutableIndexesString.length - commaSpace.length,
                                                                  commaSpace.length)];
    }
    [mutableIndexesString appendString:@" }"];
    
    return [NSString stringWithFormat:@"<%@: %p> Number of indexes: %llu, indexes: %@",
            NSStringFromClass([self class]), self, (unsigned long long)count, mutableIndexesString];
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSCopying
// ------------------------------------------------------------------------------------------
- (instancetype)copyWithZone:(NSZone * __unused)zone
{
    NSUInteger *indexes = self.indexes;
    NSUInteger indexesCount = self.indexesCount;
    
    GNEOrderedIndexSet *copy = [GNEOrderedIndexSet indexSetWithIndexes:indexes
                                                                 count:indexesCount];
    
    return copy;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Public - Add/Remove
// ------------------------------------------------------------------------------------------
- (void)addIndex:(NSUInteger)index
{
    NSParameterAssert(index < NSNotFound);
    
    if ([self containsIndex:index] == NO)
    {
        [self p_addIndexToIndexes:index];
        [self p_addIndexToSortedIndexes:index];
        self.indexesCount++;
        [self p_increaseBackingStoreMemoryIfNeeded];
    }
}


- (void)addIndexes:(NSUInteger *)indexes count:(NSUInteger)count
{
    for (NSUInteger i = 0; i < count; i++)
    {
        [self addIndex:indexes[i]];
    }
}


- (void)addIndex:(NSUInteger)index atPosition:(NSUInteger)position
{
    NSParameterAssert(index < NSNotFound);
    NSParameterAssert(position <= self.indexesCount);
    
    if (index < NSNotFound && position <= self.indexesCount &&
        [self containsIndex:index] == NO)
    {
        [self p_addIndexToIndexes:index atPosition:position];
        [self p_addIndexToSortedIndexes:index];
        self.indexesCount++;
        [self p_increaseBackingStoreMemoryIfNeeded];
    }
}


- (void)removeIndex:(NSUInteger)index
{
    NSParameterAssert(index < NSNotFound);
    
    if (index < NSNotFound && [self containsIndex:index])
    {
        [self p_removeIndexFromIndexes:index];
        [self p_removeIndexFromSortedIndexes:index];
        self.indexesCount--;
    }
}


- (void)removeIndexAtPosition:(NSUInteger)position
{
    NSParameterAssert(position < self.indexesCount);
    
    if (position >= self.indexesCount)
    {
        return;
    }
    
    NSUInteger index = self.indexes[position];
    [self p_decrementPositionsAbovePosition:position inIndexes:self.indexes];
    [self p_removeIndexFromSortedIndexes:index];
    self.indexesCount--;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Public - Finding Indexes
// ------------------------------------------------------------------------------------------
- (NSUInteger)indexAtPosition:(NSUInteger)position
{
    if (position < self.indexesCount)
    {
        return self.indexes[position];
    }
    
    return NSNotFound;
}


- (NSUInteger)positionOfIndex:(NSUInteger)index
{
    if ([self containsIndex:index] == NO)
    {
        return NSNotFound;
    }
    
    for (NSUInteger i = 0; i < self.indexesCount; i++)
    {
        NSUInteger anIndex = [self indexAtPosition:i];
        
        if (index == anIndex)
        {
            return i;
        }
    }
    
    return NSNotFound;
}


- (BOOL)containsIndex:(NSUInteger)index
{
    NSUInteger position = [self p_positionInSortedIndexesOfIndex:index
                                                   startPosition:0
                                                     endPosition:self.indexesCount];
    
    return (position != NSNotFound);
}


// ------------------------------------------------------------------------------------------
#pragma mark - Public - Enumeration
// ------------------------------------------------------------------------------------------
- (void)enumerateIndexesUsingBlock:(void (^)(NSUInteger index, NSUInteger position, BOOL *stop))block
{
    [self enumerateIndexesWithOptions:0 usingBlock:block];
}


- (void)enumerateIndexesWithOptions:(NSEnumerationOptions)options
                         usingBlock:(void (^)(NSUInteger, NSUInteger, BOOL *))block
{
    BOOL isReversed = options & NSEnumerationReverse;
    
    NSUInteger count = self.indexesCount;
    for (NSUInteger i = 0; i < count; i++)
    {
        BOOL stop = NO;
        
        NSUInteger index = (isReversed) ? (count - 1 - i) : i;
        block(self.indexes[index], i, &stop);
        
        if (stop)
        {
            break;
        }
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - Public - Equality
// ------------------------------------------------------------------------------------------
- (BOOL)isEqualToIndexSet:(GNEOrderedIndexSet *)indexSet
{
    if (self.count == indexSet.count)
    {
        NSUInteger count = self.count;
        for (NSUInteger i = 0; i < count; i++)
        {
            NSUInteger selfIndex = [self indexAtPosition:i];
            NSUInteger otherIndex = [indexSet indexAtPosition:i];
            
            if (selfIndex != otherIndex)
            {
                return NO;
            }
        }
        
        return YES;
    }
    
    return NO;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Private - Add/Remove
// ------------------------------------------------------------------------------------------
- (void)p_addIndexToIndexes:(NSUInteger)index
{
    [self p_addIndexToIndexes:index atPosition:self.indexesCount];
}


- (void)p_addIndexToIndexes:(NSUInteger)index atPosition:(NSUInteger)position
{
    position = (position <= self.indexesCount) ? position : self.indexesCount;
    [self p_incrementPositionsAtAndAbovePosition:position inIndexes:self.indexes];
    self.indexes[position] = index;
}


- (void)p_addIndexToSortedIndexes:(NSUInteger)index
{
    NSUInteger insertionPosition = [self p_insertionPositionInSortedIndexesForIndex:index];
    
    if (insertionPosition == NSNotFound)
    {
        return;
    }

    [self p_incrementPositionsAtAndAbovePosition:insertionPosition
                                       inIndexes:self.sortedIndexes];
    self.sortedIndexes[insertionPosition] = index;
}


- (void)p_removeIndexFromIndexes:(NSUInteger)index
{
    NSUInteger position = NSNotFound;
    
    for (NSUInteger i = 0; i < self.indexesCount; i++)
    {
        NSUInteger anIndex = self.indexes[i];
        if (anIndex == index)
        {
            position = i;
            break;
        }
    }
    
    if (position != NSNotFound)
    {
        [self p_decrementPositionsAbovePosition:position inIndexes:self.indexes];
    }
}


- (void)p_removeIndexFromSortedIndexes:(NSUInteger)index
{
    NSUInteger position = [self p_positionInSortedIndexesOfIndex:index
                                                   startPosition:0
                                                     endPosition:(self.indexesCount - 1)];
    
    if (position == NSNotFound)
    {
        return;
    }
    
    [self p_decrementPositionsAbovePosition:position
                                  inIndexes:self.sortedIndexes];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Private - Finding Indexes
// ------------------------------------------------------------------------------------------
- (NSUInteger)p_smallestIndex
{
    if (self.indexesCount > 0)
    {
        return self.sortedIndexes[0];
    }
    
    return NSNotFound;
}


- (NSUInteger)p_largestIndex
{
    if (self.indexesCount > 0)
    {
        return self.sortedIndexes[self.indexesCount - 1];
    }
    
    return NSNotFound;
}



/// Returns the position of the specified index within the specified range or NSNotFound if the
/// specified index could not be found.
- (NSUInteger)p_positionInSortedIndexesOfIndex:(NSUInteger)index
                                 startPosition:(NSUInteger)startPosition
                                   endPosition:(NSUInteger)endPosition
{
    NSInteger bottom = (NSInteger)startPosition;
    NSInteger top = (NSInteger)endPosition;
    
    if (self.indexesCount == 0 || index >= NSNotFound || top < bottom)
    {
        return NSNotFound;
    }
    
    NSInteger middle = ((bottom + top) / 2);
    
    NSUInteger midIndex = self.sortedIndexes[middle];
    if (index < midIndex)
    {
        return [self p_positionInSortedIndexesOfIndex:index
                                        startPosition:(NSUInteger)bottom
                                          endPosition:((NSUInteger)middle - 1)];
    }
    else if (index > midIndex)
    {
        return [self p_positionInSortedIndexesOfIndex:index
                                        startPosition:((NSUInteger)middle + 1)
                                          endPosition:(NSUInteger)top];
    }
    
    return (NSUInteger)middle;
}


- (NSUInteger)p_insertionPositionInSortedIndexesForIndex:(NSUInteger)index
{
    if (self.indexesCount == 0)
    {
        return 0;
    }
    
    NSUInteger smallestIndex = [self p_smallestIndex];
    NSUInteger largestIndex = [self p_largestIndex];
    
    if (index < smallestIndex)
    {
        return 0;
    }
    else if (index > largestIndex)
    {
        return self.indexesCount;
    }
    
    NSUInteger bottom = 0;
    NSUInteger top = self.indexesCount - 1;
    
    while (top > bottom)
    {
        NSUInteger middle = ((bottom + top) / 2);
        NSUInteger midIndex = self.sortedIndexes[middle];
        
        if (index > midIndex)
        {
            bottom = middle + 1;
        }
        else
        {
            top = middle - 1;
        }
    }
    
    while (self.sortedIndexes[bottom] < index)
    {
        bottom++;
    }
    
    return bottom;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Private - Memory
// ------------------------------------------------------------------------------------------
- (void)p_increaseBackingStoreMemoryIfNeeded
{
    // If the number of indexes is within 10 of the allocated memory, extend the indexes.
    if ((self.indexesCount + 10) > self.memoryCount)
    {
        self.memoryCount += kCountIncrementLength;
        
        self.indexes = [self p_reallocIndexes:self.indexes count:self.memoryCount];
        self.sortedIndexes = [self p_reallocIndexes:self.sortedIndexes count:self.memoryCount];
    }
}


- (NSUInteger *)p_reallocIndexes:(NSUInteger *)indexes count:(NSUInteger)count
{
    NSUInteger *newIndexes = calloc(count, sizeof(NSUInteger));
    if (newIndexes)
    {
        for (NSUInteger i = 0; i < self.indexesCount && i < count; i++)
        {
            newIndexes[i] = indexes[i];
        }
        
        free(indexes);
        indexes = NULL;
        
        return newIndexes;
    }
    else
    {
        NSException *exception = [NSException exceptionWithName:kMemoryAllocationAssertionName
                                                         reason:kMemoryAllocationAssertionReason
                                                       userInfo:nil];
        [exception raise];
        
        return indexes;
    }
}


- (void)p_decrementPositionsAbovePosition:(NSUInteger)position inIndexes:(NSUInteger *)indexes
{
    NSUInteger moveTo = position;
    NSUInteger moveFrom = position + 1;
    
    while (moveFrom <= self.indexesCount)
    {
        NSUInteger index = (moveFrom == self.indexesCount) ? 0 : indexes[moveFrom];
        indexes[moveTo] = index;
        
        moveTo++;
        moveFrom++;
    }
    
    // After decrementing the indexes, zero out the remaining memory.
    for (NSUInteger i = self.indexesCount; i < self.memoryCount; i++)
    {
        indexes[i] = 0;
    }
}


- (void)p_incrementPositionsAtAndAbovePosition:(NSUInteger)position inIndexes:(NSUInteger *)indexes
{
    if (self.indexesCount == 0)
    {
        return;
    }
    
    NSUInteger moveTo = self.indexesCount;
    NSUInteger moveFrom = self.indexesCount - 1;
    
    while (moveFrom >= position)
    {
        NSUInteger index = indexes[moveFrom];
        indexes[moveTo] = index;
        
        if (moveFrom == 0)
        {
            break;
        }
        
        moveTo--;
        moveFrom--;
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - Accessors
// ------------------------------------------------------------------------------------------
- (NSUInteger)count
{
    return self.indexesCount;
}


- (NSUInteger)smallestIndex
{
    return [self p_smallestIndex];
}


- (NSUInteger)largestIndex
{
    return [self p_largestIndex];
}


- (NSIndexSet *)ns_indexSet
{
    NSMutableIndexSet *mutableIndexSet = [NSMutableIndexSet indexSet];
    [self enumerateIndexesUsingBlock:^(NSUInteger index, NSUInteger position __unused, BOOL *stop __unused)
    {
        [mutableIndexSet addIndex:index];
    }];
    
    return [mutableIndexSet copy];
}


@end
