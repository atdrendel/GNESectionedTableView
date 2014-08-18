//
//  GNEAppDelegate.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 5/27/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

#import "GNEAppDelegate.h"
#import "GNETableViewController.h"


// ------------------------------------------------------------------------------------------


@interface GNEAppDelegate ()


@property (nonatomic, strong) GNETableViewController *tableViewController;


@end


// ------------------------------------------------------------------------------------------


@implementation GNEAppDelegate


// ------------------------------------------------------------------------------------------
#pragma mark - Application Lifecycle
// ------------------------------------------------------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification * __unused)aNotification
{
    NSView *view = (NSView *)[self.window contentView];
    [view setWantsLayer:YES];
    [view layer].backgroundColor = [[NSColor whiteColor] CGColor];
    
    self.tableViewController = [[GNETableViewController alloc] initWithFrame:[view bounds]];
    [view addSubview:[self.tableViewController view]];
    
}

@end
