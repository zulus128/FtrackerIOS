//
//  AppDelegate.m
//  Ftracker
//
//  Created by VADIM KASSIN on 5/31/15.
//  Copyright (c) 2015 VADIM KASSIN. All rights reserved.
//http://mobileoop.com/getting-location-updates-for-ios-7-and-8-when-the-app-is-killedterminatedsuspended
//http://www.raywenderlich.com/29948/backgrounding-for-ios

#import "AppDelegate.h"

#define URL @"http://89.107.99.238:10356"
#define URL1 @"http://192.168.2.168"

@implementation AppDelegate

- (void)sendToServerLat:(double)lat andLon:(double)lon {

    NSString *device = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyyMMdd_HHmmss"];
    NSString *convertedDateString = [dateFormater stringFromDate:[NSDate date]];
//    NSLog(@"--- %@", convertedDateString);
    NSString* URL_ADD = [NSString stringWithFormat:@"/gps_track.php?device='%@'&lat='%f'&lon='%f'&cl_time='%@'&bat='-7'", device, lat, lon, convertedDateString];
    NSString* encodedUrl = [URL_ADD stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self sendURL:encodedUrl fromStore:NO];
}

- (BOOL)sendURL:(NSString*)url_add fromStore:(BOOL)fromStore {
    
    NSLog(@"sendURL: %@ fromStore: %d", url_add, fromStore);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString* req = [URL stringByAppendingString:url_add];
    NSLog(@"request0 = %@", req);
    [request setURL:[NSURL URLWithString:req]];
    BOOL b = NO;
    NSHTTPURLResponse* urlResponse = nil;
    NSError *error = nil;
    NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    if (!error) {
        
        b = YES;
        NSLog(@"Success send to %@", URL);

    } else {
        NSLog(@"Failed send to %@", URL);
    }

    if(!b) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSString* req = [URL1 stringByAppendingString:url_add];
        NSLog(@"request1 = %@", req);

        [request setURL:[NSURL URLWithString:req]];
        NSHTTPURLResponse* urlResponse = nil;
        NSError *error = nil;
        NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
        
        if (!error) {
            
            b = YES;
            NSLog(@"Success send to %@", URL1);
        } else {
            NSLog(@"Failed send to %@", URL1);
        }
    }
    
    if(!fromStore) {
        
        if(!b)
            [self addToStore:url_add];
        else
            [self sendStore];
    }
    
    return b;
}


- (void)sendStore {
    
    NSMutableArray *newlist = [NSMutableArray array];
    NSMutableArray *list = [self loadStoreFromFile];
    for(NSString *url in list) {
        if(![self sendURL:url fromStore:YES]) {
            
            [newlist addObject:url];
        }
    }
    
    [self saveStoreToFile:newlist];
}

- (void)addToStore:(NSString*) url {
    
    NSMutableArray* list = [self loadStoreFromFile];
    [list addObject:url];
    [self saveStoreToFile:list];
}

- (void) saveStoreToFile:(NSMutableArray*)list {
    
    [[NSUserDefaults standardUserDefaults] setObject:list forKey:@"store"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSMutableArray*)loadStoreFromFile {

    NSMutableArray *l = [[NSUserDefaults standardUserDefaults] objectForKey:@"store"];
    return l;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    NSLog(@"didFinishLaunchingWithOptions");
    
    self.shareModel = [LocationShareModel sharedModel];
    self.shareModel.afterResume = NO;
    
//    [self addApplicationStatusToPList:@"didFinishLaunchingWithOptions"];
    
    UIAlertView * alert;
    
    //We have to make sure that the Background App Refresh is enable for the Location updates to work in the background.
    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied){
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh"
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted){
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The functions of this app are limited because the Background App Refresh is disable."
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    } else{
        
        // When there is a significant changes of the location,
        // The key UIApplicationLaunchOptionsLocationKey will be returned from didFinishLaunchingWithOptions
        // When the app is receiving the key, it must reinitiate the locationManager and get
        // the latest location updates
        
        // This UIApplicationLaunchOptionsLocationKey key enables the location update even when
        // the app has been killed/terminated (Not in th background) by iOS or the user.
        
        if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
            NSLog(@"UIApplicationLaunchOptionsLocationKey");
            
            // This "afterResume" flag is just to show that he receiving location updates
            // are actually from the key "UIApplicationLaunchOptionsLocationKey"
            self.shareModel.afterResume = YES;
            
            self.shareModel.anotherLocationManager = [[CLLocationManager alloc]init];
            self.shareModel.anotherLocationManager.delegate = self;
            self.shareModel.anotherLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            self.shareModel.anotherLocationManager.activityType = CLActivityTypeOtherNavigation;
            
            if(IS_OS_8_OR_LATER) {
                [self.shareModel.anotherLocationManager requestAlwaysAuthorization];
            }
            
            [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
            
//            [self addResumeLocationToPList];
            [self sendToServerLat:self.myLocation.latitude andLon:self.myLocation.longitude];

        }
    }
    
    return YES;

}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    NSLog(@"locationManager didUpdateLocations: %@",locations);
    
    for(int i=0;i<locations.count;i++){
        
        CLLocation * newLocation = [locations objectAtIndex:i];
        CLLocationCoordinate2D theLocation = newLocation.coordinate;
        CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;
        
        self.myLocation = theLocation;
        self.myLocationAccuracy = theAccuracy;
    }
    
