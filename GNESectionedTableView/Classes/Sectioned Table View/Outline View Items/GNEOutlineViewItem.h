//
//  GNEOutlineViewItem.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 5/27/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

@class GNEOutlineViewParentItem;


// ------------------------------------------------------------------------------------------


extern NSString * const GNEOutlineViewItemPasteboardType;

extern NSString * const GNEOutlineViewItemIndexPathKey;
extern NSString * const GNEOutlineViewItemParentItemKey;


// ------------------------------------------------------------------------------------------


@interface GNEOutlineViewItem : NSObject <NSCoding, NSPasteboardReading, NSPasteboardWriting>


/**
 Index path of the object in the outline view's data source (usually a sectioned array controller) that this
    object represents. Must not be nil.
 */
@property (nonatomic, strong) NSIndexPath *indexPath;


/**
 Parent item of this object.
 */
@property (nonatomic, weak) GNEOutlineViewParentItem *parentItem;


/**
 Default initializer. The index path points to an object in the outline view's data source (usually a sectioned
    array controller) that is used to build the view. If the location of the object pointed to by this object
    changes, the index path of this object must be updated. The parent item points to this object's parent item.
    This reference must also be kept up-to-date.
 
 @param indexPath Index path of the object that contains the data for the outline view.
 @param parentItem Parent item of this object. Must not be nil.
 @return Instance of WLOutlineViewItem or one of its subclasses.
 */
- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath parentItem:(GNEOutlineViewParentItem *)parentItem;


@end
