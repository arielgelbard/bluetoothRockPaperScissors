//
//  ViewController.h
//  arduinoRockPaperScissors
//
//  Created by Ariel Gelbard on 2015-04-02.
//  Copyright (c) 2015 Ariel Gelbard. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ORSSerialPort.h"
#import "ORSSerialPortManager.h"
@interface ViewController : NSViewController <ORSSerialPortDelegate>

@property (weak) IBOutlet NSTextField *computerChoice;

@property (weak) IBOutlet NSTextField *handChoice;

@property (weak) IBOutlet NSTextField *result;

@property (weak) IBOutlet NSImageView *leftHand;
@property (weak) IBOutlet NSImageView *leftCheckmark1;
@property (weak) IBOutlet NSImageView *leftCheckmark2;
@property (weak) IBOutlet NSImageView *leftCheckmark3;

@property (weak) IBOutlet NSImageView *rightHand;
@property (weak) IBOutlet NSImageView *rightCheckmark1;
@property (weak) IBOutlet NSImageView *rightCheckmark2;
@property (weak) IBOutlet NSImageView *rightCheckmark3;

@property (weak) IBOutlet NSImageView *countDownImage;
@property (weak) IBOutlet NSTextField *countDownLabel;

@end

