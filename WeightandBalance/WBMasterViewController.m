//
//  WBMasterViewController.m
//  WeightandBalance
//
//  Created by Adam on 4/27/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import "WBMasterViewController.h"
#import "AircraftTabViewController.h"
#import "WBTypeSelectViewController.h"



@implementation WBMasterViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Aircraft", @"Aircraft");
    }
    return self;
}
							


/*- (void)insertNewObject:(id)sender
{
    
    WBTypeSelectViewController *typeSelectView = [[WBTypeSelectViewController alloc]init];
    [self.navigationController pushViewController:typeSelectView animated:YES];
    
}
*/



-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self tableView] reloadData];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[AircraftStore defaultStore] allAircraft] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    Aircraft *a = [[AircraftStore defaultStore] allAircraft][[indexPath row]];
    
    NSString *tail = [a tailNumber];
    NSString *type = [a typeName];
    
    
    cell.textLabel.text = tail;
    cell.detailTextLabel.text = type;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Aircraft *a = [[AircraftStore defaultStore] allAircraft][[indexPath row]];
        [[AircraftStore defaultStore] removeAircraft:a];

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}


/*
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [[AircraftStore defaultStore] moveAircraftAtIndex:[fromIndexPath row] To:[toIndexPath row]];

}
*/


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"selectAircraft"])
    {
        NSIndexPath *index = [self.tableView indexPathForSelectedRow];
        AircraftTabViewController *tvc = segue.destinationViewController;
        
        Aircraft *chosen = [[AircraftStore defaultStore] allAircraft][[index row]];
        [tvc setTitle:[chosen tailNumber]];
        tvc.aircraft = chosen;
        tvc.createNew = NO;
    }
    else if ([segue.identifier isEqualToString:@"addAircraft"])
        {

        }
    
}

@end
