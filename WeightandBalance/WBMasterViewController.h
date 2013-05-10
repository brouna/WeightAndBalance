//
//  WBMasterViewController.h
//  WeightandBalance
//
//  Created by Adam on 4/27/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Aircraft.h"
#import "AircraftStore.h"


@class AircraftTabViewController;

@interface WBMasterViewController : UITableViewController

@property (strong, nonatomic) AircraftTabViewController *tvc;

@end