//    [self addLocationToPList:self.shareModel.afterResume];
    [self sendToServerLat:self.myLocation.latitude andLon:self.myLocation.longitude];
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"applicationDidEnterBackground");
    [self.shareModel.anotherLocationManager stopMonitoringSignificantLocationChanges];
    
    if(IS_OS_8_OR_LATER) {
        [self.shareModel.anotherLocationManager requestAlwaysAuthorization];
    }
    [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
    
//    [self addApplicationStatusToPList:@"applicationDidEnterBackground"];
}



- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"applicationDidBecomeActive");
    
//    [self addApplicationStatusToPList:@"applicationDidBecomeActive"];
    
    //Remove the "afterResume" Flag after the app is active again.
    self.shareModel.afterResume = NO;
    
    if(self.shareModel.anotherLocationManager)
        [self.shareModel.anotherLocationManager stopMonitoringSignificantLocationChanges];
    
    self.shareModel.anotherLocationManager = [[CLLocationManager alloc]init];
    self.shareModel.anotherLocationManager.delegate = self;
    self.shareModel.anotherLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.shareModel.anotherLocationManager.activityType = CLActivityTypeOtherNavigation;
    
    if(IS_OS_8_OR_LATER) {
        [self.shareModel.anotherLocationManager requestAlwaysAuthorization];
    }
    [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
}

