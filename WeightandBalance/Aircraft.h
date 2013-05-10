//
//  Aircraft.h
//  weightAndBalance
//
//  Created by Adam on 4/3/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Datum.h"
#import "BalanceResult.h"

@interface Aircraft : NSObject <NSCoding>


@property  (nonatomic, strong) NSString *tailNumber;
@property (nonatomic, strong) NSString *typeName;
@property (nonatomic, strong) NSNumber *maxGross, *maxFuel, *maxBaggage, *maxTKS, *maxO2;
@property (nonatomic, strong) NSNumber *frontArm, *backArm;
@property (nonatomic, strong) NSNumber *pilotWt, *coPilotWt, *secRowLeftWt, *secRowRightWt;

@property (nonatomic, strong) NSMutableDictionary *datums;
@property (nonatomic, strong) NSMutableArray *envelope;  //will hold an array of envelope points

-(float) totalMoment;  //will return the total moment of the plane
-(float) totalWeight;  // will return the total weight of the plane
-(BOOL) isFuelWithinLimits;
-(BOOL) isBaggageWithinLimits;

-(BalanceResult *) isAircraftInBalance;   //will test and return if the current loading is safe

-(id) initSelfWithType: (NSString *)myType andTail: (NSString *)myTail;


@end
