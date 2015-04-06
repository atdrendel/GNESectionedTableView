//
//  GNEMockObject.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 3/21/15.
//  Copyright (c) 2015 Gone East LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GNESectionedTableView.h"
#import "GNEMockBlocks.h"


// ------------------------------------------------------------------------------------------


@interface GNEMockObject : NSObject


@property (nonatomic, assign) BOOL didFinishSettingUp;

- (void)setBlock:(void *)block forSelector:(SEL)selector;
- (void *)blockForSelector:(SEL)selector;


@end
