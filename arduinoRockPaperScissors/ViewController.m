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


@import QuartzCore;

ORSSerialPort *serialPort;
NSString *playerChoice;
NSImageView *startScreen;
NSTimer *timer;

@implementation ViewController

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
    
    [self loadStartScreen];
    [self setupWinnerScreen];

}


-(void)loadStartScreen{
    startScreen=[[NSImageView alloc]initWithFrame:NSRectFromCGRect(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))];
    [startScreen setWantsLayer:YES];
    [startScreen.layer setBackgroundColor:[[NSColor whiteColor] CGColor]];
    [self.view addSubview:startScreen];
    
    NSImageView *titleView;
    titleView=[[NSImageView alloc]initWithFrame:NSRectFromCGRect(CGRectMake(445, 636, 499, 93))];
    titleView.image=[NSImage imageNamed:@"startTitle.png"];
    [startScreen addSubview:titleView];
    
    NSButton *startButton;
    startButton=[[NSButton alloc]initWithFrame:NSRectFromCGRect(CGRectMake(400, 200, 627, 260))];
    startButton.image=[NSImage imageNamed:@"startButton.png"];
    [startButton setBordered:NO];
    [startScreen addSubview:startButton];
    [startButton setTarget:self];
    [startButton setAction:@selector(beginGame)];
}

- (void)beginGame {
    
    [self resetBoard];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
        [context setDuration:2.0f];
        [[startScreen animator] setAlphaValue:0];
    } completionHandler:^{
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
            [startScreen removeFromSuperview];
            [self startTimer];
        } completionHandler:nil];
    }];
    
}

-(void)startTimer{
    _leftHand.image=[NSImage imageNamed:[NSString stringWithFormat:@"gesture-rock-left.png"]];
    _result.stringValue=@"";
    _countDownLabel.stringValue=@"3";
    _countDownImage.image=[NSImage imageNamed:@"new-countdown-3.png"];
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.7
             target:self
           selector:@selector(countDown)
           userInfo:nil
            repeats:YES];
}


-(void)countDown{
    if ([_countDownLabel.stringValue isEqualToString:@"1"]) {
        _countDownLabel.stringValue=@"";
        [timer invalidate];
        [self beginNextRound:nil];
    }
    else{
        _countDownImage.image=[NSImage imageNamed:[NSString stringWithFormat:@"new-countdown-%d.png", [_countDownLabel.stringValue intValue]-1]];
        _countDownLabel.stringValue= [NSString stringWithFormat:@"%d", [_countDownLabel.stringValue intValue]-1];
    }
}

- (IBAction)beginNextRound:(id)sender {
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
    
    _countDownImage.image=[NSImage imageNamed:@"new-rock.png"];
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.7
            target:self
            selector:@selector(getReadyforWinner)
            userInfo:nil
            repeats:YES];
    [self flickerGloveLight];
}

int i=0;
-(void)getReadyforWinner{
    if (i==0) {
        _countDownImage.image=[NSImage imageNamed:@"new-paper.png"];
        [self flickerGloveLight];
        i=1;
    }
    else if (i==1) {
        _countDownImage.image=[NSImage imageNamed:@"new-scissors.png"];
        [self flickerGloveLight];
        i=2;
    }
    else if (i==2) {
        i=0;
        _countDownImage.image=nil;
        [timer invalidate];
        [self sendBack:@"check"];
//        [self tempPlayerChoice];
    }
}

-(void)tempPlayerChoice{
    int randomNumber = [self getRandomNumberBetween:0 to:2];
    
    if  (randomNumber == 0){
        playerChoice=@"rock";
    }
    else if  (randomNumber == 1){
        playerChoice=@"paper";
    }
    else if  (randomNumber == 2){
        playerChoice=@"scissors";
    }
    
    [self checkForAnswer];
}

