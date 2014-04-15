//
//  TypeStore.h
//  WeightandBalance
//
//  Created by Adam on 5/11/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AircraftType;

@interface TypeStore : NSObject 

{
    NSMutableArray *allTypes;
}

+(TypeStore *)defaultStore;
-(NSMutableArray *)allTypes;
-(AircraftType *) createType;
-(void) addType:(AircraftType *)a;
-(void) removeType: (AircraftType *)a;
-(void) moveAircraftTypeAtIndex:(long)from
                             To:(long)to;
-(BOOL) saveChanges;
-(NSString *)itemArchivePath;   // returns the path to the type archive file

@end
