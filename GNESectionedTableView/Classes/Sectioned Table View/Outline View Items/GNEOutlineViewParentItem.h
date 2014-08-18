//
//  GNEOutlineViewParentItem.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 5/27/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

#import "GNEOutlineViewItem.h"


// ------------------------------------------------------------------------------------------


@interface GNEOutlineViewParentItem : GNEOutlineViewItem


/**
 YES if the outline view row view representing this object should be visible to the user, NO otherwise. If the row
    view should not be visible, it should be completely transparent and have a height of 0.1 pixel.
 */
@property (nonatomic, assign, getter = isVisible) BOOL visible;


/**
 Default initializer.
 
 @return Instance of WLOutlineViewItem or one of its subclasses.
 */
- (instancetype)init;


@end
