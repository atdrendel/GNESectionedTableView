//
//  GNEOutlineViewParentItem.m
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

#import "GNEOutlineViewParentItem.h"
#import "NSIndexPath+GNESectionedTableView.h"


// ------------------------------------------------------------------------------------------


static NSString * const kOutlineViewParentItemHasFooterKey = @"hasFooter";


// ------------------------------------------------------------------------------------------


@implementation GNEOutlineViewParentItem


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
- (instancetype)init
{
    if (self = [super initWithParentItem:nil])
    {
        _hasFooter = NO;
    }
    
    return self;
}


- (instancetype)initWithParentItem:(GNEOutlineViewParentItem * __unused)parentItem
{
    NSAssert1(parentItem == nil, @"Instances of GNEOutlineViewParentItem can not have parents: %@", parentItem);
    
    return [self init];
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSCoding
// ------------------------------------------------------------------------------------------
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSNumber *hasFooterNumber = [aDecoder decodeObjectOfClass:[NSNumber class]
                                                     forKey:kOutlineViewParentItemHasFooterKey];
    
    if (hasFooterNumber == nil)
    {
        return nil;
    }
    
    if ((self = [super initWithCoder:aDecoder]))
    {
        _hasFooter = hasFooterNumber.boolValue;
    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:@(self.hasFooter) forKey:kOutlineViewParentItemHasFooterKey];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Description
// ------------------------------------------------------------------------------------------
- (NSString *)description
{
    NSString *sectionString = @"";
    id <GNEOutlineViewItemPasteboardWritingDelegate> theDelegate = self.pasteboardWritingDelegate;
    SEL selector = NSSelectorFromString(@"draggedIndexPathForOutlineViewItem:");
    if ([theDelegate respondsToSelector:selector])
    {
        NSIndexPath *indexPath = [theDelegate draggedIndexPathForOutlineViewItem:self];
        unsigned long section = indexPath.gne_section;
        sectionString = [NSString stringWithFormat:@" Section: %lu", section];
    }
    
    return [NSString stringWithFormat:@"<%@: %p>%@",
            [self className], self, sectionString];
}


// ------------------------------------------------------------------------------------------
#pragma mark - Accessors
// ------------------------------------------------------------------------------------------
- (void)setParentItem:(GNEOutlineViewParentItem * __unused)parentItem
{
    NSAssert(NO, @"Outline view parent items cannot have parent items.");
}


@end
