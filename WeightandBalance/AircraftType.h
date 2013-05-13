//
//  AircraftType.h
//  weightAndBalance
//
//  Created by Adam on 4/3/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FUEL_LBS_PER_GALLON @6.0
#define TKS_LBS_PER_GALLON  @9.1


@class Datum;
@class NSString;


@interface AircraftType : NSObject <NSCoding>


@property (nonatomic, strong) NSString *typeName;
@property (nonatomic, strong) NSNumber *maxGross, *maxFuel, *maxBaggage, *maxTKS, *maxO2;
@property (nonatomic, strong) NSNumber *frontArm, *backArm;
@property (nonatomic, strong) NSMutableDictionary *datums;
@property (nonatomic, strong) NSMutableArray *envelope;  //will hold an array of envelope points
@end
