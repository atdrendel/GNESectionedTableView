//
//  GNEDraggingItem.m
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 12/22/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

#import "GNESectionedTableViewDraggingItem.h"


// ------------------------------------------------------------------------------------------


@interface GNESectionedTableViewDraggingItem ()

@property (nonatomic, strong) NSImageView *imageView;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, copy, readwrite) NSIndexPath *indexPath;

@end


// ------------------------------------------------------------------------------------------


@implementation GNESectionedTableViewDraggingItem


// ------------------------------------------------------------------------------------------
#pragma mark - Initialization
// ------------------------------------------------------------------------------------------
- (instancetype)initWithTableCellView:(NSTableCellView *)cellView
                                frame:(CGRect)frame
                            indexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert(cellView);
    NSParameterAssert(indexPath);
    
    if (cellView == nil || indexPath == nil)
    {
        return nil;
    }
    
    if ((self = [super init]))
    {
        _imageView = [self p_imageViewWithTableCellView:cellView frame:frame];
        _frame = frame;
        _indexPath = [indexPath copy];
    }
    
    return self;
}


// ------------------------------------------------------------------------------------------
#pragma mark - NSObject - Compare
// ------------------------------------------------------------------------------------------
- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[GNESectionedTableViewDraggingItem class]])
    {
        return [self isEqualToDraggingItem:(GNESectionedTableViewDraggingItem *)object];
    }
    
    return NO;
}


- (BOOL)isEqualToDraggingItem:(GNESectionedTableViewDraggingItem *)otherDraggingItem
{
    return (self.indexPath && otherDraggingItem.indexPath &&
            [self.indexPath compare:otherDraggingItem.indexPath] == NSOrderedSame);
}


// ------------------------------------------------------------------------------------------
#pragma mark - Private - Image View
// ------------------------------------------------------------------------------------------
- (NSImageView *)p_imageViewWithTableCellView:(NSTableCellView *)cellView
                                        frame:(CGRect)frame
{
    NSParameterAssert(CGSizeEqualToSize(cellView.bounds.size, frame.size));
    
    CGRect bounds = cellView.bounds;
    CGSize size = bounds.size;
    NSBitmapImageRep *imageRep = [cellView bitmapImageRepForCachingDisplayInRect:bounds];
    imageRep.size = size;
    [cellView cacheDisplayInRect:bounds toBitmapImageRep:imageRep];
    NSImage *image = [[NSImage alloc] initWithSize:size];
    [image addRepresentation:imageRep];
    
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:frame];
    imageView.wantsLayer = YES;
    imageView.image = image;
    
    return imageView;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Accessors
// ------------------------------------------------------------------------------------------
- (NSView *)view
{
    return (NSView *)self.imageView;
}


@end
