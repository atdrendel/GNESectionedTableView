//
//  GNESectionedTableViewMove.h
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

@class GNESectionedTableView, GNESectionedTableViewMovingItem, GNEOrderedIndexSet;


// ------------------------------------------------------------------------------------------

typedef void(^GNESectionedTableViewMoveCompletion)();

// ------------------------------------------------------------------------------------------


@interface GNESectionedTableViewMove : NSObject

@property (nonatomic, weak, readonly) GNESectionedTableView *tableView;
@property (nonatomic, copy, readonly) NSArray *movingItems;

@property (nonatomic, copy) NSArray *indexPathsToSelect;
@property (nonatomic, copy) NSIndexSet *sectionsToExpand;
@property (nonatomic, copy) NSIndexSet *autoCollapsedSections;

@property (nonatomic, copy) GNESectionedTableViewMoveCompletion completion;

/// Returns an instance of GNESectionedTableViewMove or one of its subclasses.
- (instancetype)initWithTableView:(GNESectionedTableView *)tableView NS_DESIGNATED_INITIALIZER;

- (void)addMovingItem:(GNESectionedTableViewMovingItem *)movingItem;

- (void)moveSections:(GNEOrderedIndexSet *)fromSections toSections:(GNEOrderedIndexSet *)toSections;

- (void)moveRowsAtIndexPaths:(NSArray *)fromIndexPaths toIndexPaths:(NSArray *)toIndexPaths;

@end
