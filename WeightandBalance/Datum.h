//
//  Datum.h
//  weightAndBalance
//
//  Created by Adam on 4/2/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Datum : NSObject <NSCoding, NSCopying>

extern  NSString  * const WBBasicEmptyDatum,
                  * const WBFuelDatum,
                  * const WBTKSDatum,
                  * const WBOxygenDatum,
                  * const WBBaggageDatum;

// quantity and weightperQuantity will be used e.g. for fuel (6 lbs/gallon).  A special case will then be binary (e.g. the pilot, which will always have a quantity of 1.
// arm is the arm in inches
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *quantity;
@property (strong, nonatomic) NSNumber *weightPerQuantity;
@property (strong, nonatomic) NSNumber *arm;


-(id) initWithName:(NSString *)n;  //designated initializer
-(id) initWithName:(NSString *)n Quantity:(NSNumber *)q WeightPerQuantity:(NSNumber *)wpq andArm:(NSNumber *)a;

-(float) weightAsFloat;
-(float) armAsFloat;
- (float) moment;  // returns the moment of the item (total weight * arm)

@end
