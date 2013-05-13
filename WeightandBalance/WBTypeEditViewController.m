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
@synthesize scrollView;

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
    
    [_typeLabel setText:[_type typeName]];
    [_bewALabel setText:([bewa floatValue]==0 ? @"":[NSString stringWithFormat:@"%1.1f",[bewa floatValue]])];
    [_bewWlabel setText:([beww integerValue]==0 ? @"":[NSString stringWithFormat:@"%i",[beww integerValue]])];
    [_frontALabel setText:([fa floatValue]==0 ? @"":[NSString stringWithFormat:@"%1.1f",[fa floatValue]])];
    [_backALabel setText:([ba floatValue]==0 ? @"" :[NSString stringWithFormat:@"%1.1f",[ba floatValue]])];
    [_bagALabel setText:([bga floatValue]==0 ? @"" :[NSString stringWithFormat:@"%1.1f",[bga floatValue]])];
    [_fuelALabel setText:([fuela floatValue]==0 ? @"" : [NSString stringWithFormat:@"%1.1f",[fuela floatValue]])];
    [_fuelQlabel setText:([mf floatValue]==0 ? @"" :[NSString stringWithFormat:@"%1.1f",[mf floatValue]])];
    [_MGWLabel  setText:([mg integerValue]==0 ? @"" : [NSString stringWithFormat:@"%i",[mg integerValue]])];
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
    [_TKSQLabel setDelegate:self];
    [_TKSALabel setDelegate: self];
    [_O2ALabel setDelegate: self];
    [_O2WLabel setDelegate: self];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [scrollView setFrame:self.view.bounds];
    [scrollView setContentSize:CGSizeMake(320, 460)];
    

    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)backgroundTapped:(id)sender {
    [[self view] endEditing:YES];
    [scrollView setFrame:self.view.bounds];
}

- (IBAction)setEnvelope {
   EnvelopeViewController *evc = [[EnvelopeViewController alloc] init];
    evc.envelope = _type.envelope;
    evc.maxGross = _type.maxGross;
    [self.navigationController pushViewController:evc animated:YES];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [scrollView setFrame:self.view.bounds];
    [scrollView scrollRectToVisible:[textField frame] animated:YES];
    return YES;
}

@end
