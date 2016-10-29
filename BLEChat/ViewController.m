//
//  ViewController.m
//  BLEChat
//
//  Created by Cheong on 15/8/12.
//  Modified by Eric Larson, 2014
//  Copyright (c) 2012 RedBear Lab., All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *deviceLabel;
@property (weak, nonatomic) IBOutlet UISwitch *buttonSwitch;
@property (weak, nonatomic) IBOutlet UILabel *potLabel;
@property (nonatomic) CGFloat hue;
@property (nonatomic) CGFloat saturation;
@property (nonatomic) CGFloat brightness;
@property (nonatomic) int potValue;

@end

@implementation ViewController

-(BLE*)bleShield
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.bleShield;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBLEDidConnect:) name:kBleConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBLEDidDisconnect:) name:kBleDisconnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBLEDidUpdateRSSI:) name:kBleRSSINotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (onBLEDidReceiveData:) name:kBleReceivedDataNotification object:nil];
    
    self.potValue = 1023;
    [self setRandomBackground];
}

-(void) setRandomBackground{
    self.hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    self.saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    self.brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    [self setColor];
}
-(void) setColor{
    CGFloat alpha = (float)self.potValue / 1023;
    UIColor* newColor = [UIColor colorWithHue:self.hue saturation:self.saturation brightness:self.brightness alpha:alpha];
    
    [self.view setBackgroundColor:newColor];
}
//setup auto rotation in code
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - RSSI timer
NSTimer *rssiTimer;
-(void) readRSSITimer:(NSTimer *)timer
{
//    NSLog(@"readRSSITimer");
    
    [_bleShield readRSSI]; // be sure that the RSSI is up to date
}

#pragma mark - BLEdelegate protocol methods
-(void) onBLEDidUpdateRSSI:(NSNumber *)rssi
{
    NSLog(@"onBLEDidUpdateRSSI");
    
    self.labelRSSI.text = rssi.stringValue; // when RSSI read is complete, display it
}

-(void) onBLEDidReceiveData:(NSNotification *)notification
{
//    NSLog(@"onBLEDidReceiveData");
    
    NSData* d = [[notification userInfo] objectForKey:@"data"];
    
    const char* fileBytes = (const char*)[d bytes];
    
    switch(fileBytes[0]){
        case 'F':{
            BOOL isClicked = [[NSString stringWithFormat:@"%c", fileBytes[1]] boolValue];
            [self.buttonSwitch setOn:isClicked];
            if(isClicked){
                [self setRandomBackground];
            }
            break;
        }
        case 'E':{
            NSData *value = [d subdataWithRange:NSMakeRange(1, [d length] - 1)];
            NSString *s = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
            int int_val = [s intValue];
            if(int_val < 10){
                [self.potLabel setText:@"0"];
            }else if(labs(1023 - int_val) < 10){
                [self.potLabel setText:@"1023"];
            }else{
                [self.potLabel setText:s];
            }
            self.potValue = int_val;
            [self setColor];
            break;
        }
    }
    
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    NSLog(@"Received data: %@", s);
}

- (void) onBLEDidDisconnect: (NSNotification *)notification
{
    NSLog(@"onBLEDidDisconnect");
    
    [rssiTimer invalidate];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) onBLEDidConnect: (NSNotification *)notification {
    NSLog(@"onBLEDidConnect");
    
    // Schedule to read RSSI every 1 sec.
    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(readRSSITimer:) userInfo:nil repeats:YES];
    [self changeNameLabel:notification];
}

-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSLog(@"bleDidReceiveData");
    
    NSData *d = [NSData dataWithBytes:data length:length];
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    self.label.text = s;
}

- (void) bleDidDisconnect
{
    NSLog(@"bleDidDisconnect");
    
    [rssiTimer invalidate];
}

-(void) changeNameLabel:(NSNotification *)notification {
    NSLog(@"changeNameLabel");
    
    NSString *deviceName =[notification.userInfo objectForKey:@"deviceName"];
    self.deviceLabel.text = deviceName;
}

-(void) bleDidConnect
{
    NSLog(@"bleDidConnect");
    
    // Schedule to read RSSI every 1 sec.
    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(readRSSITimer:) userInfo:nil repeats:YES];
}

#pragma mark - UI operations storyboard
- (IBAction)ledChanged:(id)sender {
    NSLog(@"ledChanged");
    
    NSMutableData *d = [[NSMutableData alloc] init];
    [d appendBytes:"B" length:1];
    BOOL state = [(UISwitch* )sender isOn];
    [d appendBytes:&state length:1];
    
    [self.bleShield write:d];
}
- (IBAction)servoChanged:(id)sender {
    NSLog(@"servoChanged");
    
    int int_value = (int) [(UISlider* )sender value];
    NSMutableData *d = [[NSMutableData alloc] init];
    [d appendBytes:"D" length:1];
    [d appendBytes:&int_value length:sizeof(int_value)];
//    NSLog(@"Integer: %i", int_value);
    
    
    [self.bleShield write:d];
}

@end
