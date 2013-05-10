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
@synthesize aircraft;
@synthesize envTableView, envelopePopoverView, popoverArm, popoverWeight, envelopePopoverSmallView, graphView ,tableHeaderLabel, graphInset;



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:[aircraft tailNumber]];
/*    if (!envTableView)
        envTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [self view].bounds.size.width, 270)];

    if (!graphView)
        graphView = [[UIView alloc]initWithFrame:CGRectMake(0, 270, [self view].bounds.size.width, 150)];
    
    if(!graphInset)
        graphInset = [[EnvelopeGraph alloc] init];
*/
    [envelopePopoverView setHidden:YES];
        
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTable:)];
    [[self navigationItem] setRightBarButtonItems:@[editButton,addButton]];
    
    //set the cell up
    //Load the NIB file to be our cell of choice
    UINib *nib = [UINib nibWithNibName:@"EnvelopeCell" bundle:nil];
        //register with the view controller
    [[self envTableView] registerNib:nib forCellReuseIdentifier:@"EnvelopeCell"];
    
    //assemble the views...
    [[self view] addSubview:envTableView];
    
    [graphInset setAircraft:aircraft];
    [graphInset setCurrentLoading:nil];
    [[self view] addSubview:graphView];
    [graphView setFrame:CGRectMake(0, 270, [self view].bounds.size.width, 150)];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    envelopePopoverView = nil;
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(void) insertNewObject:(id) sender
{
    EnvelopePoint *newEp = [[EnvelopePoint alloc] init];
    [newEp setArm:@0.0f];
    [newEp setWeight:@0.0f];
    
    [[aircraft envelope] addObject:newEp];
    
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
    graphView = nil;
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
    return [[aircraft envelope]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EnvelopeCell";
    EnvelopeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    [cell setEp:[aircraft envelope][[indexPath row]]];
    [cell setAircraft:aircraft];                    // cell needs the aircraft so it can warn about MGW overage
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
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
        [[aircraft envelope] removeObjectAtIndex:[indexPath row]];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [graphInset setNeedsDisplay];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        EnvelopePoint *newEp = [[EnvelopePoint alloc]init];
        [[aircraft envelope] insertObject:newEp atIndex:[indexPath row]];
        [graphInset setNeedsDisplay];
    }   
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (fromIndexPath != toIndexPath) {
    EnvelopePoint *p = [aircraft envelope][[fromIndexPath row]];
    
        [[aircraft envelope] removeObjectAtIndex:[fromIndexPath row]];
        [[aircraft envelope] insertObject:p atIndex:[toIndexPath row]];
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
 
    [[self view] addSubview:envelopePopoverView];
    [envelopePopoverView setHidden:NO];
    [envelopePopoverView setAlpha:1.0];
    [envelopePopoverView setUserInteractionEnabled:YES];
    [envelopePopoverView setExclusiveTouch:YES];
    
    
    //add a shadow on the inner view
    envelopePopoverSmallView.layer.shadowColor = [[UIColor blackColor] CGColor];
    envelopePopoverSmallView.layer.shadowOpacity = 0.7;
    envelopePopoverSmallView.layer.shadowRadius = 4.0;
    envelopePopoverSmallView.layer.shadowOffset = CGSizeMake(5.0f, 5.0f);
    envelopePopoverSmallView.layer.shadowPath = [UIBezierPath bezierPathWithRect:envelopePopoverSmallView.bounds].CGPath;

    
    //grab the current data and put it in the fields
    if (!currentEP) currentEP = [[EnvelopePoint alloc]init];
    
    currentEP = [aircraft envelope][[indexPath row]];
    
    [popoverWeight setText:[NSString stringWithFormat:@"%1.1f",[[currentEP weight]floatValue]]];
    [popoverArm setText:[NSString stringWithFormat:@"%1.1f",[[currentEP arm]floatValue]]];
    

}

- (IBAction)dismissPopover {
    [currentEP setArm:@([[popoverArm text]floatValue])];
    [currentEP setWeight:@([[popoverWeight text]floatValue])];
    
    [envelopePopoverView setExclusiveTouch:NO];
    [envelopePopoverView setHidden:YES];
    [envelopePopoverView removeFromSuperview];
    [[self envTableView] reloadData];
    [graphInset setNeedsDisplay];
    
}

@end
