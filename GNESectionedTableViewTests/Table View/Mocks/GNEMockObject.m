//
//  GNEMockObject.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 3/21/15.
//  Copyright (c) 2015 Gone East LLC. All rights reserved.
//

#import "GNEMockObject.h"


// ------------------------------------------------------------------------------------------


@interface GNEMockObject ()

@property (nonatomic, strong) NSMapTable *selectorToBlockMap;

@end


// ------------------------------------------------------------------------------------------


@implementation GNEMockObject


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
- (instancetype)init
{
    if ((self = [super init]))
    {
        _selectorToBlockMap = [[NSMapTable alloc] initWithKeyOptions:NSMapTableCopyIn
                                                        valueOptions:NSMapTableCopyIn
                                                            capacity:10];
    }

    return self;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Dealloc
// ------------------------------------------------------------------------------------------
- (void)dealloc
{
    [_selectorToBlockMap removeAllObjects];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Mock functions
// ------------------------------------------------------------------------------------------
- (void)setBlock:(void *)block forSelector:(SEL)selector
{
    id<NSObject, NSCopying> implementation = (__bridge id <NSObject, NSCopying>)block;
    NSParameterAssert([implementation respondsToSelector:@selector(copy)]);
    NSParameterAssert(selector);

    [self.selectorToBlockMap setObject:implementation forKey:NSStringFromSelector(selector)];
}


- (void *)blockForSelector:(SEL)selector
{
    NSParameterAssert(selector);
    [self assertBlockExistsForSelector:selector];

    return (__bridge void *)[self.selectorToBlockMap objectForKey:NSStringFromSelector(selector)];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Helpers
// ------------------------------------------------------------------------------------------
- (void)assertBlockExistsForSelector:(SEL)selector
{
    NSParameterAssert(selector);

    BOOL blockExists = NO;
    NSString *selectorString = NSStringFromSelector(selector);
    NSEnumerator *enumerator = self.selectorToBlockMap.keyEnumerator;

    NSString *key = nil;
    while (key = [enumerator nextObject])
    {
        if ([selectorString isEqualToString:key])
        {
            blockExists = YES;
            break;
        }
    }

    NSAssert(blockExists, @"%@ does not contain a block for %@.", NSStringFromClass([self class]), selectorString);
}


@end
