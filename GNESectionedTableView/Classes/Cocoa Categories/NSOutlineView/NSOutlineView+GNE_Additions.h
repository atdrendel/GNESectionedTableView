//
//  NSOutlineView+GNE_Additions.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 5/27/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

// ------------------------------------------------------------------------------------------


typedef void (^NSOutlineViewBlock)(NSOutlineView * __weak ov);


// ------------------------------------------------------------------------------------------


@interface NSOutlineView (GNE_Additions)


- (void)performAfterAnimations:(NSOutlineViewBlock)block;


@end
