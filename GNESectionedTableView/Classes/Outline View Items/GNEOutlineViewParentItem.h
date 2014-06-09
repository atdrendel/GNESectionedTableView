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
 Default initializer. The index path points to an object in the outline view's data source that is used to build
    the view. If the location of the object pointed to by this object changes, the index path of this object
    must be updated.
 
 @param indexPath Index path of the object that contains the data for the outline view.
 @return Instance of WLOutlineViewItem or one of its subclasses.
 */
- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath;


@end