int j=0;
- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data {
    NSString *gotString = [NSString stringWithUTF8String:[data bytes]];
    playerChoice = [NSString stringWithFormat:@"%@%@",playerChoice,gotString];
    
    //**when getting final string that was sent, it will add a \r\n at the end of the string (that can not be seen in the console) when needs to be removed:
    playerChoice=[playerChoice stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    if ([playerChoice isEqualToString:@"rock"] || [playerChoice isEqualToString:@"paper"] || [playerChoice isEqualToString:@"scissors"] ){
        _rightHand.image=[NSImage imageNamed:[NSString stringWithFormat:@"gesture-%@.png",playerChoice]];
        _handChoice.stringValue=playerChoice;
        playerChoice=@"";
    }
    
    else if([playerChoice isEqualToString:@"change"]){
        [self checkForAnswer];
        playerChoice=@"";
    }
}

-(void)checkForAnswer{
    _leftHand.image=[NSImage imageNamed:[NSString stringWithFormat:@"gesture-%@-left.png",_computerChoice.stringValue]];
    
    if ([_handChoice.stringValue isEqualToString:@"rock"]){
        if ([_computerChoice.stringValue isEqualToString:@"rock"]) {
            _result.stringValue=@"draw";
        }
        else if ([_computerChoice.stringValue isEqualToString:@"paper"]) {
            _result.stringValue=@"lose";
        }
        else if ([_computerChoice.stringValue isEqualToString:@"scissors"]) {
            _result.stringValue=@"win";
        }
    }
    
    else if ([_handChoice.stringValue isEqualToString:@"paper"]){
        if ([_computerChoice.stringValue isEqualToString:@"rock"]) {
            _result.stringValue=@"win";
        }
        else if ([_computerChoice.stringValue isEqualToString:@"paper"]) {
            _result.stringValue=@"draw";
        }
        else if ([_computerChoice.stringValue isEqualToString:@"scissors"]) {
            _result.stringValue=@"lose";
        }
    }
    
    else if ([_handChoice.stringValue isEqualToString:@"scissors"]){
        if ([_computerChoice.stringValue isEqualToString:@"rock"]) {
            _result.stringValue=@"lose";
        }
        else if ([_computerChoice.stringValue isEqualToString:@"paper"]) {
            _result.stringValue=@"win";
        }
        else if ([_computerChoice.stringValue isEqualToString:@"scissors"]) {
            _result.stringValue=@"draw";
        }
    }
    
    if(![_result.stringValue isEqualToString:@""]){
        NSTimer *timer2 = [NSTimer scheduledTimerWithTimeInterval: 0.8
                           target:self
                         selector:@selector(showResults)
                         userInfo:nil
                          repeats:NO];
    }
}

-(void) showResults{
    _countDownImage.image = [NSImage imageNamed:[NSString stringWithFormat:@"countdown-%@.png", _result.stringValue]];
    [self sendBack:_result.stringValue];
    [self updateScoreBoard:_result.stringValue];
}

-(void)updateScoreBoard: (NSString *)answer{
    
    bool anotherRound=true;
    
    if([answer isEqualToString:@"lose"]){
        if (_leftCheckmark1.alphaValue==0&&_leftCheckmark2.alphaValue==0&&_leftCheckmark3.alphaValue==0) {
            [self animate:_leftCheckmark1 opacityValue:1];
        }
        else if (_leftCheckmark1.alphaValue==1&&_leftCheckmark2.alphaValue==0&&_leftCheckmark3.alphaValue==0) {
            [self animate:_leftCheckmark2 opacityValue:1];
        }
        else if (_leftCheckmark1.alphaValue==1&&_leftCheckmark2.alphaValue==1&&_leftCheckmark3.alphaValue==0) {
            //CPU LOSE
            [self showWinner:false];
            anotherRound=false;
        }
    }
    else if([answer isEqualToString:@"win"]){
        if (_rightCheckmark1.alphaValue==0&&_rightCheckmark2.alphaValue==0&&_rightCheckmark3.alphaValue==0) {
            [self animate:_rightCheckmark1 opacityValue:1];
        }
        else if (_rightCheckmark1.alphaValue==1&&_rightCheckmark2.alphaValue==0&&_rightCheckmark3.alphaValue==0) {
            [self animate:_rightCheckmark2 opacityValue:1];
        }
        else if (_rightCheckmark1.alphaValue==1&&_rightCheckmark2.alphaValue==1&&_rightCheckmark3.alphaValue==0) {
            // HUMAN LOSE
            [self showWinner:true];
            anotherRound=false;
        }
    }
    if(anotherRound){
        NSTimer *timer2 = [NSTimer scheduledTimerWithTimeInterval: 2
        target:self
        selector:@selector(startTimer)
        userInfo:nil
        repeats:NO];
    }
}

NSImageView *winnerScreen;
NSString *winnerScreenBackgroundName;
-(void)showWinner:(BOOL)humanWin{
    if (humanWin==true) {
        winnerScreenBackgroundName=@"human";
        winnerScreen.image=[NSImage imageNamed:@"bg-human-win-up.png"];
    }
    else{
        winnerScreenBackgroundName=@"cpu";
        winnerScreen.image=[NSImage imageNamed:@"bg-cpu-win-happy.png"];
    }
    [self.view addSubview:winnerScreen];
    [self animate:winnerScreen opacityValue:1];
}

-(void)backToMainScreen{
    [self.view addSubview:startScreen];
    [self animate:startScreen opacityValue:1];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
        [context setDuration:1.0f];
        [[winnerScreen animator] setAlphaValue:0];
    } completionHandler:^{
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
            [winnerScreen removeFromSuperview];
        } completionHandler:nil];
    }];
}




















