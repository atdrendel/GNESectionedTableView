//
//  GNEOrderedIndexSet.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 12/22/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

#import "GNEOrderedIndexSet.h"


// ------------------------------------------------------------------------------------------


static const NSUInteger kMinimumCount = 100;
static const NSUInteger kCountIncrementLength = 50;


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


- (instancetype)initWithIndexes:(NSUInteger *)indexes count:(NSUInteger)count
{
    if ((self = [super init]))
    {
        _memoryCount = (kMinimumCount > count) ? kMinimumCount : count + kCountIncrementLength;
        _indexesCount = count;
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
    
    if (_sortedIndexes)
    {
        free(_sortedIndexes);
    }
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
#pragma mark - Public - Add/Remove
// ------------------------------------------------------------------------------------------
- (void)addIndex:(NSUInteger)index
{
    NSParameterAssert(index < NSNotFound);
    
    if ([self containsIndex:index] == NO)
    {
        [self p_addIndexToIndexes:index];
        [self p_addIndexToOrderedIndexes:index];
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
    
    if ([self containsIndex:index] == NO)
    {
        [self p_addIndexToIndexes:index atPosition:position];
        [self p_addIndexToOrderedIndexes:index];
        self.indexesCount++;
        [self p_increaseBackingStoreMemoryIfNeeded];
    }
}


- (void)removeIndex:(NSUInteger)index
{
    NSParameterAssert(index < NSNotFound);
    
    if ([self containsIndex:index])
    {
        [self p_removeIndexFromIndexes:index];
        [self p_removeIndexFromOrderedIndexes:index];
        self.indexesCount--;
    }
}


- (void)removeIndexAtPosition:(NSUInteger)position
{
    if (position >= self.indexesCount)
    {
        return;
    }
    
    NSUInteger index = self.indexes[position];
    [self removeIndex:index];
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
    NSUInteger smallestIndex = [self p_smallestIndex];
    NSUInteger largestIndex = [self p_largestIndex];
    
    if (smallestIndex != NSNotFound && index < smallestIndex)
    {
        return NSNotFound;
    }
    
    if (largestIndex != NSNotFound && index > largestIndex)
    {
        return NSNotFound;
    }
    
    return [self p_positionOfIndex:index
                     startPosition:0
                       endPosition:self.indexesCount
                 insertionPosition:NULL];
}


- (BOOL)containsIndex:(NSUInteger)index
{
    return ([self positionOfIndex:index] != NSNotFound);
}


// ------------------------------------------------------------------------------------------
#pragma mark - Enumeration
// ------------------------------------------------------------------------------------------
- (void)enumerateIndexesUsingBlock:(void (^)(NSUInteger index, NSUInteger position, BOOL *stop))block
{
    NSUInteger count = self.indexesCount;
    for (NSUInteger i = 0; i < count; i++)
    {
        BOOL stop = NO;
        block(self.indexes[i], i, &stop);
        
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


- (void)p_addIndexToOrderedIndexes:(NSUInteger)index
{
    NSUInteger insertionPosition = [self p_insertionPositionForIndex:index];
    
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


- (void)p_removeIndexFromOrderedIndexes:(NSUInteger)index
{
    NSUInteger position = [self p_positionOfIndex:index
                                    startPosition:0
                                      endPosition:self.indexesCount
                                insertionPosition:NULL];
    
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


/// Returns the largest index in the set or NSNotFound if there are no indexes in the set.
- (NSUInteger)p_largestIndex
{
    if (self.indexesCount > 0)
    {
        return self.sortedIndexes[self.indexesCount - 1];
    }
    
    return NSNotFound;
}


/**
 Returns the position of the specified index within the specified range or NSNotFound if the
 specified index could not be found. Optionally, sets the "insertion position" to a best
 guess.
 */
- (NSUInteger)p_positionOfIndex:(NSUInteger)index
                  startPosition:(NSUInteger)startPosition
                    endPosition:(NSUInteger)endPosition
              insertionPosition:(NSUInteger *)insertionPosition
{
    NSUInteger bottom = startPosition;
    NSUInteger top = endPosition;
    
    if (top < bottom)
    {
        return NSNotFound;
    }
    
    NSUInteger middle = MAX((NSUInteger)(top / 2), bottom);
    
    NSUInteger anIndex = self.sortedIndexes[middle];
    if (index < anIndex)
    {
        if (insertionPosition && bottom < (middle - 1))
        {
            *insertionPosition = bottom;
        }
        
        return [self p_positionOfIndex:index
                         startPosition:bottom
                           endPosition:(middle - 1)
                     insertionPosition:insertionPosition];
    }
    else if (index > anIndex)
    {
        if (insertionPosition)
        {
            *insertionPosition = middle;
        }
        
        return [self p_positionOfIndex:index
                         startPosition:(middle + 1)
                           endPosition:top
                     insertionPosition:insertionPosition];
    }
    
    if (insertionPosition)
    {
        *insertionPosition = middle;
    }
    
    return middle;
}


- (NSUInteger)p_insertionPositionForIndex:(NSUInteger)index
{
    NSUInteger insertionPosition = 0;
    NSUInteger position = [self p_positionOfIndex:index
                                    startPosition:0
                                      endPosition:self.indexesCount
                                insertionPosition:&insertionPosition];
    
    // If the index is already in indexes, return.
    if (position != NSNotFound)
    {
        return NSNotFound;
    }
    
    NSParameterAssert(self.sortedIndexes[insertionPosition] < index);
    
    NSUInteger nextIndex = self.sortedIndexes[insertionPosition + 1];
    while (insertionPosition <= self.indexesCount && nextIndex < index)
    {
        insertionPosition++;
        nextIndex = self.sortedIndexes[insertionPosition + 1];
    }
    
    return insertionPosition;
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
        
        return newIndexes;
    }
    
    return indexes;
}


- (void)p_decrementPositionsAbovePosition:(NSUInteger)position inIndexes:(NSUInteger *)indexes
{
    NSUInteger moveTo = position;
    NSUInteger moveFrom = position + 1;
    
    while (moveFrom < self.indexesCount)
    {
        NSUInteger index = indexes[moveFrom];
        indexes[moveTo] = index;
        
        moveTo++;
        moveFrom++;
    }
}


- (void)p_incrementPositionsAtAndAbovePosition:(NSUInteger)position inIndexes:(NSUInteger *)indexes
{
    NSUInteger moveTo = self.indexesCount;
    NSUInteger moveFrom = self.indexesCount - 1;
    
    while (moveFrom >= position)
    {
        NSUInteger index = indexes[moveFrom];
        indexes[moveTo] = index;
        
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


@end
