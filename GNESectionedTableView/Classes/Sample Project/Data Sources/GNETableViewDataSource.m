//
//  GNETableViewDataSource.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 6/9/14.
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

#import "GNETableViewDataSource.h"
#import "GNETableCellView.h"
#import "GNETableRowView.h"
#import "GNEHeaderCellView.h"


// ------------------------------------------------------------------------------------------


static NSString * const kRowViewIdentifier = @"com.goneeast.RowViewIdentifier";
static NSString * const kCellViewIdentifier = @"com.goneeast.CellViewIdentifier";

static NSString * const kHeaderRowViewIdentifier = @"com.goneeast.HeaderRowViewIdentifier";
static NSString * const kHeaderCellViewIdentifier = @"com.goneeast.HeaderCellViewIdentifier";

static NSString * const kFooterRowViewIdentifier = @"com.goneeast.FooterRowViewIdentifer";
static NSString * const kFooterCellViewIdentifier = @"com.goneeast.FooterCellViewIdentifer";


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
    
    [tableView reloadData];
    [tableView expandAllSections:NO];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Public - Debugging
// ------------------------------------------------------------------------------------------
#if DEBUG
- (NSUInteger)numberOfSections
{
    NSParameterAssert(self.sections.count == self.rows.count);
    
    return self.sections.count;
}


- (NSUInteger)numberOfRows
{
    NSParameterAssert(self.sections.count == self.rows.count);
    
    NSUInteger numberOfRows = 0;
    
    NSUInteger sectionCount = self.rows.count;
    for (NSUInteger section = 0; section < sectionCount; section++)
    {
        numberOfRows += ((NSArray *)self.rows[section]).count;
    }
    
    return numberOfRows;
}


- (NSUInteger)numberOfFooters
{
    NSUInteger numberOfFooters = 0;
    
    SEL heightSelector = @selector(tableView:heightForFooterInSection:);
    SEL rowViewSelector = @selector(tableView:rowViewForFooterInSection:);
    SEL cellViewSelector = @selector(tableView:cellViewForFooterInSection:);
    
    if ([self respondsToSelector:heightSelector] == NO ||
        [self respondsToSelector:rowViewSelector] == NO ||
        [self respondsToSelector:cellViewSelector] == NO)
    {
        return numberOfFooters;
    }
    
    NSUInteger sectionCount = self.sections.count;
    for (NSUInteger section = 0; section < sectionCount; section++)
    {
        CGFloat footerHeight = [self tableView:self.tableView
                      heightForFooterInSection:section];
        numberOfFooters += (footerHeight > GNESectionedTableViewInvisibleRowHeight) ? 1 : 0;
    }
    
    return numberOfFooters;
}
#endif


// ------------------------------------------------------------------------------------------
#pragma mark - Private - Sections and Rows
// ------------------------------------------------------------------------------------------
- (void)p_buildAndConfigureSectionsAndRows
{
    NSUInteger sectionCount = MAX((NSUInteger)arc4random_uniform(10), (NSUInteger)3);
    sectionCount = 5;
    
    self.sections = [NSMutableArray arrayWithCapacity:sectionCount];
    self.rows = [NSMutableArray arrayWithCapacity:sectionCount];
    
    for (NSUInteger section = 0; section < sectionCount; section++)
    {
        [self.sections addObject:[self p_stringForSection:section]];
        
        NSUInteger rowCount = arc4random_uniform(10);
        rowCount = 4;
        NSMutableArray *rowsArray = [NSMutableArray array];
        for (NSUInteger row = 0; row < rowCount; row++)
        {
            NSIndexPath *indexPath = [NSIndexPath gne_indexPathForRow:row inSection:section];
            [rowsArray addObject:[self p_stringForRowAtIndexPath:indexPath]];
        }
        
        [self.rows addObject:rowsArray];
    }
}


- (NSString *)p_stringForSection:(NSUInteger)section
{
    NSString *dateString = [self.dateFormatter stringFromDate:[NSDate date]];
    NSString *string = [NSString stringWithFormat:@"%lu at %@", section, dateString];
    
    return string;
}


- (NSString *)p_stringForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *dateString = [self.dateFormatter stringFromDate:[NSDate date]];
    NSString *string = [NSString stringWithFormat:@"{%lu, %lu} at %@",
                        indexPath.gne_section,
                        indexPath.gne_row, dateString];
    
    return string;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Private - Timers