-(void)applicationWillTerminate:(UIApplication *)application {
    
    NSLog(@"applicationWillTerminate");
//    [self addApplicationStatusToPList:@"applicationWillTerminate"];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

///////////////////////////////////////////////////////////////
// Below are 3 functions that add location and Application status to PList
// The purpose is to collect location information locally

//-(void)addResumeLocationToPList{
//    
//    NSLog(@"addResumeLocationToPList");
//    UIApplication* application = [UIApplication sharedApplication];
//    
//    NSString * appState;
//    if([application applicationState]==UIApplicationStateActive)
//        appState = @"UIApplicationStateActive";
//    if([application applicationState]==UIApplicationStateBackground)
//        appState = @"UIApplicationStateBackground";
//    if([application applicationState]==UIApplicationStateInactive)
//        appState = @"UIApplicationStateInactive";
//    
//    self.shareModel.myLocationDictInPlist = [[NSMutableDictionary alloc]init];
//    [self.shareModel.myLocationDictInPlist setObject:@"UIApplicationLaunchOptionsLocationKey" forKey:@"Resume"];
//    [self.shareModel.myLocationDictInPlist setObject:appState forKey:@"AppState"];
//    [self.shareModel.myLocationDictInPlist setObject:[NSDate date] forKey:@"Time"];
//    
//    NSString *plistName = [NSString stringWithFormat:@"LocationArray.plist"];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *docDir = [paths objectAtIndex:0];
//    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", docDir, plistName];
//    
//    NSMutableDictionary *savedProfile = [[NSMutableDictionary alloc] initWithContentsOfFile:fullPath];
//    
//    if (!savedProfile){
//        savedProfile = [[NSMutableDictionary alloc] init];
//        self.shareModel.myLocationArrayInPlist = [[NSMutableArray alloc]init];
//    }
//    else{
//        self.shareModel.myLocationArrayInPlist = [savedProfile objectForKey:@"LocationArray"];
//    }
//    
//    if(self.shareModel.myLocationDictInPlist)
//    {
//        [self.shareModel.myLocationArrayInPlist addObject:self.shareModel.myLocationDictInPlist];
//        [savedProfile setObject:self.shareModel.myLocationArrayInPlist forKey:@"LocationArray"];
//    }
//    
//    if (![savedProfile writeToFile:fullPath atomically:FALSE] ) {
//        NSLog(@"Couldn't save LocationArray.plist" );
//    }
//}
//
//-(void)addLocationToPList:(BOOL)fromResume{
//    NSLog(@"addLocationToPList");
//    
//    UIApplication* application = [UIApplication sharedApplication];
//    
//    NSString * appState;
//    if([application applicationState]==UIApplicationStateActive)
//        appState = @"UIApplicationStateActive";
//    if([application applicationState]==UIApplicationStateBackground)
//        appState = @"UIApplicationStateBackground";
//    if([application applicationState]==UIApplicationStateInactive)
//        appState = @"UIApplicationStateInactive";
//    
//    self.shareModel.myLocationDictInPlist = [[NSMutableDictionary alloc]init];
//    [self.shareModel.myLocationDictInPlist setObject:[NSNumber numberWithDouble:self.myLocation.latitude]  forKey:@"Latitude"];
//    [self.shareModel.myLocationDictInPlist setObject:[NSNumber numberWithDouble:self.myLocation.longitude] forKey:@"Longitude"];
//    [self.shareModel.myLocationDictInPlist setObject:[NSNumber numberWithDouble:self.myLocationAccuracy] forKey:@"Accuracy"];
//    
//    [self.shareModel.myLocationDictInPlist setObject:appState forKey:@"AppState"];
//    
//    if(fromResume)
//        [self.shareModel.myLocationDictInPlist setObject:@"YES" forKey:@"AddFromResume"];
//    else
//        [self.shareModel.myLocationDictInPlist setObject:@"NO" forKey:@"AddFromResume"];
//    
//    [self.shareModel.myLocationDictInPlist setObject:[NSDate date] forKey:@"Time"];
//    
//    NSString *plistName = [NSString stringWithFormat:@"LocationArray.plist"];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *docDir = [paths objectAtIndex:0];
//    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", docDir, plistName];
//    
//    NSMutableDictionary *savedProfile = [[NSMutableDictionary alloc] initWithContentsOfFile:fullPath];
//    
//    if (!savedProfile){
//        savedProfile = [[NSMutableDictionary alloc] init];
//        self.shareModel.myLocationArrayInPlist = [[NSMutableArray alloc]init];
//    }
//    else{
//        self.shareModel.myLocationArrayInPlist = [savedProfile objectForKey:@"LocationArray"];
//    }
//    
//    NSLog(@"Dict: %@",self.shareModel.myLocationDictInPlist);
//    
//    if(self.shareModel.myLocationDictInPlist)
//    {
//        [self.shareModel.myLocationArrayInPlist addObject:self.shareModel.myLocationDictInPlist];
//        [savedProfile setObject:self.shareModel.myLocationArrayInPlist forKey:@"LocationArray"];
//    }
//    
//    if (![savedProfile writeToFile:fullPath atomically:FALSE] ) {
//        NSLog(@"Couldn't save LocationArray.plist" );
//    }
//}
//
//
//
//-(void)addApplicationStatusToPList:(NSString*)applicationStatus{
//    
//    NSLog(@"addApplicationStatusToPList");
//    UIApplication* application = [UIApplication sharedApplication];
//    
//    NSString * appState;
//    if([application applicationState]==UIApplicationStateActive)
//        appState = @"UIApplicationStateActive";
//    if([application applicationState]==UIApplicationStateBackground)
//        appState = @"UIApplicationStateBackground";
//    if([application applicationState]==UIApplicationStateInactive)
//        appState = @"UIApplicationStateInactive";
//    
//    self.shareModel.myLocationDictInPlist = [[NSMutableDictionary alloc]init];
//    [self.shareModel.myLocationDictInPlist setObject:applicationStatus forKey:@"applicationStatus"];
//    [self.shareModel.myLocationDictInPlist setObject:appState forKey:@"AppState"];
//    [self.shareModel.myLocationDictInPlist setObject:[NSDate date] forKey:@"Time"];
//    
//    NSString *plistName = [NSString stringWithFormat:@"LocationArray.plist"];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *docDir = [paths objectAtIndex:0];
//    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", docDir, plistName];
//    
//    NSMutableDictionary *savedProfile = [[NSMutableDictionary alloc] initWithContentsOfFile:fullPath];
//    
//    if (!savedProfile){
//        savedProfile = [[NSMutableDictionary alloc] init];
//        self.shareModel.myLocationArrayInPlist = [[NSMutableArray alloc]init];
//    }
//    else{
//        self.shareModel.myLocationArrayInPlist = [savedProfile objectForKey:@"LocationArray"];
//    }
//    
//    if(self.shareModel.myLocationDictInPlist)
//    {
//        [self.shareModel.myLocationArrayInPlist addObject:self.shareModel.myLocationDictInPlist];
//        [savedProfile setObject:self.shareModel.myLocationArrayInPlist forKey:@"LocationArray"];
//    }
//    
//    if (![savedProfile writeToFile:fullPath atomically:FALSE] ) {
//        NSLog(@"Couldn't save LocationArray.plist" );
//    }
//}

@end
