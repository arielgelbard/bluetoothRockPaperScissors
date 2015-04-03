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


@end

