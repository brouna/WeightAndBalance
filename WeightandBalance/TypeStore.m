//
//  TypeStore.m
//  WeightandBalance
//
//  Created by Adam on 5/11/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import "TypeStore.h"
#import "AircraftType.h"

@implementation TypeStore


+(TypeStore *)defaultStore;
{
    static TypeStore *defaultStore;
    if (!defaultStore) {
        defaultStore = [[super alloc] init];
    }
    return defaultStore;
    
}

- (id)init
{
    self = [super init];
    if (self) {
        NSString *path = [self itemArchivePath];
        allTypes = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (!allTypes)
            allTypes = [[NSMutableArray alloc] init];
    }
    return self;
    
}



-(NSMutableArray *)allTypes;
{ return allTypes; }

-(AircraftType *) createType;
{
    AircraftType *a = [[AircraftType alloc]init];
    [allTypes addObject:a];
    return a;
    
}


-(void) addType:(AircraftType *)a;
{ [allTypes addObject:a];}

-(void) removeType: (AircraftType *)a;
{ [allTypes removeObject:a];}


-(void) moveAircraftTypeAtIndex:(int)from
                             To:(int)to;

{   if (from != to) {
        AircraftType *a = allTypes[from];
        [allTypes removeObjectAtIndex:from];
        [allTypes insertObject:a atIndex:to];
    }
}
-(BOOL) saveChanges;
{
    NSString *path = [self itemArchivePath];
    return [NSKeyedArchiver archiveRootObject:allTypes
                                       toFile:path];
}

-(NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentDirectory = documentDirectories[0];
    return [documentDirectory stringByAppendingPathComponent:@"types.archive"];
}

@end
