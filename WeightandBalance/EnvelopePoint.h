//
//  EnvelopePoint.h
//  weightAndBalance
//
//  Created by Adam on 4/9/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EnvelopePoint : NSObject  <NSCoding>

@property NSNumber *weight, *arm;

-(float) moment;
-(float) weightAsFloat;
-(float) armAsFloat;
@end
