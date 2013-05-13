//
//  WBTypeEditViewController.h
//  WeightandBalance
//
//  Created by Adam on 5/11/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AircraftType;

@interface WBTypeEditViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate>
@property AircraftType *type;

@property (weak, nonatomic) IBOutlet UITextField *typeLabel;
@property (weak, nonatomic) IBOutlet UITextField *bewWlabel;
@property (weak, nonatomic) IBOutlet UITextField *bewALabel;
@property (weak, nonatomic) IBOutlet UITextField *frontALabel;
@property (weak, nonatomic) IBOutlet UITextField *backALabel;
@property (weak, nonatomic) IBOutlet UITextField *bagWLabel;
@property (weak, nonatomic) IBOutlet UITextField *bagALabel;
@property (weak, nonatomic) IBOutlet UITextField *fuelQlabel;
@property (weak, nonatomic) IBOutlet UITextField *fuelALabel;
@property (weak, nonatomic) IBOutlet UITextField *TKSQLabel;
@property (weak, nonatomic) IBOutlet UITextField *TKSALabel;
@property (weak, nonatomic) IBOutlet UITextField *O2WLabel;
@property (weak, nonatomic) IBOutlet UITextField *O2ALabel;
@property (weak, nonatomic) IBOutlet UITextField *MGWLabel;
- (IBAction)setEnvelope;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)backgroundTapped:(id)sender;

@end
