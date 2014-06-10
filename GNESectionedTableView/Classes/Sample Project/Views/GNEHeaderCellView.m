//
//  GNEHeaderCellView.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 6/10/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

#import "GNEHeaderCellView.h"

@implementation GNEHeaderCellView


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
- (instancetype)initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect]))
    {
        CALayer *layer = [self layer];
        layer.backgroundColor = [[[NSColor purpleColor] colorWithAlphaComponent:0.1f] CGColor];
    }
    
    return self;
}


@end
