//
//  WBTypeSelectViewController.m
//  WeightandBalance
//
//  Created by Adam on 5/11/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import "WBTypeSelectViewController.h"
#import "TypeStore.h"
#import "AircraftType.h"
#import "WBTypeEditViewController.h"
#import "Aircraft.h"
#import "AircraftStore.h"


@interface WBTypeSelectViewController ()

@end

@implementation WBTypeSelectViewController

@synthesize typeTableView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
         self.title = NSLocalizedString(@"Aircraft Types", @"Aircraft Types");
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];

    self.navigationItem.rightBarButtonItems = @[self.editButtonItem,addButton];
    
    //set the cell up
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[TypeStore defaultStore] allTypes] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier                forIndexPath:indexPath];

    
    //Add buttons
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [editButton addTarget:self
                   action:@selector(editType:)
	 forControlEvents:UIControlEventTouchUpInside];
	editButton.frame = CGRectMake(200.0f, 5.0f, 50.0f, 30.0f);
    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
	[cell addSubview:editButton];
    [editButton setHidden:NO];
    
    UIButton *useButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [useButton addTarget:self
                   action:@selector(selectType:)
         forControlEvents:UIControlEventTouchUpInside];
	useButton.frame = CGRectMake(260.0f, 5.0f, 50.0f, 30.0f);
    [useButton setTitle:@"Use" forState:UIControlStateNormal];
	[cell addSubview:useButton];
    [useButton setHidden:NO];
    
    
    // Configure the cell...
    cell.textLabel.text = [[[TypeStore defaultStore]allTypes][indexPath.row] typeName];
    
    return cell;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        AircraftType *t = [[TypeStore defaultStore]allTypes][indexPath.row];
        [[[TypeStore defaultStore]allTypes]removeObject:t];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        AircraftType *t = [[AircraftType alloc]init];
        WBTypeEditViewController *blankType = [[WBTypeEditViewController alloc]init];
        blankType.type = t;
        [self.navigationController pushViewController:blankType animated:YES];
        [[TypeStore defaultStore]addType:t];
    }   
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
    [[TypeStore defaultStore]moveAircraftTypeAtIndex:fromIndexPath.row To:toIndexPath.row];
    
    
}


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

-(void) insertNewObject:(id)sender
{
    AircraftType *t = [[AircraftType alloc]init];
    WBTypeEditViewController *blankType = [[WBTypeEditViewController alloc]init];
    blankType.type = t;
    [self.navigationController pushViewController:blankType animated:YES];
    [[TypeStore defaultStore]addType:t];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

}

-(void) editType:(id) sender
{
    //Get the superview from this button which will be our cell...keep moving up the view hierarchy until we hit a UITableViewCell
    
	UITableViewCell *owningCell = (UITableViewCell*)[[sender superview]superview];
    
	//From the cell get its index path.
    
    
	NSIndexPath *pathToCell = [typeTableView indexPathForCell:owningCell];
    AircraftType *chosen = [[TypeStore defaultStore]allTypes][pathToCell.row];
    
    [self performSegueWithIdentifier:@"EditType" sender:chosen];
     
}


-(void) selectType:(id) sender
{
    //Get the superview from this button which will be our cell
	UITableViewCell *owningCell = (UITableViewCell*)[[sender superview]superview];
	//From the cell get its index path.
	NSIndexPath *pathToCell = [typeTableView indexPathForCell:owningCell];
    
    AircraftType *chosen = [[TypeStore defaultStore]allTypes][pathToCell.row];
    Aircraft *aircraftOfType = [[Aircraft alloc]initSelfWithType:chosen.typeName andTail:@"New"];
    [[AircraftStore defaultStore] addAircraft:aircraftOfType];
    [self.navigationController popToRootViewControllerAnimated:TRUE ];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"EditType"]){
        WBTypeEditViewController *wb = segue.destinationViewController;
        if ([sender class] == [AircraftType class]) {
            wb.type = sender;
        }
        
    }
}

@end
