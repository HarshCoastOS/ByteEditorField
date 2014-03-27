//
//  HcByteValueViewController.h
//
//  Copyright (c) 2014 Harsh Coast.
//


@class HcByteValue;


/// The view controller for the byte value editor.
///
@interface HcByteValueViewController : NSViewController


/// The edited byte value
///
@property (strong) HcByteValue *editedByteValue;

/// Popover which owns this controller.
///
@property (weak) NSPopover *owner;


@end
