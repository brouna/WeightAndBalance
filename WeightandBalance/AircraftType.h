//
//  AircraftType.h
//  weightAndBalance
//
//  Created by Adam on 4/3/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Datum;
@class NSString;

@interface AircraftType : NSObject

@property (copy) NSString *typeName;
@property (copy) Datum *basicEmptyMoment, *fuelMoment;
@property NSNumber *maxGross, *maxFuel, *maxBaggage, *fuelBurnRate;
@property NSNumber *frontArm, *backArm, *baggageArm;

@property (strong) NSMutableArray *envelope;  //will hold an array of envelope points



@end
