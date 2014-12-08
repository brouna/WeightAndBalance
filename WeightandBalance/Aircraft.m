//
//  Aircraft.m
//  weightAndBalance
//
//  Created by Adam on 4/3/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import "Aircraft.h"
#import "Datum.h"
#import "AircraftType.h"
#import "EnvelopePoint.h"
#import "BalanceResult.h"
#import "TypeStore.h"
#import "WBGlobalConstants.h"

@implementation Aircraft


@synthesize tailNumber, typeName;
@synthesize maxGross, maxFuel, maxBaggage, maxO2, maxTKS;
@synthesize frontArm, backArm;
@synthesize pilotWt, coPilotWt, secRowLeftWt, secRowRightWt;
@synthesize envelope;
@synthesize datums;



- (id)init
{
    self = [super init];
    if (self) {
/*
 
 */
    }
    return self;
}

-(id) initSelfWithType:(NSString *)myType andTail:(NSString *)myTail
{
    self = [self init];
    if (self)
    {
        typeName = myType;
        tailNumber = myTail;
        BOOL foundTypeMatch = NO;
        
        // if an aircraftype exists, copy all its data, otherwise create a blank one
        for (AircraftType *at in [[TypeStore defaultStore]allTypes]) {
            if (at.typeName == myType){  //found a match
                maxGross = [at.maxGross copy];
                maxFuel = [at.maxFuel copy];
                maxBaggage = [at.maxBaggage copy];
                maxTKS = [at.maxTKS copy];
                maxO2 = [at.maxO2 copy];
                frontArm = [at.frontArm copy];
                backArm = [at.backArm copy];
                datums = [[NSMutableDictionary  alloc] initWithDictionary:at.datums copyItems:YES ];  //make sure we create a deep copy of the datums and envelope
                envelope = [[NSMutableArray alloc] initWithArray:at.envelope copyItems:YES];
                foundTypeMatch = YES;
            }
        }
        if (!foundTypeMatch) {
            Datum *bew = [[Datum alloc] initWithName:WBBasicEmptyDatum Quantity:@0.0 WeightPerQuantity:@1.0 andArm:@0.0];
            Datum *fuel = [[Datum alloc] initWithName:WBFuelDatum Quantity:@0.0 WeightPerQuantity:FUEL_LBS_PER_GALLON andArm:@0.0];
            Datum *tks =  [[Datum alloc] initWithName:WBTKSDatum Quantity:@0.0 WeightPerQuantity:TKS_LBS_PER_GALLON andArm:@0.0];
            Datum *o2 =  [[Datum alloc] initWithName:WBOxygenDatum Quantity:@0.0 WeightPerQuantity:@1.0 andArm:@0.0];
            Datum *bags = [[Datum alloc]initWithName:WBBaggageDatum Quantity:@0.0 WeightPerQuantity:@1.0 andArm:@0.0];
            
            datums = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      bew,  WBBasicEmptyDatum,
                      fuel, WBFuelDatum       ,
                      tks,  WBTKSDatum        ,
                      o2,   WBOxygenDatum     ,
                      bags, WBBaggageDatum    , nil];
            
            envelope = [[NSMutableArray alloc]init];
            [envelope addObject:[[EnvelopePoint alloc]init]];
        }
    
    }
    return self;
}

-(float) totalMoment;  //will return the total moment of the plane
{
    float total = 0;   //holds my running total
    
    //start with the datums
    for ( NSString *k in datums){
        Datum *d = datums[k];
        total +=  [[d quantity]floatValue] * [[d weightPerQuantity]floatValue] * [[d arm] floatValue];
        
    }
    
    //Front row
    total += ([pilotWt floatValue] + [coPilotWt floatValue]) * [frontArm floatValue];
    
    //Second row
    total += ([secRowLeftWt floatValue] + [secRowRightWt floatValue]) * [backArm floatValue];
    
   
    
    return total;
    
}

-(float) totalWeight;
{
    
    float total = 0;
    
    //Start with the datums
    for (NSString *d in datums) {
        total += [[datums[d] quantity]floatValue]  * [[datums[d] weightPerQuantity] floatValue];
    }
    
    //Front row
    total += [pilotWt floatValue] + [coPilotWt floatValue];
    
    //Second row
    total += [secRowLeftWt floatValue] + [secRowRightWt floatValue];

    
    return total;
    
}


-(BOOL) isFuelWithinLimits
{
    float fuelQt = [[datums[WBFuelDatum] quantity]floatValue];
    return (fuelQt <= [maxFuel floatValue]);
    
}

