//
//  ViewController.m
//  arduinoRockPaperScissors
//
//  Created by Ariel Gelbard on 2015-04-02.
//  Copyright (c) 2015 Ariel Gelbard. All rights reserved.
//

#import "ViewController.h"
#import "ORSSerialPort.h"
#import "ORSSerialPortManager.h"

ORSSerialPort *serialPort;
NSString *playerChoice;

@implementation ViewController

- (IBAction)turnGreen:(id)sender {
    
//    NSLog(@"test");
    int randomNumber = [self getRandomNumberBetween:0 to:2];

    if  (randomNumber == 0){
        _computerChoice.stringValue=@"rock";
    }
    else if  (randomNumber == 1){
        _computerChoice.stringValue=@"paper";
    }
    else if  (randomNumber == 2){
        _computerChoice.stringValue=@"scissors";
    }
    
    NSString* str = @"start";
//
//    NSLog(@"str %@",str);
    
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [serialPort sendData:data]; // someData is an NSData object
    
}

- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data
{
    NSString *gotString = [NSString stringWithUTF8String:[data bytes]];

    playerChoice = [NSString stringWithFormat:@"%@%@",playerChoice,gotString];
    
//**when getting final string that was sent, it will add a \r\n at the end of the string (that can not be seen in the console) when needs to be removed:
    playerChoice=[playerChoice stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    if ([playerChoice isEqualToString:@"rock"]){
        _handChoice.stringValue=playerChoice;
        if ([_computerChoice.stringValue isEqualToString:@"rock"]) {
            _result.stringValue=@"draw";
        }
        else if ([_computerChoice.stringValue isEqualToString:@"paper"]) {
            _result.stringValue=@"lose";
        }
        else if ([_computerChoice.stringValue isEqualToString:@"scissors"]) {
            _result.stringValue=@"win";
        }
        playerChoice=@"";
        [self sendBackResult];
    }

    else if ([playerChoice isEqualToString:@"paper"]){
        _handChoice.stringValue=playerChoice;
        if ([_computerChoice.stringValue isEqualToString:@"rock"]) {
            _result.stringValue=@"win";
        }
        else if ([_computerChoice.stringValue isEqualToString:@"paper"]) {
            _result.stringValue=@"draw";
        }
        else if ([_computerChoice.stringValue isEqualToString:@"scissors"]) {
            _result.stringValue=@"lose";
        }
        playerChoice=@"";
        [self sendBackResult];
    }
    
    else if ([playerChoice isEqualToString:@"scissors"]){
        _handChoice.stringValue=playerChoice;
        if ([_computerChoice.stringValue isEqualToString:@"rock"]) {
            _result.stringValue=@"lose";
        }
        else if ([_computerChoice.stringValue isEqualToString:@"paper"]) {
            _result.stringValue=@"win";
        }
        else if ([_computerChoice.stringValue isEqualToString:@"scissors"]) {
            _result.stringValue=@"draw";
        }
        playerChoice=@"";
        [self sendBackResult];
    }
    
}

-(void)sendBackResult{
    
    NSString* str = _result.stringValue;
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [serialPort sendData:data];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    playerChoice = [[NSString alloc]init];
    
    serialPort = [ORSSerialPort serialPortWithPath:@"/dev/tty.HC-05-DevB"];
    serialPort.baudRate = @9600;
    
    serialPort.delegate=self;
    
    [serialPort open];
    
    
    _computerChoice.stringValue=@"";
    _handChoice.stringValue=@"";
    _result.stringValue=@"";
    
    // Do any additional setup after loading the view.

}

-(int)getRandomNumberBetween:(int)from to:(int)to {
    
    return (int)from + arc4random() % (to-from+1);
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
