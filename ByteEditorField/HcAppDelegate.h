//
//  HcAppDelegate.h
//
//  Copyright (c) 2014 Harsh Coast.
//


@class HcByteTextField;


@interface HcAppDelegate : NSObject <NSApplicationDelegate>


@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet HcByteTextField *byteTextField;


@end
