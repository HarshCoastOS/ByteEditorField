//
//  HcByteValueViewController.m
//
//  Copyright (c) 2014 Harsh Coast.
//
#import "HcByteValueViewController.h"


@interface HcByteValueViewController ()

@end


@implementation HcByteValueViewController


- (id)init
{
    self = [super initWithNibName:@"HcByteValueView" bundle:nil];
    if (self) {
        // Initialization code here.
    }
    return self;
}


- (IBAction)onDoneClicked:(id)sender
{
    [self.owner performClose:nil];
}


@end
