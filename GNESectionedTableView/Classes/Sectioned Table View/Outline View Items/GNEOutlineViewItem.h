//
//  GNEOutlineViewItem.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 8/9/15.
//  Copyright © 2015 Gone East LLC. All rights reserved.
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
@class GNESectionedTableView;
@protocol GNESectionedTableViewDataSource;
@protocol GNESectionedTableViewDelegate;

// ------------------------------------------------------------------------------------------

extern NSString  * _Nonnull  const GNEOutlineViewItemPasteboardType;

typedef NS_ENUM(NSUInteger, GNEOutlineViewItemType)
{
    GNEOutlineViewItemTypeUnknown = 0,
    GNEOutlineViewItemTypeSection,
    GNEOutlineViewItemTypeRow
};

typedef void(^GNECompletionBlock)();

// ------------------------------------------------------------------------------------------

@interface GNEOutlineViewItem : NSObject <NSSecureCoding, NSPasteboardReading, NSPasteboardWriting>

@property (nonatomic, weak) GNESectionedTableView *tableView;
@property (nonatomic, weak) id<GNESectionedTableViewDataSource> tableViewDataSource;
@property (nonatomic, weak) id<GNESectionedTableViewDelegate> tableViewDelegate;

@property (nonatomic, assign, readonly) GNEOutlineViewItemType type;
@property (nonatomic, assign, readonly) BOOL isSection;
@property (nonatomic, assign, readonly) BOOL isRow;

@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign, readonly) CGFloat height;
@property (nonnull, nonatomic, strong, readonly) NSTableRowView *rowView;
@property (nullable, nonatomic, strong, readonly) NSTableCellView *cellView;

- (nonnull instancetype)initWithTableView:(GNESectionedTableView * _Nonnull)tableView
                               dataSource:(id<GNESectionedTableViewDataSource> _Nonnull)dataSource
                                 delegate:(id<GNESectionedTableViewDelegate> _Nonnull)delegate NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end
