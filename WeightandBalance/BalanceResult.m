//
//  BalanceResult.m
//  WeightandBalance
//
//  Created by Adam on 5/2/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import "BalanceResult.h"

@implementation BalanceResult


const int   WBinBalanceCondition = 1,
            WBinsufficientEnvelope = 0,
            WBoutOfBalanceGeneric = 2,
            WBoutOfBalanceFore = 3,
            WBoutofBalanceAft = 4;

- (id)init
{
    self = [super init];
    if (self) {
        result = @"Unknown CG position";
    }
    return self;
}

-(void) setResultForCondition:(int)cond;
{
    switch (cond) {
        case WBinBalanceCondition:
            result =  @"In Balance";
            break;
        case WBinsufficientEnvelope:
            result = @"Insufficient Envelope";
            break;
        case WBoutOfBalanceGeneric:
            result = @"Out of Balance";
            break;
        case WBoutOfBalanceFore:
            result = @"CG too far foward";
            break;
        case WBoutofBalanceAft:
            result =@"CG too far aft";
            break;
        default:
            result=@"Unknown CG position";
            break;
    }
    
}

+(NSString *) resultForCondition:(int)cond
{
    switch (cond) {
        case WBinBalanceCondition:
            return  @"In Balance";
            break;
        case WBinsufficientEnvelope:
            return @"Insufficient Envelope";
            break;
        case WBoutOfBalanceGeneric:
            return  @"Out of Balance";
            break;
        case WBoutOfBalanceFore:
            return @"CG too far foward";
            break;
        case WBoutofBalanceAft:
            return @"CG too far aft";
            break;
        default:
            return @"Unknown CG position";
            break;
    }
}


-(NSString *) result
{
    return result;
}


@end
