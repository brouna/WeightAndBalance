//
//  BalanceResult.h
//  WeightandBalance
//
//  Created by Adam on 5/2/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const int  WBinBalanceCondition,
                 WBinsufficientEnvelope,
                 WBoutOfBalanceGeneric,
                 WBoutOfBalanceFore,
                 WBoutofBalanceAft;


@interface BalanceResult : NSObject

{ NSString *result; };

-(void) setResultForCondition:(int)cond;

+(NSString *) resultForCondition:(int)cond;

-(NSString *) result;

@end
