//
//  GNEOutlineViewItem.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 5/27/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

@class GNEOutlineViewItem;
@class GNEOutlineViewParentItem;


// ------------------------------------------------------------------------------------------


extern NSString * const GNEOutlineViewItemPasteboardType;

extern NSString * const GNEOutlineViewItemParentItemKey;


// ------------------------------------------------------------------------------------------


@protocol GNEOutlineViewItemPasteboardWritingDelegate <NSObject>


- (NSInteger)rowForOutlineViewItem:(GNEOutlineViewItem *)item;


@end


// ------------------------------------------------------------------------------------------


@interface GNEOutlineViewItem : NSObject <NSCoding, NSPasteboardReading, NSPasteboardWriting>


@property (nonatomic, weak) id <GNEOutlineViewItemPasteboardWritingDelegate> pasteboardWritingDelegate;


/**
 Parent item of this object.
 */
@property (nonatomic, weak) GNEOutlineViewParentItem *parentItem;


/**
 Returns the outline view row of the receiver if it is being dragged, otherwise -1.
 */
@property (nonatomic, assign, readonly) NSInteger draggedRow;


/**
 Default initializer. The parent item points to this object's parent item. This reference must be kept up-to-date.
 
 @param parentItem Parent item of this object.
 @return Instance of WLOutlineViewItem or one of its subclasses.
 */
- (instancetype)initWithParentItem:(GNEOutlineViewParentItem *)parentItem;


@end
