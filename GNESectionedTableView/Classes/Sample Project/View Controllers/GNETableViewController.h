//
//  GNETableViewController.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 6/9/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

@class GNESectionedTableView;


// ------------------------------------------------------------------------------------------


@interface GNETableViewController : NSViewController


@property (nonatomic, strong, readonly) GNESectionedTableView *tableView;


/**
 Designated initializer. Creates an instance of GNETableViewController or one of its subclasses and sets its view's
    frame to the specified frame.
 
 @param frameRect Rect for the view controller's view.
 @return Instance of GNETableViewController or one of its subclasses.
 */
- (instancetype)initWithFrame:(CGRect)frameRect;


@end
