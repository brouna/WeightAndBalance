//
//  AircraftViewController.m
//  WeightandBalance
//
//  Created by Adam on 4/27/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AircraftViewController.h"
#import "Datum.h"
#import "AircraftStore.h"
#import "Aircraft.h"
#import "AircraftType.h"
#import "EnvelopeViewController.h"



@implementation AircraftViewController

{
    UITextField *activeField;
}

@synthesize aircraft;
@synthesize createNew;
@synthesize scrollView;
@synthesize tailLabel, typeLabel, bewALabel, bewWLabel, frontALabel, baggageALabel, backALabel, fuelCLabel, fuelAlabel, mgwLabel, maxBaggageWt, tksALabel, tksWLabel, o2ALabel, o2WLabel;




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      
    
    }
    return self;
}

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
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;  //get the size of the keyboard
    

    CGRect navigationFrame = [[self.navigationController navigationBar] frame];
    CGFloat heightForNavBar = navigationFrame.size.height;                             //get a correction for the navigation bar if present
    

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(heightForNavBar, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
 
    CGRect aRect = self.view.frame;
    aRect.size.height -= (kbSize.height+heightForNavBar);
    CGPoint bottomOfField = CGPointMake(activeField.frame.origin.x, activeField.frame.origin.y+activeField.frame.size.height);
    
    
    if (!CGRectContainsPoint(aRect, bottomOfField) ) {
        CGPoint scrollPoint = CGPointMake(0.0, bottomOfField.y-kbSize.height-heightForNavBar);
        scrollPoint.y = (scrollPoint.y<0 ? 0 : scrollPoint.y);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    [self resetScrollWindow];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIToolbar *accessory = [self createToolBar];  // add +/- button to arms labels
    bewALabel.inputAccessoryView = accessory;
    frontALabel.inputAccessoryView = accessory;
    backALabel.inputAccessoryView = accessory;
    baggageALabel.inputAccessoryView = accessory;
    fuelAlabel.inputAccessoryView = accessory;
    tksALabel.inputAccessoryView = accessory;
    o2ALabel.inputAccessoryView = accessory;
    
    
    
    Datum *bew = [aircraft datums][WBBasicEmptyDatum];
    NSNumber *bewa = [bew arm];
    NSNumber *beww = [bew quantity];
    
    Datum *fuel = [aircraft datums][WBFuelDatum];
    NSNumber *fuela = [fuel arm];
    
    Datum *tks = [aircraft datums][WBTKSDatum];
    NSNumber *tksq = [aircraft maxTKS];
    NSNumber *tksa = [tks arm];
    
    Datum *o2 = [aircraft datums][WBOxygenDatum];
    NSNumber *o2a = [o2 arm];
    NSNumber *o2q = [aircraft maxO2];
    
    Datum *bags = [aircraft datums][WBBaggageDatum];
    NSNumber *bga = [bags arm];
        
    NSNumber *fa = [aircraft frontArm];
    NSNumber *ba = [aircraft backArm];
    NSNumber *mf = [aircraft maxFuel];
    NSNumber *mb = [aircraft maxBaggage];
    NSNumber *mg = [aircraft maxGross];
    
    [tailLabel setText:[aircraft tailNumber]];
    [typeLabel setText:[aircraft typeName]];
    [bewALabel setText:([bewa floatValue]==0 ? @"":[NSString stringWithFormat:@"%1.1f",[bewa floatValue]])];
    [bewWLabel setText:([beww integerValue]==0 ? @"":[NSString stringWithFormat:@"%li",(long)[beww integerValue]])];
    [frontALabel setText:([fa floatValue]==0 ? @"":[NSString stringWithFormat:@"%1.1f",[fa floatValue]])];
    [backALabel setText:([ba floatValue]==0 ? @"" :[NSString stringWithFormat:@"%1.1f",[ba floatValue]])];
    [baggageALabel setText:([bga floatValue]==0 ? @"" :[NSString stringWithFormat:@"%1.1f",[bga floatValue]])];
    [fuelAlabel setText:([fuela floatValue]==0 ? @"" : [NSString stringWithFormat:@"%1.1f",[fuela floatValue]])];
    [fuelCLabel setText:([mf floatValue]==0 ? @"" :[NSString stringWithFormat:@"%1.1f",[mf floatValue]])];
    [mgwLabel  setText:([mg integerValue]==0 ? @"" : [NSString stringWithFormat:@"%li",(long)[mg integerValue]])];
    [maxBaggageWt setText:([mb floatValue]==0 ? @"" : [NSString stringWithFormat:@"%1.1f",[mb floatValue]])];
    [tksWLabel setText:([tksq floatValue]==0 ? @"" : [NSString stringWithFormat:@"%1.1f",[tksq floatValue]])];
    [tksALabel setText:([tksa floatValue]==0 ? @"" : [NSString stringWithFormat:@"%1.1f",[tksa floatValue]])];
    [o2WLabel  setText:([o2q floatValue]==0 ? @"" : [NSString stringWithFormat:@"%1.1f",[o2q floatValue]])];
    [o2ALabel  setText:([o2a floatValue]==0 ? @"" : [NSString stringWithFormat:@"%1.1f",[o2a floatValue]])];
    
    

    [tailLabel setDelegate:self];
    [typeLabel setDelegate:self];
    [bewALabel setDelegate:self];
    [bewWLabel setDelegate:self];
    [frontALabel setDelegate:self];
    [backALabel setDelegate:self];
    [fuelAlabel setDelegate:self];
    [fuelCLabel setDelegate:self];
    [baggageALabel setDelegate:self];
    [mgwLabel setDelegate:self];
    [maxBaggageWt setDelegate:self];
    [tksWLabel setDelegate:self];
    [tksALabel setDelegate: self];
    [o2ALabel setDelegate: self];
    [o2WLabel setDelegate: self];
    
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

    
    [aircraft setTailNumber:[tailLabel text]];
    [aircraft setTypeName:[typeLabel text]];
    
    Datum *bew = [aircraft datums][WBBasicEmptyDatum];
    [bew setArm: @([[bewALabel text] floatValue])];
    [bew setQuantity:@([[bewWLabel text] floatValue])];


    [aircraft setFrontArm:@([[frontALabel text] floatValue])];
    [aircraft setBackArm:@([[backALabel text] floatValue])];
    
    Datum *bags = [aircraft datums][WBBaggageDatum];
    [bags setArm:@([[baggageALabel text] floatValue])];

        
    Datum *few = [aircraft datums][WBFuelDatum];
    [few setArm: @([[fuelAlabel text] floatValue])];

    Datum *tks = [aircraft datums][WBTKSDatum];
    [tks setArm:@([[tksALabel text] floatValue])];
    [aircraft setMaxTKS:@([[tksWLabel text]floatValue])];
    
    Datum *o2 = [aircraft datums][WBOxygenDatum];
    [o2 setArm:@([[o2ALabel text]floatValue])];
    [aircraft setMaxO2:@([[o2WLabel text]floatValue])];
    
    [aircraft setMaxFuel:@([[fuelCLabel text] floatValue])];
    [aircraft setMaxBaggage:@([[maxBaggageWt text]floatValue])];
    [aircraft setMaxGross:@([[mgwLabel text]floatValue])];

}


- (IBAction)backgroundTapped:(id)sender {
       [[self view] endEditing:YES];
 }

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editAircraftEnvelope"]) {
        EnvelopeViewController *evc = segue.destinationViewController;
        evc.envelope = aircraft.envelope;
        evc.maxGross = aircraft.maxGross;
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
    
    CGFloat newTop = applicationFrame.origin.y+navigationFrame.size.height;
    
    scrollView.contentSize = newContentSize;
    
    [scrollView setContentOffset:(CGPointMake(0.0, -newTop)) animated:NO];

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
