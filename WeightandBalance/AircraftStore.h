//
//  AircraftStore.h
//  WeightandBalance
//
//  Created by Adam on 4/27/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Aircraft.h"

@interface AircraftStore : NSObject

{
    NSMutableArray *allAircraft;           //not an @property as I want no setter and will write a getter

}

+(AircraftStore *)defaultStore;
-(NSMutableArray *)allAircraft;
-(Aircraft *) createAircraft;
-(void) addAircraft:(Aircraft *)a;
-(void) removeAircraft: (Aircraft *)a;
-(void) moveAircraftAtIndex:(int)from
                         To:(int)to;
-(BOOL) saveChanges;

@end
