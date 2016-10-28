//
//  ViewController.h
//  BLEChat
//
//  Created by Cheong on 15/8/12.
//  Copyright (c) 2012 RedBear Lab., All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"
#import "AppDelegate.h"

@interface ViewController : UIViewController {
    
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *labelRSSI;
@property (weak, nonatomic) BLE *bleShield;

@end
