//
//  GNEMockObject.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 3/21/15.
//  Copyright (c) 2015 Gone East LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GNESectionedTableViewTests.h"


// ------------------------------------------------------------------------------------------


typedef void(^MockVoidBlock)();
typedef NSArray *(^MockReturnArrayBlock)();
typedef void(^MockObjectBlock)(id object);
typedef void(^MockObjectObjectBlock)(id object1, id object2);
typedef void(^MockObjectUnsignedIntegerBlock)(id object, NSUInteger unsignedInteger);


// ------------------------------------------------------------------------------------------


@interface GNEMockObject : NSObject


- (void)setBlock:(void *)block forSelector:(SEL)selector;
- (void *)blockForSelector:(SEL)selector;


@end
