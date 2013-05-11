//
//  Datum.m
//  weightAndBalance
//
//  Created by Adam on 4/2/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import "Datum.h"

@implementation Datum

NSString * const WBBasicEmptyDatum=@"Basic Empty",
         * const WBFuelDatum=@"Fuel",
         * const WBTKSDatum=@"TKS",
         * const WBOxygenDatum=@"Oxygen",
         * const WBBaggageDatum=@"Baggage";

@synthesize name, quantity, weightPerQuantity, arm;


-(id) initWithName:(NSString *)n
{
    
    self = [super init];
    if (self) {
        // set up the quantities as the right kind of number
        [self setName:n];
        [self setQuantity:@1.0f];
        [self setWeightPerQuantity:@1.0f];
        [self setArm:@0.0f];
    }
    return self;

    
}

- (id)init
{
    return [self initWithName:@"Unknown"];
}

-(id) copyWithZone:(NSZone *)zone
{
    return  self;
}

-(float)weightAsFloat
{
    return [quantity floatValue] * [weightPerQuantity floatValue];
}

-(float)armAsFloat

{
    return [arm floatValue];
}

- (float) moment {
    return [quantity floatValue]*[weightPerQuantity floatValue]* [arm floatValue];
}



-(id) initWithName:(NSString *)n Quantity:(NSNumber *)q WeightPerQuantity:(NSNumber *)wpq andArm:(NSNumber *)a
{
    self = [self initWithName:n];
    [self setQuantity:q];
    [self setWeightPerQuantity:wpq];
    [self setArm:a];
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:name forKey:@"DatumName"];
    [aCoder encodeObject:quantity forKey:@"DatumQuantity"];
    [aCoder encodeObject:weightPerQuantity forKey:@"DatumWPQ"];
    [aCoder encodeObject:arm forKey:@"DatumArm"];
    
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setName:[aDecoder decodeObjectForKey:@"DatumName"]];
        [self setQuantity :[aDecoder decodeObjectForKey:@"DatumQuantity"]];
        [self setWeightPerQuantity :[aDecoder decodeObjectForKey:@"DatumWPQ"]];
        [self setArm:[aDecoder decodeObjectForKey:@"DatumArm"]];
}
    return self;
}

@end
