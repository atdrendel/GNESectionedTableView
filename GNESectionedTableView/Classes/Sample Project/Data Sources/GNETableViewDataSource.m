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

@property (nonatomic, strong) NSTimer *updateTimer;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;


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
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
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
#pragma mark - Public - Debugging
// ------------------------------------------------------------------------------------------
#ifdef DEBUG
- (NSUInteger)numberOfSections
{
    NSParameterAssert([self.sections count] == [self.rows count]);
    
    return [self.sections count];
}


- (NSUInteger)numberOfRows
{
    NSParameterAssert([self.sections count] == [self.rows count]);
    
    NSUInteger numberOfRows = 0;
    
    NSUInteger sectionCount = [self.rows count];
    for (NSUInteger section = 0; section < sectionCount; section++)
    {
        numberOfRows += [self.rows[section] count];
    }
    
    return numberOfRows;
}
#endif


// ------------------------------------------------------------------------------------------
#pragma mark - Private - Sections and Rows
// ------------------------------------------------------------------------------------------
- (void)p_buildAndConfigureSectionsAndRows
{
    NSUInteger sectionCount = arc4random_uniform(10);
    
    self.sections = [NSMutableArray arrayWithCapacity:sectionCount];
    self.rows = [NSMutableArray arrayWithCapacity:sectionCount];
    
//    for (NSUInteger section = 0; section < sectionCount; section++)
//    {
//        [self.sections addObject:[self p_stringForSection:section]];
//        
//        NSUInteger rowCount = arc4random_uniform(10);
//        rowCount = 10;
//        NSMutableArray *rowsArray = [NSMutableArray array];
//        for (NSUInteger row = 0; row < rowCount; row++)
//        {
//            NSIndexPath *indexPath = [NSIndexPath gne_indexPathForRow:row inSection:section];
//            [rowsArray addObject:[self p_stringForRowAtIndexPath:indexPath]];
//        }
//        
//        [self.rows addObject:rowsArray];
//    }
}


- (NSString *)p_stringForSection:(NSUInteger)section
{
    NSString *dateString = [self.dateFormatter stringFromDate:[NSDate date]];
    NSString *string = [NSString stringWithFormat:@"Section %lu at %@", section, dateString];
    
    return string;
}


- (NSString *)p_stringForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *dateString = [self.dateFormatter stringFromDate:[NSDate date]];
    NSString *string = [NSString stringWithFormat:@"%lu, %lu at %@",
                        indexPath.gne_section,
                        indexPath.gne_row, dateString];
    
    return string;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Private - Timers
// ------------------------------------------------------------------------------------------
- (void)p_buildAndConfigureTimers
{
    self.updateTimer = [NSTimer timerWithTimeInterval:3
                                               target:self
                                             selector:@selector(p_performRandomUpdates)
                                             userInfo:nil
                                              repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.updateTimer forMode:NSDefaultRunLoopMode];
}


- (void)p_performRandomUpdates
{
    if ([self.sections count] == 0)
    {
        [self p_insertRandomSections];
        return;
    }
    
    // TODO: Support moves
    NSUInteger operation = arc4random_uniform(2);
    
    switch (operation)
    {
        case 0:
        {
            [self p_performRandomInsertions];
            break;
        }
        case 1:
        {
            [self p_performRandomDeletions];
            break;
        }
        case 2:
        {
            [self p_performRandomMoves];
            break;
        }
    }
}


