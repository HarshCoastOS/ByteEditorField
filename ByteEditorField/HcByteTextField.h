//
//  HcByteTextField.h
//
//  Copyright (c) 2014 Harsh Coast.
//


@class HcByteValue;


/// A text field to edit byte values
///
@interface HcByteTextField : NSTextField


/// The edited byte value
///
@property (strong, nonatomic) HcByteValue *editedByteValue;


@end
