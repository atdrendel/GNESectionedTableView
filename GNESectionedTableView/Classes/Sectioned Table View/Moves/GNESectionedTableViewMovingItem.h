//
//  GNESectionedTableViewMovingItem.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 12/22/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 Gone East LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

@import Cocoa;


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