// ------------------------------------------------------------------------------------------
- (void)p_buildAndConfigureTimers
{
    self.updateTimer = [NSTimer timerWithTimeInterval:15
                                               target:self
                                             selector:@selector(p_performRandomUpdates)
                                             userInfo:nil
                                              repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.updateTimer forMode:NSDefaultRunLoopMode];
}


- (void)p_performRandomUpdates
{
    return;
    
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


// ------------------------------------------------------------------------------------------
#pragma mark - Insertion
// ------------------------------------------------------------------------------------------
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


// ------------------------------------------------------------------------------------------
#pragma mark - Deletion
// ------------------------------------------------------------------------------------------
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
    
    [sectionIndexSet enumerateIndexesWithOptions:NSEnumerationReverse
                                      usingBlock:^(NSUInteger section,
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
#pragma mark - Moves
// ------------------------------------------------------------------------------------------
- (void)p_performRandomMoves
{
    
}


- (void)p_moveSections:(NSIndexSet *)fromSections toSection:(NSUInteger)toSection
{
    NSMutableArray *sections = [NSMutableArray array];
    NSMutableArray *rows = [NSMutableArray array];
    
    [fromSections enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger section,
                                                                                BOOL *stop __unused)
    {
        NSString *sectionString = self.sections[section];
        [sections insertObject:sectionString atIndex:0];
        [self.sections removeObjectAtIndex:section];

        NSArray *rowsArray = self.rows[section];
        [rows insertObject:rowsArray atIndex:0];
        [self.rows removeObjectAtIndex:section];
    }];
    
    NSRange sectionInsertionRange = NSMakeRange(toSection, sections.count);
    NSIndexSet *sectionInsertionIndexes = [NSIndexSet indexSetWithIndexesInRange:sectionInsertionRange];
    [self.sections insertObjects:sections atIndexes:sectionInsertionIndexes];
    
    NSRange rowInsertionRange = NSMakeRange(toSection, rows.count);
    NSIndexSet *rowInsertionIndexes = [NSIndexSet indexSetWithIndexesInRange:rowInsertionRange];
    [self.rows insertObjects:rows atIndexes:rowInsertionIndexes];
    
    GNEOrderedIndexSet *orderedFromSections = [GNEOrderedIndexSet indexSetWithNSIndexSet:fromSections];
    
    [self.tableView moveSections:orderedFromSections toSection:toSection];
}


- (void)p_moveRowsAtIndexPaths:(NSArray *)fromIndexPaths toSection:(NSUInteger)toSection
{
    NSIndexPath *toIndexPath = [NSIndexPath gne_indexPathForRow:0 inSection:toSection];
    [self p_moveRowsAtIndexPaths:fromIndexPaths toIndexPath:toIndexPath];
}


- (void)p_moveRowsAtIndexPaths:(NSArray *)fromIndexPaths toIndexPath:(NSIndexPath *)toIndexPath
{
    NSMutableArray *movedRows = [NSMutableArray array];
    __block NSUInteger toRow = toIndexPath.gne_row;
    
    SEL sortingSelector = NSSelectorFromString(@"gne_reverseCompare:");
    NSArray *sortedFromIndexPaths = [fromIndexPaths sortedArrayUsingSelector:sortingSelector];
    
    [sortedFromIndexPaths enumerateObjectsWithOptions:0
                                           usingBlock:^(NSIndexPath *indexPath,
                                                        NSUInteger idx __unused,
                                                        BOOL *stop __unused)
    {
        NSParameterAssert(indexPath.gne_section < self.rows.count);
        NSMutableArray *mutableRowsArray = self.rows[indexPath.gne_section];
        NSParameterAssert(indexPath.gne_row < mutableRowsArray.count);
        NSString *rowString = mutableRowsArray[indexPath.gne_row];
        [movedRows gne_insertObject:rowString atIndex:0];
        [mutableRowsArray removeObjectAtIndex:indexPath.gne_row];
        if (indexPath.gne_section == toIndexPath.gne_section
            && indexPath.gne_row < toIndexPath.gne_row)
        {
            toRow -= 1; // Account for the row that was just removed.
        }
    }];
    
    if (movedRows.count > 0)
    {
        NSParameterAssert(self.rows.count > toIndexPath.gne_section);
        NSMutableArray *toRowsArray = self.rows[toIndexPath.gne_section];
        NSParameterAssert(toRowsArray.count >= toRow);
        NSRange insertionRange = NSMakeRange(toRow, movedRows.count);
        NSIndexSet *insertionIndexSet = [NSIndexSet indexSetWithIndexesInRange:insertionRange];
        [toRowsArray insertObjects:movedRows atIndexes:insertionIndexSet];
        [self.tableView moveRowsAtIndexPaths:fromIndexPaths
                                 toIndexPath:[NSIndexPath gne_indexPathForRow:toRow
                                                                    inSection:toIndexPath.gne_section]];
    }
}


// ------------------------------------------------------------------------------------------
#pragma mark - GNESectionedTableViewDataSource
// ------------------------------------------------------------------------------------------
- (NSUInteger)numberOfSectionsInTableView:(GNESectionedTableView * __unused)tableView
{
    return self.sections.count;
}


- (NSUInteger)tableView:(GNESectionedTableView * __unused)tableView numberOfRowsInSection:(NSUInteger)section
{
    return ((NSArray *)self.rows[section]).count;
}


- (NSTableRowView *)tableView:(GNESectionedTableView *)tableView
     rowViewForRowAtIndexPath:(NSIndexPath * __unused)indexPath
{
    GNETableRowView *rowView = [tableView makeViewWithIdentifier:kRowViewIdentifier owner:self];
    
    if (rowView == nil)
    {
        rowView = [[GNETableRowView alloc] initWithFrame:CGRectZero];
        rowView.autoresizingMask = NSViewWidthSizable;
        rowView.identifier = kRowViewIdentifier;
        rowView.backgroundColor = [NSColor blueColor];
    }
    
    return rowView;
}


- (NSTableCellView *)tableView:(GNESectionedTableView *)tableView
     cellViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GNETableCellView *cellView = [tableView makeViewWithIdentifier:kCellViewIdentifier owner:self];
    
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
    
    cellView.layer.backgroundColor = [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:0.2].CGColor;
    
    return cellView;
}


- (void)tableView:(GNESectionedTableView * __unused)tableView didUpdateDrag:(id<NSDraggingInfo>)info
{
    NSLog(@"%@", info);
}


- (BOOL)tableView:(GNESectionedTableView * __unused)tableView
   canDragSection:(NSUInteger __unused)section
{
    return YES;
}



-       (BOOL)tableView:(GNESectionedTableView * __unused)tableView
  canDragRowAtIndexPath:(NSIndexPath * __unused)indexPath
{
    return YES;
}


-       (BOOL)tableView:(GNESectionedTableView * __unused)tableView
  canDropRowAtIndexPath:(NSIndexPath * __unused)fromIndexPath
      onHeaderInSection:(NSUInteger __unused)section
{
    return YES;
}


-       (BOOL)tableView:(GNESectionedTableView * __unused)tableView
  canDropRowAtIndexPath:(NSIndexPath * __unused)fromIndexPath
       onRowAtIndexPath:(NSIndexPath * __unused)toIndexPath
{
    return NO;
}


- (BOOL)tableView:(GNESectionedTableView * __unused)tableView
   canDragSection:(NSUInteger)fromSection
        toSection:(NSUInteger)toSection
{
    return (fromSection != toSection);
}


-       (BOOL)tableView:(GNESectionedTableView * __unused)tableView
  canDragRowAtIndexPath:(NSIndexPath *)fromIndexPath
            toIndexPath:(NSIndexPath *)toIndexPath
{
    NSLog(@"canDragRowAtIndexPath: (%lu, %lu) toIndexPath: (%lu, %lu)", fromIndexPath.gne_section, fromIndexPath.gne_row, toIndexPath.gne_section, toIndexPath.gne_row);
    
    return YES;
}


-       (void)tableView:(GNESectionedTableView * __unused)tableView
didDropRowsAtIndexPaths:(NSArray *)fromIndexPaths
      onHeaderInSection:(NSUInteger)section
{
    NSLog(@"didDropRowsAtIndexPaths: %@ onHeaderInSection: %lu", fromIndexPaths, (unsigned long)section);
}


-       (void)tableView:(GNESectionedTableView * __unused)tableView
didDropRowsAtIndexPaths:(NSArray *)fromIndexPaths
       onRowAtIndexPath:(NSIndexPath *)toIndexPath
{
    NSLog(@"didDropRowsAtIndexPaths: %@ onRowAtIndexPath: %@", fromIndexPaths, toIndexPath);
}


-       (void)tableView:(GNESectionedTableView * __unused)tableView
        didDragSections:(NSIndexSet *)fromSections
              toSection:(NSUInteger)toSection
{
    NSLog(@"didDragSections: %@ toSection: %lu", fromSections, toSection);
    
    NSRange belowTargetRange = NSMakeRange(0, toSection);
    NSUInteger sectionsBelowTarget = [fromSections countOfIndexesInRange:belowTargetRange];
    toSection -= sectionsBelowTarget;
    
    [self p_moveSections:fromSections toSection:toSection];
}


-       (void)tableView:(GNESectionedTableView * __unused)tableView
didDragRowsAtIndexPaths:(NSArray *)fromIndexPaths
            toIndexPath:(NSIndexPath *)toIndexPath
{
    NSLog(@"didDragRowsAtIndexPaths: %@ toIndexPath: %@", fromIndexPaths, toIndexPath);
    
    [self p_moveRowsAtIndexPaths:fromIndexPaths toIndexPath:toIndexPath];
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
    
    NSArray *rowsArray = self.rows[section];
    
    return ((rowsArray.count > 0) ? 22.0f : GNESectionedTableViewInvisibleRowHeight);
}


-       (CGFloat)tableView:(GNESectionedTableView * __unused)tableView
  heightForFooterInSection:(NSUInteger __unused)section
{
    NSArray *rowsArray = self.rows[section];
    
    return ((rowsArray.count > 0) ? 22.0f : GNESectionedTableViewInvisibleRowHeight);
}


- (NSTableRowView *)tableView:(GNESectionedTableView *)tableView
    rowViewForHeaderInSection:(NSUInteger __unused)section
{
    GNETableRowView *rowView = [tableView makeViewWithIdentifier:kHeaderRowViewIdentifier owner:self];
    
    if (rowView == nil)
    {
        rowView = [[GNETableRowView alloc] initWithFrame:CGRectZero];
        rowView.autoresizingMask = NSViewWidthSizable;
        rowView.identifier = kHeaderRowViewIdentifier;
        rowView.backgroundColor = [NSColor greenColor];
        rowView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleRegular;
    }
    
    return rowView;
}


- (NSTableRowView *)tableView:(GNESectionedTableView *)tableView
    rowViewForFooterInSection:(NSUInteger __unused)section
{
    GNETableRowView *rowView = [tableView makeViewWithIdentifier:kFooterRowViewIdentifier owner:self];
    
    if (rowView == nil)
    {
        rowView = [[GNETableRowView alloc] initWithFrame:CGRectZero];
        rowView.autoresizingMask = NSViewWidthSizable;
        rowView.identifier = kFooterRowViewIdentifier;
        rowView.backgroundColor = [NSColor blueColor];
    }
    
    return rowView;
}


- (NSTableCellView *)tableView:(GNESectionedTableView *)tableView
    cellViewForHeaderInSection:(NSUInteger)section
{
    GNEHeaderCellView *cellView = [tableView makeViewWithIdentifier:kHeaderCellViewIdentifier owner:self];
    
    if (cellView == nil)
    {
        cellView = [[GNEHeaderCellView alloc] initWithFrame:CGRectZero];
        cellView.autoresizingMask = NSViewWidthSizable;
        cellView.identifier = kHeaderCellViewIdentifier;
    }
    
    cellView.layer.backgroundColor = [NSColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:0.2].CGColor;
    cellView.title = [NSString stringWithFormat:@"Header %@", self.sections[section]];
    
    return cellView;
}


- (NSTableCellView *)tableView:(GNESectionedTableView *)tableView cellViewForFooterInSection:(NSUInteger)section
{
    NSArray *rowsArray = self.rows[section];
    if (rowsArray.count <= 1)
    {
        return nil;
    }
    
    GNEHeaderCellView *cellView = [tableView makeViewWithIdentifier:kFooterCellViewIdentifier owner:self];
    
    if (cellView == nil)
    {
        cellView = [[GNEHeaderCellView alloc] initWithFrame:CGRectZero];
        cellView.autoresizingMask = NSViewWidthSizable;
        cellView.identifier = kFooterCellViewIdentifier;
    }
    
    cellView.layer.backgroundColor = [NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:0.2].CGColor;
    cellView.title = [NSString stringWithFormat:@"Footer %@", self.sections[section]];
    
    return cellView;
}


- (void)tableView:(GNESectionedTableView * __unused)tableView
 didExpandSection:(NSUInteger)section
{
    NSLog(@"didExpandSection: %llu", (unsigned long long)section);
}


-   (void)tableView:(GNESectionedTableView * __unused)tableView
 didCollapseSection:(NSUInteger)section
{
    NSLog(@"didCollapseSection: %llu", (unsigned long long)section);
}


-           (BOOL)tableView:(GNESectionedTableView * __unused)tableView
shouldSelectHeaderInSection:(NSUInteger __unused)section
{
    return YES;
}


-           (BOOL)tableView:(GNESectionedTableView * __unused)tableView
 shouldSelectRowAtIndexPath:(NSIndexPath * __unused)indexPath
{
    return YES;
}


- (void)tableView:(GNESectionedTableView * __unused)tableView didClickHeaderInSection:(NSUInteger)section
{
    NSLog(@"didClickHeaderInSection: %lu", section);
//    
//    BOOL isExpanded = [tableView isSectionExpanded:section];
//    if (isExpanded)
//    {
//        [tableView collapseSection:section animated:YES];
//    }
//    else
//    {
//        [tableView expandSection:section animated:YES];
//    }
}


- (void)tableView:(GNESectionedTableView * __unused)tableView didClickFooterInSection:(NSUInteger)section
{
    NSLog(@"didClickFooterInSection: %lu", section);
}


- (void)tableView:(GNESectionedTableView * __unused)tableView didClickRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = ((NSArray *)self.rows[indexPath.gne_section])[indexPath.gne_row];
    
    NSLog(@"didClickRowAtIndexPath: %@ (%@)", indexPath, title);
}