-(void)sendBack:(NSString *)theString{
    NSString* str = theString;
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [serialPort sendData:data];
    
}

-(void)animate:(NSImageView *)view opacityValue:(CGFloat)value{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
        [context setDuration:1.0f];
        [[view animator] setAlphaValue:value];
        //        [[startScreen animator] setFrame:test];
    } completionHandler:nil];
}

-(void)flickerGloveLight{
    [self sendBack:@"1"];
    NSTimer *temp = [NSTimer scheduledTimerWithTimeInterval: 0.5
                     target:self
                   selector:@selector(flickerGloveLightOff)
                   userInfo:nil
                    repeats:NO];
}

-(void)flickerGloveLightOff{
    [self sendBack:@"0"];
}

-(void) setupWinnerScreen{
    winnerScreen=[[NSImageView alloc]initWithFrame:
    NSRectFromCGRect(CGRectMake(155, 0, 1078, 744))];
    winnerScreen.alphaValue=0;
    NSButton *menuButton;
    menuButton=[[NSButton alloc]initWithFrame:NSRectFromCGRect(CGRectMake(150, 100, 764, 261))]; //421,125,547,186
    menuButton.image=[NSImage imageNamed:@"btn-mainmenu.png"];
    [winnerScreen addSubview:menuButton];
    [menuButton setBordered:NO];
    [menuButton setTarget:self];
    [menuButton setAction:@selector(backToMainScreen)];
    NSTimer *timer2 = [NSTimer scheduledTimerWithTimeInterval: 1
                                                       target:self
                                                     selector:@selector(animateWinnerBackground)
                                                     userInfo:nil
                                                      repeats:YES];
}

int bg=0;
-(void)animateWinnerBackground{
    if ([winnerScreenBackgroundName isEqualToString:@"cpu"]) {
        if (bg==0) {
            bg=1;
            winnerScreen.image=[NSImage imageNamed:@"bg-cpu-win-happy.png"];
        }
        else{
            bg=0;
            winnerScreen.image=[NSImage imageNamed:@"bg-cpu-win-mad.png"];
        }
    }
    else{
        if (bg==0) {
            bg=1;
            winnerScreen.image=[NSImage imageNamed:@"bg-human-win-up.png"];
        }
        else{
            bg=0;
            winnerScreen.image=[NSImage imageNamed:@"bg-human-win-down.png"];
        }
    }
}

-(void)resetBoard{
    playerChoice=@"";
    _result.stringValue=@"";
    _countDownLabel.stringValue=@"";
    _leftHand.image=[NSImage imageNamed:[NSString stringWithFormat:@"gesture-rock-left.png"]];
    _rightHand.image=[NSImage imageNamed:[NSString stringWithFormat:@"gesture-rock.png"]];
    [_leftCheckmark1 setAlphaValue:0];
    [_leftCheckmark2 setAlphaValue:0];
    [_leftCheckmark3 setAlphaValue:0];
    [_rightCheckmark1 setAlphaValue:0];
    [_rightCheckmark2 setAlphaValue:0];
    [_rightCheckmark3 setAlphaValue:0];
}

-(int)getRandomNumberBetween:(int)from to:(int)to {
    return (int)from + arc4random() % (to-from+1);
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
