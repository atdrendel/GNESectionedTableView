//
//  GNETableViewController.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 6/9/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

#import "GNETableViewController.h"
#import "GNETableViewDataSource.h"
#import "GNESectionedTableView.h"


// ------------------------------------------------------------------------------------------


@interface GNETableViewController ()

/// GNESectionedTableView data source and delegate.
@property (nonatomic, strong) GNETableViewDataSource *dataSource;

@property (nonatomic, strong) NSScrollView *tableViewContainer;
@property (nonatomic, strong, readwrite) GNESectionedTableView *tableView;


@end


// ------------------------------------------------------------------------------------------


@implementation GNETableViewController


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
- (instancetype)initWithFrame:(CGRect)frameRect
{
    if ((self = [super initWithNibName:nil bundle:nil]))
    {
        [[self view] setFrame:frameRect];
        
        [self p_buildAndConfigure];
    }
    
    return self;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Dealloc
// ------------------------------------------------------------------------------------------
- (void)dealloc
{
    self.tableView.tableViewDataSource = nil;
    self.tableView.tableViewDelegate = nil;
    self.tableView = nil;
    self.dataSource = nil;
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSViewController
// ------------------------------------------------------------------------------------------
- (void)loadView
{
    NSView *view = [[NSView alloc] initWithFrame:CGRectZero];
    [view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [view setWantsLayer:YES];
    [view layer].backgroundColor = [[NSColor clearColor] CGColor];
    
    [self setView:view];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Internal - Build and Configure
// ------------------------------------------------------------------------------------------
- (void)p_buildAndConfigure
{
    [self p_buildAndConfigureDataSource];
    [self p_buildAndConfigureTableView];
}


- (void)p_buildAndConfigureDataSource
{
    self.dataSource = [[GNETableViewDataSource alloc] init];
}


- (void)p_buildAndConfigureTableView
{
    CGRect bounds = [[self view] bounds];
    
    self.tableViewContainer = [[NSScrollView alloc] initWithFrame:bounds];
    [self.tableViewContainer setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.tableViewContainer setWantsLayer:YES];
    [self.tableViewContainer setDrawsBackground:NO];
    [self.tableViewContainer setFocusRingType:NSFocusRingTypeNone];
    [self.tableViewContainer setScrollerStyle:NSScrollerStyleOverlay];
    
    self.tableView = [[GNESectionedTableView alloc] initWithFrame:[self.tableViewContainer bounds]];
    [self.tableView setBackgroundColor:[NSColor clearColor]];
    self.tableView.tableViewDataSource = self.dataSource;
    self.tableView.tableViewDelegate = self.dataSource;
    
    [self.tableViewContainer setDocumentView:self.tableView];
    
    [[self view] addSubview:self.tableViewContainer];
}


@end
