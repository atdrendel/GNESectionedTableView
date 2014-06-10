//
//  GNETableCellView.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 6/9/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

#import "GNETableCellView.h"


// ------------------------------------------------------------------------------------------


@interface GNETableCellView ()


@property (nonatomic, strong) NSTextField *titleTextField;


@end


// ------------------------------------------------------------------------------------------


@implementation GNETableCellView


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
- (instancetype)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setAutoresizingMask:NSViewWidthSizable];
        [self setWantsLayer:YES];
        
        CALayer *layer = [self layer];
        layer.backgroundColor = [[[NSColor orangeColor] colorWithAlphaComponent:0.1f] CGColor];
        
        [self buildAndConfigure];
    }
    
    return self;
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSView
// ------------------------------------------------------------------------------------------
- (BOOL)wantsUpdateLayer
{
    return YES;
}


- (void)updateLayer
{
    [self layoutCellView];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Build and Configure
// ------------------------------------------------------------------------------------------
- (void)buildAndConfigure
{
    [self buildAndConfigureTextField];
}


- (void)buildAndConfigureTextField
{
    self.titleTextField = [[NSTextField alloc] initWithFrame:CGRectZero];
    [self.titleTextField setBordered:NO];
    [self.titleTextField setBezeled:NO];
    [self.titleTextField setBackgroundColor:[NSColor clearColor]];
    
    [self addSubview:self.titleTextField];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Layout
// ------------------------------------------------------------------------------------------
- (void)layoutCellView
{
    CGRect frame = [self bounds];
    const CGFloat height = 18.0f;
    frame.origin.y = (frame.size.height - height) / 2.0f;
    frame.size.height = 18.0f;
    
    [self.titleTextField setFrame:frame];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Accessors
// ------------------------------------------------------------------------------------------
- (void)setTitle:(NSString *)title
{
    if (_title != title)
    {
        _title = [title copy];
        [self.titleTextField setStringValue:_title];
    }
}


@end
