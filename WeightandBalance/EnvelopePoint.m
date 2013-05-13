//
//  EnvelopePoint.m
//  weightAndBalance
//
//  Created by Adam on 4/9/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import "EnvelopePoint.h"

@implementation EnvelopePoint

@synthesize weight,arm;

-(float) moment
{
    return [weight floatValue]*[arm floatValue];
}


-(id)copyWithZone:(NSZone *)zone
{
    EnvelopePoint *new = [[EnvelopePoint allocWithZone:zone]init];
    new.weight = [weight copy];
    new.arm = [arm copy];
    return new;
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:weight forKey:@"EWeight"];
    [aCoder encodeObject:arm forKey:@"EArm"];
    
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setWeight:[aDecoder decodeObjectForKey:@"EWeight"]];
        [self setArm:[aDecoder decodeObjectForKey:@"EArm"]];
    }
    return self;
}

-(float) weightAsFloat
{
    return [weight floatValue];
}

-(float) armAsFloat
{
    return [arm floatValue];
}


@end
