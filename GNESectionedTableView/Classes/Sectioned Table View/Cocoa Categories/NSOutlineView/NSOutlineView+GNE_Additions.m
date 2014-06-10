//
//  NSOutlineView+GNE_Additions.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 5/27/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

#import "NSOutlineView+GNE_Additions.h"

@implementation NSOutlineView (GNE_Additions)


- (void)performAfterAnimations:(NSOutlineViewBlock)block
{
    __weak typeof(self) weakSelf = self;
    
    [[NSAnimationContext currentContext] setCompletionHandler:^()
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        block(strongSelf);
    }];
}


@end
