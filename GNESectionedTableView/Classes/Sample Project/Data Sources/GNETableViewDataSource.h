//
//  GNETableViewDataSource.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 6/9/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

#import "GNESectionedTableView.h"

@interface GNETableViewDataSource : NSObject <GNESectionedTableViewDataSource, GNESectionedTableViewDelegate>


- (void)setTableView:(GNESectionedTableView *)tableView;


@end
