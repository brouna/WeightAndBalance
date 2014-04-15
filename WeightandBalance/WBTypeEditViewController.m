//
//  WBTypeEditViewController.m
//  WeightandBalance
//
//  Created by Adam on 5/11/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//


#import "WBTypeEditViewController.h"
#import "AircraftType.h"
#import "Aircraft.h"
#import "EnvelopeViewController.h"



@implementation WBTypeEditViewController

{
    UITextField *activeField;
}

@synthesize scrollView;


- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;  //get the size of the keyboard
    
    
    CGRect navigationFrame = [[self.navigationController navigationBar] frame];
    CGFloat heightFoNavBar = navigationFrame.size.height;                             //get a correction for the navigation bar if present
    
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(heightFoNavBar, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible

    CGRect aRect = self.view.frame;
    aRect.size.height -= (kbSize.height+heightFoNavBar);
    CGPoint bottomOfField = CGPointMake(activeField.frame.origin.x, activeField.frame.origin.y+activeField.frame.size.height);
    
    
    if (!CGRectContainsPoint(aRect, bottomOfField) ) {
        CGPoint scrollPoint = CGPointMake(0.0, bottomOfField.y-kbSize.height-heightFoNavBar);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    Datum *bew = [_type datums][WBBasicEmptyDatum];
    NSNumber *bewa = [bew arm];
    NSNumber *beww = [bew quantity];
    
    Datum *fuel = [_type datums][WBFuelDatum];
    NSNumber *fuela = [fuel arm];
    
    Datum *tks = [_type datums][WBTKSDatum];
    NSNumber *tksq = [_type maxTKS];
    NSNumber *tksa = [tks arm];
    
    Datum *o2 = [_type datums][WBOxygenDatum];
    NSNumber *o2a = [o2 arm];
    NSNumber *o2q = [_type maxO2];
    
    Datum *bags = [_type datums][WBBaggageDatum];
    NSNumber *bga = [bags arm];
    
    NSNumber *fa = [_type frontArm];
    NSNumber *ba = [_type backArm];
    NSNumber *mf = [_type maxFuel];
    NSNumber *mb = [_type maxBaggage];
    NSNumber *mg = [_type maxGross];
    
    //Change keyboard
    UIToolbar *accessory = [self createToolBar];   // adds a +/- button to the Arm keyboards
    _bewALabel.inputAccessoryView = accessory;
    _frontALabel.inputAccessoryView = accessory;
    _backALabel.inputAccessoryView = accessory;
    _bagALabel.inputAccessoryView = accessory;
    _fuelALabel.inputAccessoryView = accessory;
    _TKSALabel.inputAccessoryView = accessory;
    _O2ALabel.inputAccessoryView = accessory;
    
    
    [_typeLabel setText:[_type typeName]];
    [_bewALabel setText:([bewa floatValue]==0 ? @"":[NSString stringWithFormat:@"%1.1f",[bewa floatValue]])];
    [_bewWlabel setText:([beww integerValue]==0 ? @"":[NSString stringWithFormat:@"%li",(long)[beww integerValue]])];
    [_frontALabel setText:([fa floatValue]==0 ? @"":[NSString stringWithFormat:@"%1.1f",[fa floatValue]])];
    [_backALabel setText:([ba floatValue]==0 ? @"" :[NSString stringWithFormat:@"%1.1f",[ba floatValue]])];
    [_bagALabel setText:([bga floatValue]==0 ? @"" :[NSString stringWithFormat:@"%1.1f",[bga floatValue]])];
    [_fuelALabel setText:([fuela floatValue]==0 ? @"" : [NSString stringWithFormat:@"%1.1f",[fuela floatValue]])];
    [_fuelQlabel setText:([mf floatValue]==0 ? @"" :[NSString stringWithFormat:@"%1.1f",[mf floatValue]])];
    [_MGWLabel  setText:([mg integerValue]==0 ? @"" : [NSString stringWithFormat:@"%li",(long)[mg integerValue]])];
    [_bagWLabel setText:([mb floatValue]==0 ? @"" : [NSString stringWithFormat:@"%1.1f",[mb floatValue]])];
    [_TKSQLabel setText:([tksq floatValue]==0 ? @"" : [NSString stringWithFormat:@"%1.1f",[tksq floatValue]])];
    [_TKSALabel setText:([tksa floatValue]==0 ? @"" : [NSString stringWithFormat:@"%1.1f",[tksa floatValue]])];
    [_O2WLabel  setText:([o2q floatValue]==0 ? @"" : [NSString stringWithFormat:@"%1.1f",[o2q floatValue]])];
    [_O2ALabel  setText:([o2a floatValue]==0 ? @"" : [NSString stringWithFormat:@"%1.1f",[o2a floatValue]])];
    
    
    [_typeLabel setDelegate:self];
    [_bewALabel setDelegate:self];
    [_bewWlabel setDelegate:self];
    [_frontALabel setDelegate:self];
    [_backALabel setDelegate:self];
    [_fuelALabel setDelegate:self];
    [_fuelQlabel setDelegate:self];
    [_MGWLabel setDelegate:self];
    [_bagWLabel setDelegate:self];
    [_bagALabel setDelegate:self];
    [_TKSQLabel setDelegate:self];
    [_TKSALabel setDelegate: self];
    [_O2ALabel setDelegate: self];
    [_O2WLabel setDelegate: self];
    
    
    [self registerForKeyboardNotifications];
    [self resetScrollWindow];

}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self resetScrollWindow];
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self view] endEditing:YES];

    _type.typeName=_typeLabel.text;
    
    Datum *bew = [_type datums][WBBasicEmptyDatum];
    [bew setArm: @([[_bewALabel text] floatValue])];
    [bew setQuantity:@([[_bewWlabel text] floatValue])];
    
    
    [_type setFrontArm:@([[_frontALabel text] floatValue])];
    [_type setBackArm:@([[_backALabel text] floatValue])];  
    
    Datum *bags = [_type datums][WBBaggageDatum];
    [bags setArm:@([[_bagALabel text] floatValue])];
    
    
    Datum *few = [_type datums][WBFuelDatum];
    [few setArm: @([[_fuelALabel text] floatValue])];
    
    Datum *tks = [_type datums][WBTKSDatum];
    [tks setArm:@([[_TKSALabel text] floatValue])];
    [_type setMaxTKS:@([[_TKSQLabel text]floatValue])];
    
    Datum *o2 = [_type datums][WBOxygenDatum];
    [o2 setArm:@([[_O2ALabel text]floatValue])];
    [_type setMaxO2:@([[_O2WLabel text]floatValue])];
    
    [_type setMaxFuel:@([[_fuelQlabel text] floatValue])];
    [_type setMaxBaggage:@([[_bagWLabel text]floatValue])];
    [_type setMaxGross:@([[_MGWLabel text]floatValue])];
}



