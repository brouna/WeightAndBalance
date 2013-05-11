//
//  AircraftLoadViewController.m
//  WeightandBalance
//
//  Created by Adam on 4/28/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import "AircraftLoadViewController.h"
#import "Aircraft.h"
#import "Datum.h"
#import "EnvelopePoint.h"
#import "EnvelopeGraph.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface AircraftLoadViewController ()  <MFMailComposeViewControllerDelegate>



@end

@implementation AircraftLoadViewController
@synthesize frontRowLeftLabel, frontRowRightLabel, secondRowLeftLabel, secondRowRightLabel, baggage, fuelQty, inTotalLimitsLabel, bagErrorLabel, fuelErrorLabel, envelopeLimitsLabel, graphInset, tksSwitch, o2Switch;

@synthesize aircraft;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
 //       graphInset = [[EnvelopeGraph alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	//load up the fields if there's data to be had
    [frontRowLeftLabel setText:[NSString stringWithFormat:@"%1.0f",[[aircraft pilotWt]floatValue]]];
    [frontRowRightLabel setText:[NSString stringWithFormat:@"%1.0f",[[aircraft coPilotWt]floatValue]]];
    [secondRowLeftLabel setText:[NSString stringWithFormat:@"%1.0f",[[aircraft secRowLeftWt]floatValue]]];
    [secondRowRightLabel setText:[NSString stringWithFormat:@"%1.0f",[[aircraft secRowRightWt]floatValue]]];
    [baggage setText:[NSString stringWithFormat:@"%1.0f",[[[aircraft datums][WBBaggageDatum]quantity]floatValue]]];
    [fuelQty setText:[NSString stringWithFormat:@"%1.0f",[[[aircraft datums][WBFuelDatum] quantity] floatValue]]];
    [tksSwitch setOn:([[aircraft datums][WBTKSDatum]quantity]!=0)];
    [o2Switch setOn:([[aircraft datums][WBOxygenDatum]quantity]!=0)];
    
    
    [frontRowLeftLabel setDelegate:self];
    [frontRowRightLabel setDelegate:self];
    [secondRowRightLabel setDelegate:self];
    [secondRowLeftLabel setDelegate:self];
    [baggage setDelegate:self];
    [fuelQty setDelegate:self];
    
   
    [self checkLimits];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [graphInset setAircraft:aircraft];
    
    EnvelopePoint *loadPoint = [[EnvelopePoint alloc] init];
    [loadPoint setWeight:@([aircraft totalWeight])];
    [loadPoint setArm:@([aircraft totalMoment]/[aircraft totalWeight])];
    
    [graphInset setCurrentLoading:loadPoint];
    [graphInset setNeedsDisplay];
    
    [self checkLimits];
    [[self view] setNeedsDisplay];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self view] endEditing:YES];
    [self updateAircraft];
     
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)backgroundTapped:(id)sender {
    [[self view] endEditing:YES];
    [self updateAircraft];
    [graphInset setNeedsDisplay];
    [self checkLimits];
}


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self updateAircraft];
    [self checkLimits];
    [graphInset setNeedsDisplay];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];  //make the keyboard vanish
    [self checkLimits];
    [graphInset setNeedsDisplay];
    return YES;
}


-(void) updateAircraft
{
    // store the fields
    [aircraft setPilotWt:@([[frontRowLeftLabel text] floatValue])];
    [aircraft setCoPilotWt:@([[frontRowRightLabel text] floatValue])];
    [aircraft setSecRowLeftWt:@([[secondRowLeftLabel text] floatValue])];
    [aircraft setSecRowRightWt:@([[secondRowRightLabel text] floatValue])];
    [[aircraft datums ][WBBaggageDatum] setQuantity:@([[baggage text] floatValue])];
    [[aircraft datums][WBFuelDatum]setQuantity:@([[fuelQty text]floatValue])];
    [[aircraft datums][WBTKSDatum] setQuantity:([tksSwitch isOn] ? [aircraft maxTKS] : 0)];
    [[aircraft datums][WBOxygenDatum] setQuantity:([o2Switch isOn] ? [aircraft maxO2] : 0)];
    
    EnvelopePoint *loadPoint = [[EnvelopePoint alloc] init];
    [loadPoint setWeight:@([aircraft totalWeight])];
    [loadPoint setArm:@([aircraft totalMoment]/[aircraft totalWeight])];
    
    [graphInset setCurrentLoading:loadPoint];
    
}

