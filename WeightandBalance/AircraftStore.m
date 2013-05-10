//
//  AircraftStore.m
//  WeightandBalance
//
//  Created by Adam on 4/27/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import "AircraftStore.h"

@implementation AircraftStore


+(AircraftStore *) defaultStore
{
    static AircraftStore *defaultStore;
    if (!defaultStore){
        defaultStore = [[super alloc] init];
    }

    return defaultStore;
}

-(id)init
{
    self = [super init];
    if (self) {
        NSString *path = [self itemArchivePath];
        allAircraft = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        if (!allAircraft)
            allAircraft = [[NSMutableArray alloc] init];
        
    }
    return self;
}


-(NSMutableArray *)allAircraft
{
    return allAircraft;
}



-(void) addAircraft:(Aircraft *)a
{
    [allAircraft addObject:a];
}

-(Aircraft *) createAircraft
{
    Aircraft *a = [[Aircraft alloc]init];
    [allAircraft addObject:a];
    return a;
}


-(void) removeAircraft: (Aircraft *)a
{
    [allAircraft removeObject:a];
}


-(void) moveAircraftAtIndex:(int)from
                         To:(int)to

{
    if (from == to)
        return;
        
    Aircraft *p = [allAircraft objectAtIndex:from];
    [allAircraft removeObjectAtIndex:from];
    [allAircraft insertObject:p atIndex:to];

}

-(BOOL) saveChanges
{
    NSString *path = [self itemArchivePath];
    return [NSKeyedArchiver archiveRootObject:allAircraft
                                       toFile:path];
    
}

-(NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentDirectory = documentDirectories[0];
    return [documentDirectory stringByAppendingPathComponent:@"aircraft.archive"];
}


@end
