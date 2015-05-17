//
//  NSIndexPath+GNESectionedTableView.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 5/27/14.
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


@interface NSIndexPath (GNESectionedTableView)


@property (nonatomic, assign, readonly) NSUInteger gne_section; // Index at position 1.
@property (nonatomic, assign, readonly) NSUInteger gne_row; // Index at position 0.


/**
 Creates an index path with indexes { row, section }.
 
 @param row Index path row (index at position 0)
 @param section Index path section (index at position 1)
 @return An instance of NSIndexPath with indexes { row, section }
 */
+ (nonnull instancetype)gne_indexPathForRow:(NSUInteger)row inSection:(NSUInteger)section;


/**
 Returns an array of index paths corresponding to the specified indexes in the specified section.
 
 @discussion The count of the returned array will equal the count of the indexes contained
 in the specified index set. If the specified index set contains 1, 2, and 3, and the specified 
 section is 4, the returned array will equal: [{1,4}, {2,4}, {3,4}].
 @param indexSet Index set containing the row indexes to create.
 @param section Section index to apply to all of the created index paths.
 @return An array containing the index paths corresponding to the specified indexes and section.
 */
+ (NSArray * __nonnull)gne_indexPathsForIndexes:(NSIndexSet * __nonnull)indexSet inSection:(NSUInteger)section;


/**
 Compares two index paths first by their sections and then, if the sections differ, by their rows.
 
 @param indexPath Index path to compare against the receiver.
 @return The ordering of the receiving index path and indexPath.
 NSOrderedAscending: The receiving index path comes before indexPath.
 NSOrderedDescending: The receiving index path comes after indexPath.
 NSOrderedSame: The receiving index path and indexPath are the same index path.
 */
- (NSComparisonResult)gne_compare:(NSIndexPath * __nonnull)indexPath;


/**
 Compares two index paths first by their sections and then, if the sections differ, by their rows.
 
 @param indexPath Index path to compare against the receiver.
 @return The ordering of the receiving index path and indexPath.
 NSOrderedAscending: The receiving index path comes after indexPath.
 NSOrderedDescending: The receiving index path comes before indexPath.
 NSOrderedSame: The receiving index path and indexPath are the same index path.
 */
- (NSComparisonResult)gne_reverseCompare:(NSIndexPath * __nonnull)indexPath;


@end