- (void)p_performRandomInsertions
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
    NSMutableArray *sectionsCopy = [NSMutableArray arrayWithArray:self.sections];
    NSMutableArray *rowsCopy = [NSMutableArray arrayWithArray:self.rows];
    
    NSParameterAssert([sectionsCopy count] == [rowsCopy count]);
    
    NSUInteger sectionCount = [sectionsCopy count];
    
    NSUInteger sectionInsertionCount = arc4random_uniform(4);
    sectionInsertionCount = MAX((NSUInteger)1, sectionInsertionCount);
    
    NSIndexSet *insertedSections = [self p_indexSetOfRandomIndexesForInsertionInRange:NSMakeRange(0, sectionCount)
                                                                                count:sectionInsertionCount];
    [insertedSections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop __unused)
    {
        NSUInteger rowInsertionCount = arc4random_uniform(5);

        NSUInteger actualIndex = [sectionsCopy gne_insertObject:[self p_stringForSection:section] atIndex:section];

        NSParameterAssert(actualIndex == section);

        NSMutableArray *rows = [NSMutableArray arrayWithCapacity:rowInsertionCount];
        actualIndex = [rowsCopy gne_insertObject:rows atIndex:section];

        NSParameterAssert(actualIndex == section);

        for (NSUInteger row = 0; row < rowInsertionCount; row++)
        {
            NSIndexPath *indexPath = [NSIndexPath gne_indexPathForRow:row inSection:section];
            [rows addObject:[self p_stringForRowAtIndexPath:indexPath]];
        }
    }];
    
    NSParameterAssert([insertedSections count] == sectionInsertionCount);
    
    self.sections = sectionsCopy;
    self.rows = rowsCopy;
    
    GNESectionedTableView *tableView = self.tableView;
    [tableView insertSections:insertedSections withAnimation:NSTableViewAnimationEffectFade];
}


- (void)p_insertRandomRows
{
    NSMutableArray *sectionsCopy = [NSMutableArray arrayWithArray:self.sections];
    NSMutableArray *rowsCopy = [NSMutableArray arrayWithArray:self.rows];
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    NSUInteger sectionCount = [sectionsCopy count];
    
    if (sectionCount == 0)
    {
        return;
    }
    
    NSUInteger iterations = arc4random_uniform(3);
    iterations = MAX((NSUInteger)1, iterations);
    
    for (NSUInteger i = 0; i < iterations; i++)
    {
        NSUInteger section = arc4random_uniform((uint32_t)sectionCount);
        NSMutableArray *rows = rowsCopy[section];
        NSUInteger rowCount = [rows count];
        
        NSUInteger insertionIndex = arc4random_uniform((uint32_t)rowCount);
        NSUInteger insertionCount = arc4random_uniform(5);
        
        for (NSUInteger insertion = 0; insertion < insertionCount; insertion++)
        {
            NSIndexPath *indexPath = [NSIndexPath gne_indexPathForRow:(insertionIndex + insertion) inSection:section];
            [indexPaths addObject:indexPath];
            
            [rows gne_insertObject:[self p_stringForRowAtIndexPath:indexPath]
                           atIndex:indexPath.gne_row];
        }
    }
    
    self.sections = sectionsCopy;
    self.rows = rowsCopy;
    
    GNESectionedTableView *tableView = self.tableView;
    [tableView insertRowsAtIndexPaths:indexPaths withAnimation:NSTableViewAnimationEffectFade];
}


- (void)p_performRandomDeletions
{
    BOOL deleteRows = (BOOL)arc4random_uniform(2);
    if (deleteRows)
    {
        [self p_deleteRandomRows];
    }
    else
    {
        [self p_deleteRandomSections];
    }
}


- (void)p_deleteRandomSections
{
    NSMutableArray *sectionsCopy = [NSMutableArray arrayWithArray:self.sections];
    NSMutableArray *rowsCopy = [NSMutableArray arrayWithArray:self.rows];
    
    NSUInteger sectionCount = [sectionsCopy count];
    
    if (sectionCount == 0)
    {
        return;
    }
    
    NSUInteger deletionCount = arc4random_uniform((uint32_t)sectionCount);
    NSIndexSet *sectionIndexSet = [self p_indexSetOfRandomIndexesForDeletionInRange:NSMakeRange(0, sectionCount)
                                                                              count:deletionCount];
    
    [sectionIndexSet enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger section,
                                                                                   BOOL *stop __unused)
    {
        [sectionsCopy removeObjectAtIndex:section];
        [rowsCopy removeObjectAtIndex:section];
    }];
    
    self.sections = sectionsCopy;
    self.rows = rowsCopy;
    
    GNESectionedTableView *tableView = self.tableView;
    [tableView deleteSections:sectionIndexSet withAnimation:NSTableViewAnimationEffectFade];
}


