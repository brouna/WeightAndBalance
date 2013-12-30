//
//  AircraftType.m
//  weightAndBalance
//
//  Created by Adam on 4/3/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import "AircraftType.h"
#import "Datum.h"
#import "EnvelopePoint.h"

@implementation AircraftType



-(id) initWithName: (NSString *)newName
{
    self = [super init];
    if (self)
    {
        _typeName = newName;
        _envelope = [[NSMutableArray alloc]init]; //will hold the envelope points
        [_envelope addObject:[[EnvelopePoint alloc]init]]; //add a blank envelope point
        
        _datums = [[NSMutableDictionary alloc]initWithObjects:@[
                           [[Datum alloc]initWithName:WBBasicEmptyDatum Quantity:@0 WeightPerQuantity:@1 andArm:@0.0f],
                           [[Datum alloc]initWithName:WBFuelDatum Quantity:@0 WeightPerQuantity: FUEL_LBS_PER_GALLON andArm:@0.0f],
                           [[Datum alloc]initWithName:WBTKSDatum Quantity:@0 WeightPerQuantity:TKS_LBS_PER_GALLON andArm:@0.0f],
                           [[Datum alloc]initWithName:WBOxygenDatum Quantity:@0 WeightPerQuantity:@1 andArm:@0.0f],
                           [[Datum alloc]initWithName:WBBaggageDatum Quantity:@0 WeightPerQuantity:@1 andArm:@0.0f]]
                        forKeys:@[WBBasicEmptyDatum,WBFuelDatum,WBTKSDatum, WBOxygenDatum, WBBaggageDatum]];
    }
    return self;
}

-(id) init
{
    self= [self initWithName:@""];
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_typeName forKey:@"typeName"];
    [aCoder encodeObject:_maxGross forKey:@"maxGross"];
    [aCoder encodeObject:_maxFuel forKey:@"maxFuel"];
    [aCoder encodeObject:_maxBaggage forKey:@"maxBaggage"];
    [aCoder encodeObject:_frontArm forKey:@"frontArm"];
    [aCoder encodeObject:_backArm forKey:@"backArm"];
    [aCoder encodeObject:_maxTKS forKey:@"MaxTKS"];
    [aCoder encodeObject:_maxO2 forKey:@"MaxO2"];
    [aCoder encodeObject:_envelope forKey:@"envelope"];
    [aCoder encodeObject:_datums forKey:@"datums"];
    
    
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _typeName = [aDecoder decodeObjectForKey:@"typeName"];
        _maxGross =[aDecoder decodeObjectForKey:@"maxGross"];
        _maxFuel =[aDecoder decodeObjectForKey:@"maxFuel"];
        _maxBaggage =[aDecoder decodeObjectForKey:@"maxBaggage"];
        _frontArm =[aDecoder decodeObjectForKey:@"frontArm"];
        _backArm =[aDecoder decodeObjectForKey:@"backArm"];
        _maxTKS=[aDecoder decodeObjectForKey:@"MaxTKS"];
        _maxO2=[aDecoder decodeObjectForKey:@"MaxO2"];
        _envelope=[aDecoder decodeObjectForKey:@"envelope"];
        _datums=[aDecoder decodeObjectForKey:@"datums"];
    }
    return self;
}



@end
