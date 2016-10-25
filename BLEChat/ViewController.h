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

//CHANGE 2a: No longer need to be a delegate
@interface ViewController : UIViewController {
    
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *labelRSSI;
//@property (weak, nonatomic) IBOutlet UIButton *buttonConnect;
@property (weak, nonatomic) BLE *bleShield; //CHANGE 2.b: make bleShield a property, will need to add "self" in different places

@end
