//
//  HcAppDelegate.m
//
//  Copyright (c) 2014 Harsh Coast.
//
#import "HcAppDelegate.h"


#import "HcByteTextField.h"
#import "HcByteValue.h"


@implementation HcAppDelegate {
    HcByteValue *_byteValue;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _byteValue = [[HcByteValue alloc] init];
    _byteValue.bytes = 6050;
    self.byteTextField.editedByteValue = _byteValue;
}


@end
