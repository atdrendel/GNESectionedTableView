//
//  GNETableViewDataSource.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 6/9/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

#import "GNETableViewDataSource.h"
#import "GNETableCellView.h"
#import "GNEHeaderCellView.h"


// ------------------------------------------------------------------------------------------


static NSString * const kRowViewIdentifier = @"com.goneeast.RowViewIdentifier";
static NSString * const kCellViewIdentifier = @"com.goneeast.CellViewIdentifier";

static NSString * const kHeaderRowViewIdentifier = @"com.goneeast.HeaderRowViewIdentifier";
static NSString * const kHeaderCellViewIdentifier = @"com.goneeast.HeaderCellViewIdentifier";


// ------------------------------------------------------------------------------------------


@interface GNETableViewDataSource ()


@property (nonatomic, weak) GNESectionedTableView *tableView;

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSMutableArray *rows;

@property (nonatomic, strong) NSTimer *insertionTimer;
@property (nonatomic, strong) NSTimer *deletionTimer;
@property (nonatomic, strong) NSTimer *moveTimer;


@end


// ------------------------------------------------------------------------------------------


@implementation GNETableViewDataSource


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
- (instancetype)init
{
    if ((self = [super init]))
    {
        [self p_buildAndConfigureSectionsAndRows];
        [self p_buildAndConfigureTimers];
    }
    
    return self;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Public - Table View
// ------------------------------------------------------------------------------------------
- (void)setTableView:(GNESectionedTableView *)tableView
{
    _tableView = tableView;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Private - Sections and Rows
// ------------------------------------------------------------------------------------------
- (void)p_buildAndConfigureSectionsAndRows
{
    NSUInteger sectionCount = arc4random_uniform(10);
    sectionCount = 10;
    
    self.sections = [NSMutableArray arrayWithCapacity:sectionCount];
    self.rows = [NSMutableArray arrayWithCapacity:sectionCount];
    
    for (NSUInteger section = 0; section < sectionCount; section++)
    {
        [self.sections addObject:[NSString stringWithFormat:@"%lu", section]];
        
//        NSUInteger rowCount = arc4random_uniform(10);
//        rowCount = 10;
        NSMutableArray *rowsArray = [NSMutableArray array];
//        for (NSUInteger row = 0; row < rowCount; row++)
//        {
//            [rowsArray addObject:[NSString stringWithFormat:@"%lu", row]];
//        }
        
        [self.rows addObject:rowsArray];
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - Private - Timers
// ------------------------------------------------------------------------------------------
- (void)p_buildAndConfigureTimers
{
    self.insertionTimer = [NSTimer timerWithTimeInterval:3
                                                  target:self
                                                selector:@selector(p_insertRandomSectionsOrRows)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.insertionTimer forMode:NSDefaultRunLoopMode];
}


- (void)p_insertRandomSectionsOrRows
{
    BOOL insertRows = (BOOL)arc4random_uniform(2);
    if (insertRows)
    {
        [self p_insertRandomRows];
    }
    else
    {
        [self p_insertRandomSections];
    }
}


- (void)p_insertRandomSections
{
    
}


- (void)p_insertRandomRows
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    NSUInteger sectionCount = [self.sections count];
    
    NSUInteger iterations = arc4random_uniform(3);
    iterations = MAX((NSUInteger)1, iterations);
    
    for (NSUInteger i = 0; i < iterations; i++)
    {
        NSUInteger section = arc4random_uniform((uint32_t)sectionCount);
        NSUInteger rowCount = [self.rows[section] count];
        
        NSUInteger insertionIndex = arc4random_uniform((uint32_t)rowCount);
        NSUInteger insertionCount = arc4random_uniform(5);
        
        for (NSUInteger insertion = 0; insertion < insertionCount; insertion++)
        {
            NSIndexPath *indexPath = [NSIndexPath gne_indexPathForRow:(insertionIndex + insertion) inSection:section];
            [indexPaths addObject:indexPath];
        }
    }
    
    GNESectionedTableView *tableView = self.tableView;
    [tableView insertRowsAtIndexPaths:indexPaths withAnimation:NSTableViewAnimationEffectFade];
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableViewDataSource
// ------------------------------------------------------------------------------------------
- (NSUInteger)numberOfSectionsInTableView:(GNESectionedTableView * __unused)tableView
{
    return [self.sections count];
}


- (NSUInteger)tableView:(GNESectionedTableView * __unused)tableView numberOfRowsInSection:(NSUInteger)section
{
    return [self.rows[section] count];
}


- (NSTableRowView *)tableView:(GNESectionedTableView *)tableView
     rowViewForRowAtIndexPath:(NSIndexPath * __unused)indexPath
{
    NSTableRowView *rowView = [tableView makeViewWithIdentifier:kRowViewIdentifier owner:tableView];
    
    if (rowView == nil)
    {
        rowView = [[NSTableRowView alloc] initWithFrame:CGRectZero];
        [rowView setAutoresizingMask:NSViewWidthSizable];
        rowView.identifier = kRowViewIdentifier;
        rowView.backgroundColor = [NSColor blueColor];
    }
    
    return rowView;
}


- (NSTableCellView *)tableView:(GNESectionedTableView *)tableView
     cellViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GNETableCellView *cellView = [tableView makeViewWithIdentifier:kCellViewIdentifier owner:tableView];
    
    if (cellView == nil)
    {
        cellView = [[GNETableCellView alloc] initWithFrame:CGRectZero];
        [cellView setAutoresizingMask:NSViewWidthSizable];
        cellView.identifier = kCellViewIdentifier;
    }
    
    cellView.title = [NSString stringWithFormat:@"%lu, %lu", indexPath.gne_section, indexPath.gne_row];
    
    return cellView;
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableViewDelegate
// ------------------------------------------------------------------------------------------
-       (CGFloat)tableView:(GNESectionedTableView * __unused)tableView
   heightForRowAtIndexPath:(NSIndexPath * __unused)indexPath
{
    return 40.0f;
}


-       (CGFloat)tableView:(GNESectionedTableView * __unused)tableView
  heightForHeaderInSection:(NSUInteger)section
{
    if (section == 0)
    {
        return 0.0f;
    }
    
    return 22.0f;
}


- (NSTableRowView *)tableView:(GNESectionedTableView *)tableView
    rowViewForHeaderInSection:(NSUInteger __unused)section
{
    if (section == 0)
    {
        return nil;
    }
    
    NSTableRowView *rowView = [tableView makeViewWithIdentifier:kHeaderRowViewIdentifier owner:tableView];
    
    if (rowView == nil)
    {
        rowView = [[NSTableRowView alloc] initWithFrame:CGRectZero];
        [rowView setAutoresizingMask:NSViewWidthSizable];
        rowView.identifier = kHeaderRowViewIdentifier;
        rowView.backgroundColor = [NSColor greenColor];
    }
    
    return rowView;
}


- (NSTableCellView *)tableView:(GNESectionedTableView *)tableView
    cellViewForHeaderInSection:(NSUInteger)section
{
    if (section == 0)
    {
        return nil;
    }
    
    GNEHeaderCellView *cellView = [tableView makeViewWithIdentifier:kHeaderCellViewIdentifier owner:tableView];
    
    if (cellView == nil)
    {
        cellView = [[GNEHeaderCellView alloc] initWithFrame:CGRectZero];
        [cellView setAutoresizingMask:NSViewWidthSizable];
        cellView.identifier = kHeaderCellViewIdentifier;
    }
    
    cellView.title = [NSString stringWithFormat:@"Section %lu", section];
    
    return cellView;
}


- (BOOL)tableView:(GNESectionedTableView * __unused)tableView shouldSelectRowAtIndexPath:(NSIndexPath * __unused)indexPath
{
    return YES;
}


@end
