//
//  NSIndexPath+GNESectionedTableView.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 5/27/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

@interface NSIndexPath (GNESectionedTableView)


/**
 Creates an index path with indexes { row, section }.
 
 @param row Index path row (index at position 0)
 @param section Index path section (index at position 1)
 @return An instance of NSIndexPath with indexes { row, section }
 */
+ (instancetype)gne_indexPathForRow:(NSUInteger)row inSection:(NSUInteger)section;


/**
 Compares two index paths first by their sections and then, if the sections differ, by their rows.
 
 @param indexPath Index path to compare against the receiver.
 @return The ordering of the receiving index path and indexPath.
            NSOrderedAscending: The receiving index path comes before indexPath.
            NSOrderedDescending: The receiving index path comes after indexPath.
            NSOrderedSame: The receiving index path and indexPath are the same index path.
 */
- (NSComparisonResult)gne_compare:(NSIndexPath *)indexPath;


/**
 Returns the row of the index path (index at position 0). Throws an exception if the index path
    does not contain exactly two indexes.
 
 @return Index path row (index at position 0)
 */
- (NSUInteger)gne_row;


/**
 Returns the section of the index path (index at position 1). Throws an exception if the index path
    does not contain exactly two indexes.
 
 @return Index path section (index at position 1)
 */
- (NSUInteger)gne_section;


@end
