//
//  NSMutableArray+GNESectionedTableView.h
//  GNESectionedTableView
//
//  Created by Anthony Drendel on 6/15/14.
//  Copyright (c) 2014 Gone East LLC. All rights reserved.
//

@interface NSMutableArray (GNESectionedTableView)


/**
 Safely inserts the specified object at the specified index.
 
 @discussion If the specified index lies within the bounds of the receiver, the specified object is inserted into
                the array. Otherwise, the specified object is added to the end of the array.
 @param anObject Object to add to the receiver.
 @param index Index at which to add the specified object.
 @return Index at which the specified object was actually inserted.
 */
- (NSUInteger)gne_insertObject:(id)anObject atIndex:(NSUInteger)index;


@end
