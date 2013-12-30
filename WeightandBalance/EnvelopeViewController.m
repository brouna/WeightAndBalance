//
//  EnvelopeViewController.m
//  WeightandBalance
//
//  Created by Adam on 4/30/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "EnvelopeViewController.h"
#import "EnvelopePoint.h"
#import "EnvelopeCell.h"
#import "EnvelopeGraph.h"
#import "Aircraft.h"


@interface EnvelopeViewController ()

@end

@implementation EnvelopeViewController

{ EnvelopePoint *currentEP;    // will hold the selected row's envelope point for the purposes of editing
}
@synthesize envelope, maxGross;
@synthesize envTableView, envelopePopoverView, popoverArm, popoverWeight, envelopePopoverSmallView, graphInset;


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Envelope"];

    [envelopePopoverView setHidden:YES];
    
    UIToolbar *accessory = [self createToolBar];
    popoverArm.inputAccessoryView = accessory;  // add the +/- button to the arm field
        
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTable:)];
    [[self navigationItem] setRightBarButtonItems:@[editButton,addButton]];

    [graphInset setEnvelope:envelope];
    [graphInset setCurrentLoading:nil];
 
}



#pragma mark - Table view data source

-(void) insertNewObject:(id) sender
{
    EnvelopePoint *newEp = [[EnvelopePoint alloc] init];
    [newEp setArm:@0.0f];
    [newEp setWeight:@0.0f];
    
    [envelope addObject:newEp];
    
    [envTableView reloadData];
    [graphInset setNeedsDisplay];
    
}

-(void) editTable:(id) sender
{
    [envTableView setEditing:(![envTableView isEditing]) animated:YES];
    
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTable:)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editTable:)];
    
    if ([envTableView isEditing])
        [[self navigationItem] setRightBarButtonItems:@[doneButton]];
    else
        [[self navigationItem] setRightBarButtonItems:@[editButton,addButton]];
    
}



-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [envTableView reloadData];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    graphInset = nil;
    envTableView = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [envelope count];
}

- (EnvelopeCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EnvelopeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EnvelopeCell" forIndexPath:indexPath];
    
    // Configure the cell...
    EnvelopePoint *ep = envelope[indexPath.row];
    
    [cell.weightLabel setText:[NSString stringWithFormat:@"%1.1f",[[ep weight]floatValue]]];
    [cell.armLabel setText:[NSString stringWithFormat:@"%1.1f",[[ep arm] floatValue]]];
    [cell.weightWarning setHidden:([[ep weight]floatValue]<=[[self maxGross] floatValue])];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [envelope removeObjectAtIndex:[indexPath row]];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [graphInset setNeedsDisplay];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        EnvelopePoint *newEp = [[EnvelopePoint alloc]init];
        [envelope insertObject:newEp atIndex:[indexPath row]];
        [graphInset setNeedsDisplay];
    }   
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (fromIndexPath != toIndexPath) {
    EnvelopePoint *p = envelope [fromIndexPath.row];
    
        [envelope removeObjectAtIndex:[fromIndexPath row]];
        [envelope insertObject:p atIndex:[toIndexPath row]];
        [graphInset setNeedsDisplay];
    
    }
}


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
   [[self view] bringSubviewToFront:envelopePopoverView];
    [envelopePopoverView setHidden:NO];
    [envelopePopoverView setAlpha:1.0];
    [envelopePopoverView setExclusiveTouch:YES];
    [envelopePopoverView setUserInteractionEnabled:YES];
    [envelopePopoverSmallView setHidden:NO];
    [envelopePopoverSmallView setAlpha:1.0];
    
    //add a shadow on the inner view
    envelopePopoverSmallView.layer.shadowColor = [[UIColor blackColor] CGColor];
    envelopePopoverSmallView.layer.shadowOpacity = 0.7;
    envelopePopoverSmallView.layer.shadowRadius = 4.0;
    envelopePopoverSmallView.layer.shadowOffset = CGSizeMake(5.0f, 5.0f);
    envelopePopoverSmallView.layer.shadowPath = [UIBezierPath bezierPathWithRect:envelopePopoverSmallView.bounds].CGPath;

    
    //grab the current data and put it in the fields
    if (!currentEP) currentEP = [[EnvelopePoint alloc]init];
    
    currentEP =  envelope[indexPath.row];
    
    [popoverWeight setText:[NSString stringWithFormat:@"%1.1f",[[currentEP weight]floatValue]]];
    [popoverArm setText:[NSString stringWithFormat:@"%1.1f",[[currentEP arm]floatValue]]];
    
    [popoverArm setDelegate:self];
    [popoverWeight setDelegate:self];
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

- (IBAction)dismissPopover {
    [currentEP setArm:@([[popoverArm text]floatValue])];
    [currentEP setWeight:@([[popoverWeight text]floatValue])];
    
    [popoverWeight resignFirstResponder];
    [popoverWeight resignFirstResponder];
    
    [envelopePopoverView setExclusiveTouch:NO];
    [envelopePopoverView setUserInteractionEnabled:NO];
    [envelopePopoverView setHidden:YES];
    [[self view] sendSubviewToBack:envelopePopoverView];
    [envTableView reloadData];
    [graphInset setNeedsDisplay];
    
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
    
    if (popoverArm.isFirstResponder){
        if ([[popoverArm text] floatValue] != 0 )
        {
            popoverArm.text = [NSString stringWithFormat:@"%1.1f", (-1 * [[popoverArm text]floatValue])];
        }
    }
    
}

@end
