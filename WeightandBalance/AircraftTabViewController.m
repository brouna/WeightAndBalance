//
//  AircraftTabViewController.m
//  WeightandBalance
//
//  Created by Adam on 4/28/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import "AircraftTabViewController.h"
#import "AircraftLoadViewController.h"
#import "AircraftViewController.h"

@interface AircraftTabViewController ()

@end

@implementation AircraftTabViewController

@synthesize aircraft, createNew;

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
    AircraftLoadViewController *lvc;
    AircraftViewController *avc;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //  Look for an aircraft view controller and a load view controller in the tabs
        
    for (id thisVC in self.childViewControllers) {
        if ([thisVC isKindOfClass:[AircraftLoadViewController class]]) {
            lvc = thisVC;
            [lvc setEditing:YES];
            [lvc setTabBarItem:[[UITabBarItem alloc]initWithTitle:@"Load" image:[UIImage imageNamed:@"loadplane30x30.png"] tag:1]];
            [lvc setAircraft:aircraft];
            

        }
        if ([thisVC isKindOfClass:[AircraftViewController class]]) {
            avc = thisVC;
            [avc setEditing:YES];
            [avc setTabBarItem: [[UITabBarItem alloc] initWithTitle:@"Edit" image:[UIImage imageNamed:@"editplane30x30.png"] tag:0] ];
            [avc setAircraft:aircraft];
            [avc setCreateNew:createNew];
            [avc setTitle:[@"Edit " stringByAppendingString:([aircraft tailNumber]?[aircraft tailNumber]:@"")]];
            
        }
        
    }
    
    self.selectedIndex = (createNew ? 1 : 0);  //if the aircraft is new, start on the edit page, otherwise the load page

    
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}





@end