- (void)p_deleteRandomRows
{
    NSMutableArray *sectionsCopy = [NSMutableArray arrayWithArray:self.sections];
    NSMutableArray *rowsCopy = [NSMutableArray arrayWithArray:self.rows];
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    NSUInteger sectionCount = [sectionsCopy count];
    
    if (sectionCount == 0)
    {
        return;
    }
    
    NSUInteger sourceSectionCount = arc4random_uniform((uint32_t)sectionCount);
    NSIndexSet *sectionIndexSet = [self p_indexSetOfRandomIndexesForDeletionInRange:NSMakeRange(0, sectionCount)
                                                                       count:sourceSectionCount];
    
    [sectionIndexSet enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stopOuter __unused)
    {
        NSUInteger rowCount = [rowsCopy[section] count];
        NSUInteger deletionCount = arc4random_uniform((uint32_t)rowCount);
        
        NSIndexSet *rowIndexes = [self p_indexSetOfRandomIndexesForDeletionInRange:NSMakeRange(0, rowCount)
                                                                             count:deletionCount];
        [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger row, BOOL *stopInner __unused)
        {
            [indexPaths addObject:[NSIndexPath gne_indexPathForRow:row inSection:section]];
        }];
    }];
    
    // Sort the index paths according to section and then row.
    SEL compareSelector = NSSelectorFromString(@"gne_compare:");
    [indexPaths sortUsingSelector:compareSelector];
    
    // Remove chosen index paths from data source.
    NSEnumerator *enumerator = [indexPaths reverseObjectEnumerator];
    NSIndexPath *indexPath = nil;
    while (indexPath = [enumerator nextObject])
    {
        [rowsCopy[indexPath.gne_section] removeObjectAtIndex:indexPath.gne_row];
    }
    
    self.sections = sectionsCopy;
    self.rows = rowsCopy;
    
    GNESectionedTableView *tableView = self.tableView;
    [tableView deleteRowsAtIndexPaths:indexPaths withAnimation:NSTableViewAnimationEffectFade];
}


- (void)p_performRandomMoves
{
    
}


- (NSIndexSet *)p_indexSetOfRandomIndexesForInsertionInRange:(NSRange)range
                                           count:(NSUInteger)count
{
    if (range.length == 0)
    {
        range.length = 1; // Otherwise it would be impossible to add indexes.
    }
    
    NSMutableIndexSet *mutableIndexSet = [NSMutableIndexSet indexSet];
    while ([mutableIndexSet count] < count)
    {
        NSUInteger index = arc4random_uniform((uint32_t)(range.length - range.location)) + range.location;
        if ([mutableIndexSet containsIndex:index] == NO)
        {
            [mutableIndexSet addIndex:index];
            range.length += 1;
        }
    }
    
    return mutableIndexSet;
}


- (NSIndexSet *)p_indexSetOfRandomIndexesForDeletionInRange:(NSRange)range
                                                       count:(NSUInteger)count
{
    NSParameterAssert(range.length >= count);
    
    NSMutableIndexSet *mutableIndexSet = [NSMutableIndexSet indexSet];
    while ([mutableIndexSet count] < count)
    {
        NSUInteger index = arc4random_uniform((uint32_t)(range.length - range.location));
        if ([mutableIndexSet containsIndex:index] == NO)
        {
            [mutableIndexSet addIndex:index];
        }
    }
    
    return mutableIndexSet;
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
    
    if (indexPath.gne_section < [self.rows count] && indexPath.gne_row < [self.rows[indexPath.gne_section] count])
    {
        cellView.title = [self.rows[indexPath.gne_section] objectAtIndex:indexPath.gne_row];
    }
    else
    {
        cellView.title = @"";
    }
    
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
  heightForHeaderInSection:(NSUInteger __unused)section
{
    return 22.0f;
}


- (NSTableRowView *)tableView:(GNESectionedTableView *)tableView
    rowViewForHeaderInSection:(NSUInteger __unused)section
{
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
    GNEHeaderCellView *cellView = [tableView makeViewWithIdentifier:kHeaderCellViewIdentifier owner:tableView];
    
    if (cellView == nil)
    {
        cellView = [[GNEHeaderCellView alloc] initWithFrame:CGRectZero];
        [cellView setAutoresizingMask:NSViewWidthSizable];
        cellView.identifier = kHeaderCellViewIdentifier;
    }
    
    cellView.title = self.sections[section];
    
    return cellView;
}


- (BOOL)tableView:(GNESectionedTableView * __unused)tableView shouldSelectRowAtIndexPath:(NSIndexPath * __unused)indexPath
{
    return YES;
}


@end