- (void)tableView:(GNESectionedTableView *)tableView didDoubleClickHeaderInSection:(NSUInteger)section
{
    NSLog(@"didDoubleClickHeaderInSection: %lu", section);
    
    NSUInteger numberOfSections = tableView.numberOfSections;
    GNEOrderedIndexSet *indexSet = [GNEOrderedIndexSet indexSet];
    for (NSUInteger i = 0; i < numberOfSections; i++)
    {
        if (i != section && (i != (section + 1)))
        {
            [indexSet addIndex:i];
        }
    }
    
    NSUInteger position = (NSUInteger)arc4random_uniform((u_int32_t)(indexSet.count));
    NSUInteger toSection = [indexSet indexAtPosition:position];
    
    [self p_moveSections:[NSIndexSet indexSetWithIndex:section] toSection:toSection];
}


- (void)tableView:(GNESectionedTableView * __unused)tableView didDoubleClickFooterInSection:(NSUInteger)section
{
    NSLog(@"didDoubleClickFooterInSection: %lu", section);
}


- (void)tableView:(GNESectionedTableView * __unused)tableView didDoubleClickRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didDoubleClickRowAtIndexPath: %@", indexPath);
}


- (void)tableViewDidDeselectAllHeadersAndRows:(GNESectionedTableView * __unused)tableView
{
    NSLog(@"didDeselectAllHeadersAndRows:");
}


- (void)tableView:(GNESectionedTableView * __unused)tableView didSelectHeaderInSection:(NSUInteger)section
{
    NSLog(@"didSelectHeaderInSection: %lu", section);
}


- (void)tableView:(GNESectionedTableView * __unused)tableView didSelectHeadersInSections:(NSIndexSet *)sections
{
    NSLog(@"didSelectHeadersInSetions: %@", sections);
}


- (void)tableView:(GNESectionedTableView * __unused)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath: %@", indexPath);
}


- (void)tableView:(GNESectionedTableView * __unused)tableView didSelectRowsAtIndexPaths:(NSArray *)indexPaths
{
    NSLog(@"didSelectRowsAtIndexPaths: %@", indexPaths);
}


@end
