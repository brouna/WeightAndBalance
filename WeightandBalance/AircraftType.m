//
//  AircraftType.m
//  weightAndBalance
//
//  Created by Adam on 4/3/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import "AircraftType.h"
#import "Datum.h"

@implementation AircraftType

@synthesize typeName;
@synthesize basicEmptyMoment, fuelMoment;
@synthesize maxGross, maxFuel, maxBaggage, fuelBurnRate;
@synthesize frontArm, backArm, baggageArm;

-(id) initWithName: (NSString *)newName
{
    self = [super init];
    if (self)
    {
        [self setTypeName:newName];
        basicEmptyMoment  = [[Datum alloc] initWithName:@"Basic Empty"];
        
        fuelMoment = [[Datum alloc] initWithName:@"Fuel"];
        maxGross = [NSNumber numberWithFloat:0];
        maxFuel = [NSNumber numberWithFloat:0];
        maxBaggage = [NSNumber numberWithFloat:0];
        fuelBurnRate = [NSNumber numberWithFloat:0];
        frontArm = [NSNumber numberWithFloat:0];
        backArm = [NSNumber numberWithFloat:0];
        baggageArm = [NSNumber numberWithFloat:0];
    
    
        self.envelope = [[NSMutableArray alloc]init]; //will hold the envelope points
        
    }
    return self;
}

-(id) init
{
    self= [self initWithName:@""];
    return self;
}

@end
