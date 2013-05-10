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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    [scrollView setContentSize:CGSizeMake(320, 460)];
    
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
    [bewWLabel setText:([beww integerValue]==0 ? @"":[NSString stringWithFormat:@"%i",[beww integerValue]])];
    [frontALabel setText:([fa floatValue]==0 ? @"":[NSString stringWithFormat:@"%1.1f",[fa floatValue]])];
    [backALabel setText:([ba floatValue]==0 ? @"" :[NSString stringWithFormat:@"%1.1f",[ba floatValue]])];
    [baggageALabel setText:([bga floatValue]==0 ? @"" :[NSString stringWithFormat:@"%1.1f",[bga floatValue]])];
    [fuelAlabel setText:([fuela floatValue]==0 ? @"" : [NSString stringWithFormat:@"%1.1f",[fuela floatValue]])];
    [fuelCLabel setText:([mf floatValue]==0 ? @"" :[NSString stringWithFormat:@"%1.1f",[mf floatValue]])];
    [mgwLabel  setText:([mg integerValue]==0 ? @"" : [NSString stringWithFormat:@"%i",[mg integerValue]])];
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
    [mgwLabel setDelegate:self];
    [maxBaggageWt setDelegate:self];
    [tksWLabel setDelegate:self];
    [tksALabel setDelegate: self];
    [o2ALabel setDelegate: self];
    [o2WLabel setDelegate: self];
    }
    
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
        
    [scrollView setFrame:CGRectMake(0, 0, 320, 200)];
    [scrollView scrollRectToVisible:[textField frame] animated:YES];

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)backgroundTapped:(id)sender {
       [[self view] endEditing:YES];
        [scrollView setFrame:[_fullView bounds]];

}

- (IBAction)editEnvelope {
    EnvelopeViewController *evc = [[EnvelopeViewController alloc] init];

    [evc setAircraft:aircraft];
    [self.navigationController pushViewController:evc animated:YES];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [scrollView setFrame:[_fullView bounds]];
    [scrollView scrollRectToVisible:[textField frame] animated:YES];

    return YES;
}




@end
