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

@property (nonatomic, strong) NSScrollView *contentScrollView;
@property (nonatomic, strong) NSView *headerView;

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
        self.view.frame = frameRect;
        
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
    view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    view.wantsLayer = YES;
    view.layer.backgroundColor = [NSColor clearColor].CGColor;
    view.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
    
    self.view = view;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Internal - Build and Configure
// ------------------------------------------------------------------------------------------
- (void)p_buildAndConfigure
{
    [self p_buildAndConfigureDataSource];
    [self p_buildAndConfigureTableView];
    [self.dataSource setTableView:self.tableView];
}


- (void)p_buildAndConfigureDataSource
{
    self.dataSource = [[GNETableViewDataSource alloc] init];
}


- (void)p_buildAndConfigureTableView
{
    self.tableViewContainer = [[NSScrollView alloc] initWithFrame:self.view.bounds];
    self.tableViewContainer.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.tableViewContainer.wantsLayer = YES;
    self.tableViewContainer.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
    self.tableViewContainer.drawsBackground = NO;
    self.tableViewContainer.focusRingType = NSFocusRingTypeNone;
    self.tableViewContainer.scrollerStyle = NSScrollerStyleOverlay;
    self.tableViewContainer.hasHorizontalScroller = NO;
    self.tableViewContainer.hasVerticalScroller = YES;
    
    self.tableView = [[GNESectionedTableView alloc] initWithFrame:self.tableViewContainer.bounds];
    self.tableView.autoresizingMask = NSViewNotSizable;
    self.tableView.backgroundColor = [NSColor clearColor];
    self.tableView.intercellSpacing = CGSizeZero;
    self.tableView.allowsMultipleSelection = YES;
    
    self.tableView.tableViewDataSource = self.dataSource;
    self.tableView.tableViewDelegate = self.dataSource;
    
    self.tableViewContainer.documentView = self.tableView;
    
    [self.view addSubview:self.tableViewContainer];
}


@end
