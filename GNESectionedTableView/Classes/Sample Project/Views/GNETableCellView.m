//
//  GNETableCellView.m
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
        self.wantsLayer = YES;
        
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
    self.titleTextField.bordered = NO;
    self.titleTextField.bezeled = NO;
    self.titleTextField.backgroundColor = [NSColor clearColor];
    
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
