//
//  WBAppDelegate.m
//  WeightandBalance
//
//  Created by Adam on 4/27/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import "WBAppDelegate.h"

#import "WBMasterViewController.h"
#import "AircraftStore.h"
#import "TypeStore.h"
#import "Aircraft.h"
#import "Datum.h"
#import "WBGlobalConstants.h"


@implementation WBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.

    
    [self loadInitialTypes];   
    
    
    WBMasterViewController *masterViewController = [[WBMasterViewController alloc] initWithNibName:@"WBMasterViewController" bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if ([[AircraftStore defaultStore] saveChanges])
        NSLog(@"Aircraft saved OK");
    else
        NSLog(@"Error saving aircraft");
    
    if([[TypeStore defaultStore] saveChanges])
        NSLog(@"Aircraft types saved OK");
    else
        NSLog(@"Error saving aircraft types");

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void) loadInitialTypes
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                       NSUserDomainMask, YES);
    NSString * documentDirectory = documentDirectories[0];
    NSString *txtPath =  [documentDirectory stringByAppendingPathComponent:TYPES_LIBRARY_FILE_NAME];
    
    if ([fileManager fileExistsAtPath:txtPath] == NO) {
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:TYPES_LIBRARY_RESOURCE_NAME ofType:nil];
        if (resourcePath)
            [fileManager copyItemAtPath:resourcePath toPath:txtPath error:&error];
    }
}

@end
