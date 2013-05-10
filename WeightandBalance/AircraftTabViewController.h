//
//  AircraftTabViewController.h
//  WeightandBalance
//
//  Created by Adam on 4/28/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Aircraft.h"
@interface AircraftTabViewController : UITabBarController

@property (strong, nonatomic)Aircraft *aircraft;

@property BOOL createNew;

@end
