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
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //create the tab bar by creating an array of view controllers
    
    AircraftViewController *avc = [[AircraftViewController alloc]initWithNibName:@"AircraftViewController" bundle:nil];
    [avc setEditing:YES];
    [avc setTabBarItem: [[UITabBarItem alloc] initWithTitle:@"Edit" image:[UIImage imageNamed:@"editplane30x30.png"] tag:0] ];
    [avc setAircraft:aircraft];
    [avc setCreateNew:createNew];
    [avc setTitle:(createNew ? @"New Aircraft" : [@"Edit " stringByAppendingString:([aircraft tailNumber]?[aircraft tailNumber]:@"")])];
    
    AircraftLoadViewController *lvc = [[AircraftLoadViewController alloc]initWithNibName:@"AircraftLoadViewController" bundle:nil];
    [lvc setEditing:YES];
    [lvc setTabBarItem:[[UITabBarItem alloc]initWithTitle:@"Load" image:[UIImage imageNamed:@"loadplane30x30.png"] tag:1]];
    [lvc setAircraft:aircraft];
   
    NSArray *vcs = @[lvc, avc];
    [self setViewControllers:vcs];
    if (createNew)
        [self setSelectedViewController:avc];       //For new ac, start on the edit tab
        

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
