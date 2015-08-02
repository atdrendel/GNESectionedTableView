//
//  GNESectionController.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 8/2/15.
//  Copyright © 2015 Gone East LLC. All rights reserved.
//

#import "GNESectionedTableView.h"

@interface GNESectionController : NSObject

@property (nonatomic, weak) id<GNESectionedTableViewDataSource> tableViewDataSource;
@property (nonatomic, weak) id<GNESectionedTableViewDelegate> tableViewDelegate;

- (nonnull instancetype)init NS_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithTableViewDataSource:(id<GNESectionedTableViewDataSource> _Nonnull)dataSource
                                  tableViewDelegate:(id<GNESectionedTableViewDelegate> _Nonnull)delegate;

@end