- (IBAction)backgroundTapped:(id)sender {
    [[self view] endEditing:YES];
  }


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editTypeEnvelope"]) {
        EnvelopeViewController *evc = segue.destinationViewController;
        evc.envelope = _type.envelope;
        evc.maxGross = _type.maxGross;
        [self resetScrollWindow];
        if (activeField) {
            [activeField resignFirstResponder];
            activeField = nil;
        }

    }
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

-(void)resetScrollWindow
{
    
    
    // Set the scroll view's content size to be the same width as the
    // application's frame but set its height to be the height of the
    // application frame minus the height of the navigation bar's frame
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    CGRect navigationFrame = [[self.navigationController navigationBar] frame];
    CGFloat height = applicationFrame.size.height - navigationFrame.size.height;
    CGSize newContentSize = CGSizeMake(applicationFrame.size.width, height);
    
    scrollView.contentSize = newContentSize;
    
    [scrollView setContentOffset:(CGPointMake(0.0, 0.0)) animated:NO];
    
}

-(UIToolbar *) createToolBar
{
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.view.window.frame.size.width, 44.0f)];
    
    toolbar.tintColor = [UIColor colorWithRed:0.56f
                                        green:0.59f
                                         blue:0.63f
                                        alpha:1.0f];
    toolbar.translucent = NO;
    toolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:@"+/-" style:UIBarButtonItemStyleBordered target:self action:@selector(changeSign:)]];
    
    return toolbar;
    
}

-(void)changeSign:(UIBarButtonItem *) sender
{
    
    if (activeField.isFirstResponder){
        if ([[activeField text] floatValue] != 0 )
        {
            activeField.text = [NSString stringWithFormat:@"%1.1f", (-1 * [[activeField text]floatValue])];
        }
    }
    
}



@end
