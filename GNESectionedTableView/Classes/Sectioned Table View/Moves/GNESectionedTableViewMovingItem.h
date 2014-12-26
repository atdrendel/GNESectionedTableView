//
//  GNESectionedTableViewMovingItem.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 12/22/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

@interface GNESectionedTableViewMovingItem : NSObject

@property (nonatomic, strong, readonly) NSView *view;
@property (nonatomic, copy, readonly) NSIndexPath *indexPath;

/**
 Returns an instance of GNEDraggingItem or one of its subclasses.
 
 @param cellView Table cell view that is being dragged.
 @param frame Frame of the table cell view in terms of its table view.
 @param indexPath Index path of the cell view. This acts as the dragging item's unique identifier.
 */
- (instancetype)initWithTableCellView:(NSTableCellView *)cellView
                                frame:(CGRect)frame
                            indexPath:(NSIndexPath *)indexPath;

/**
 Returns an instance of GNEDraggingItem or one of its subclasses.
 
 @param cellViews Array of table cell views belonging to the same section.
 @param frame Frame of the section (encompassing all of the table cell views) in terms of its table view.
 @param indexPath Index path of the section's header. This acts as the dragging item's unique identifier.
 */
- (instancetype)initForSectionWithTableCellViews:(NSArray *)cellViews
                                           frame:(CGRect)frame
                                 headerIndexPath:(NSIndexPath *)indexPath;

@end
