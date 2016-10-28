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
    NSUInteger length = [d length];
    NSUInteger index;
    
    for (index = 0; index<length; index++)
    {
        char aByte = fileBytes[index];
        NSLog(@"Byte at index %lu: %c", (unsigned long)index, aByte);
        //Do something with each byte
    }
    
//    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
//    NSLog(@"Received data: %@", s);
//    self.label.text = s;
}

- (void) onBLEDidDisconnect: (NSNotification *)notification
{
    NSLog(@"onBLEDidDisconnect");
    
    [rssiTimer invalidate];
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
- (IBAction)sendText:(id)sender {
    NSLog(@"sendText");
    
    NSString *s;
    NSData *d;
    
    if (self.textField.text.length > 16)
        s = [self.textField.text substringToIndex:16];
    else
        s = self.textField.text;
    
    s = [NSString stringWithFormat:@"%@\r\n", s];
    d = [s dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.bleShield write:d];
}

@end