-(BOOL) isBaggageWithinLimits
{
    float bagWt = [[datums[WBBaggageDatum]quantity]floatValue];
    float maxBags = [maxBaggage floatValue];
    return (bagWt <= maxBags);
    
}


-(BalanceResult *)isAircraftInBalance;

{
//Now to see if the loading is in the envelope...we'll create a CGPath for the envelope.  We'll map arm to the x-coord and weight to the y-coord
    BalanceResult *result = [[BalanceResult alloc]init];

    if ([envelope count] >=3) {         //envelope must have at least 3 points to be worth it
        
        CGMutablePathRef envelopePath = CGPathCreateMutable();
        
        EnvelopePoint *startPoint = envelope[0];  //get the first point in the array
        
        CGPathMoveToPoint(envelopePath, NULL, [startPoint armAsFloat], [startPoint weightAsFloat]);
        for (EnvelopePoint *nextPoint in envelope)
            CGPathAddLineToPoint(envelopePath, NULL, [nextPoint armAsFloat], [nextPoint weightAsFloat]);
        
        CGPathCloseSubpath(envelopePath);
        
        // Now create a point representing the current loading...
        CGPoint loadPoint = CGPointMake([self totalMoment]/[self totalWeight], [self totalWeight]);
        NSLog(@"Weight is %1.1f and arm %1.1f",[self totalWeight], [self totalMoment]/[self totalWeight]);
        //And test if it's in the envelope!
        if(CGPathContainsPoint(envelopePath, NULL, loadPoint, NO))
             [result setResultForCondition:WBinBalanceCondition];
        
        else [result setResultForCondition:WBoutOfBalanceGeneric];
        
        CGPathRelease(envelopePath);
        }
        else [result setResultForCondition:WBinsufficientEnvelope];
    
    return result;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:tailNumber forKey:@"tailNumber"];
    [aCoder encodeObject:typeName forKey:@"typeName"];
    [aCoder encodeObject:maxGross forKey:@"maxGross"];
    [aCoder encodeObject:maxFuel forKey:@"maxFuel"];
    [aCoder encodeObject:maxBaggage forKey:@"maxBaggage"];
    [aCoder encodeObject:frontArm forKey:@"frontArm"];
    [aCoder encodeObject:backArm forKey:@"backArm"];
    [aCoder encodeObject:pilotWt forKey:@"pilotWt"];
    [aCoder encodeObject:coPilotWt forKey:@"coPilotWt"];
    [aCoder encodeObject:secRowLeftWt forKey:@"secRowLeftWt"];
    [aCoder encodeObject:secRowRightWt forKey:@"secRowRightWt"];
    [aCoder encodeObject:maxTKS forKey:@"MaxTKS"];
    [aCoder encodeObject:maxO2 forKey:@"MaxO2"];
    [aCoder encodeObject:envelope forKey:@"envelope"];
    [aCoder encodeObject:datums forKey:@"datums"];
    
  
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setTailNumber:[aDecoder decodeObjectForKey:@"tailNumber"]];
        [self setTypeName :[aDecoder decodeObjectForKey:@"typeName"]];
        [self setMaxGross :[aDecoder decodeObjectForKey:@"maxGross"]];
        [self setMaxFuel :[aDecoder decodeObjectForKey:@"maxFuel"]];
        [self setMaxBaggage :[aDecoder decodeObjectForKey:@"maxBaggage"]];
        [self setFrontArm :[aDecoder decodeObjectForKey:@"frontArm"]];
        [self setBackArm :[aDecoder decodeObjectForKey:@"backArm"]];
        [self setPilotWt :[aDecoder decodeObjectForKey:@"pilotWt"]];
        [self setCoPilotWt :[aDecoder decodeObjectForKey:@"coPilotWt"]];
        [self setSecRowLeftWt :[aDecoder decodeObjectForKey:@"secRowLeftWt"]];
        [self setSecRowRightWt :[aDecoder decodeObjectForKey:@"secRowRightWt"]];
        [self setMaxTKS:[aDecoder decodeObjectForKey:@"MaxTKS"]];
        [self setMaxO2:[aDecoder decodeObjectForKey:@"MaxO2"]];
        [self setEnvelope:[aDecoder decodeObjectForKey:@"envelope"]];
        [self setDatums:[aDecoder decodeObjectForKey:@"datums"]];
    }
    return self;
}




@end