-(void) updateSwitches
{
    [self updateAircraft];
    [self checkLimits];
    [graphInset setNeedsDisplay];
}

- (IBAction)mailLoading {       //create an email with the current loading for audit purposes

    if ([MFMailComposeViewController canSendMail]) {                //make sure the device can support it
         MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
        [mailView setMailComposeDelegate:self];
        
        NSString *subject =[NSString stringWithFormat:@"Weight and balance for %@",[aircraft tailNumber]];
        [mailView setSubject:subject];
        
        NSDate *today = [NSDate date];
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setDateStyle:NSDateFormatterFullStyle];
        [df setTimeStyle:NSDateFormatterFullStyle];
        
        
        NSString *text = [NSString stringWithFormat:@"Weight and Balance Calculaction\n=============================\n\nCalculated on %@\nFor %@ %@\n\n", [df stringFromDate:today], [aircraft typeName], [aircraft tailNumber]];
  
        
        text = [text stringByAppendingFormat: @"Front row:%5.1f lbs %5.1f in\n",[[aircraft pilotWt]floatValue]+[[aircraft coPilotWt]floatValue],[[aircraft frontArm]floatValue]];
        text = [text stringByAppendingFormat: @"Second row:%5.1f lbs %5.1f in\n",[[aircraft secRowLeftWt]floatValue]+[[aircraft secRowRightWt]floatValue],[[aircraft backArm]floatValue]];
        for (NSString *k in [aircraft datums]){
            Datum *d = [aircraft datums][k];
            text = [text stringByAppendingFormat: @"%18@:%5.1f lbs %5.1f in\n",[d name],[d weightAsFloat],[d armAsFloat]];
        }
        text = [text stringByAppendingFormat:@"--------------------------------------\nTotal Weight:%5.1f lbs  Arm:%5.1f in  Moment/1000:%5.1f \n\n",[aircraft totalWeight], [aircraft totalMoment]/[aircraft totalWeight],[aircraft totalMoment]/1000];
    
        
        [mailView setMessageBody:text isHTML:NO];
        [self presentViewController:mailView animated:YES completion:nil];
        mailView=nil;
        
    }
    
}

-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(void) checkLimits {

    //First check fuel and baggage
    [bagErrorLabel setHidden:[aircraft isBaggageWithinLimits]];
    [fuelErrorLabel setHidden:[aircraft isFuelWithinLimits]];
    
    
    //Now mgw
    if ([aircraft totalWeight] > [[aircraft maxGross] floatValue]) {
        CGFloat overage = [aircraft totalWeight] - [[aircraft maxGross] floatValue];
        
        [inTotalLimitsLabel setText:[NSString stringWithFormat:@"%1.0flbs over Max Weight!",overage]];
        [inTotalLimitsLabel setHidden:NO];
        [inTotalLimitsLabel setTextColor:[UIColor redColor]];
        
    } else {
        [inTotalLimitsLabel setText:[NSString stringWithFormat:@"Within max gross weight"]];
        [inTotalLimitsLabel setHidden:NO];
        [inTotalLimitsLabel setTextColor:[UIColor greenColor]];
    }
    
    [envelopeLimitsLabel setText:[[aircraft isAircraftInBalance] result]];
    
    [envelopeLimitsLabel setTextColor: ([[envelopeLimitsLabel text] isEqualToString:@"In Balance"] ?
                                        [UIColor greenColor] :
                                        [UIColor redColor])];
    
    
    
    return;
}

@end
