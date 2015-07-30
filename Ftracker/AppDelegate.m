//
//  AppDelegate.m
//  Ftracker
//
//  Created by VADIM KASSIN on 5/31/15.
//  Copyright (c) 2015 VADIM KASSIN. All rights reserved.
//http://mobileoop.com/getting-location-updates-for-ios-7-and-8-when-the-app-is-killedterminatedsuspended
//http://www.raywenderlich.com/29948/backgrounding-for-ios

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#define URL @"http://89.107.99.238:10356"
#define URL1 @"http://192.168.2.168"

@implementation AppDelegate

- (void)sendToServerLat:(double)lat andLon:(double)lon {

    NSString *device = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyyMMdd_HHmmss"];
    NSString *convertedDateString = [dateFormater stringFromDate:[NSDate date]];
    NSString* URL_ADD = [NSString stringWithFormat:@"/gps_track.php?device='%@'&lat='%f'&lon='%f'&cl_time='%@'&bat='-18'", device, lat, lon, convertedDateString];
    NSString* encodedUrl = [URL_ADD stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self sendURL:encodedUrl fromStore:NO];
}

- (void)sendURL:(NSString*)url_add fromStore:(BOOL)fromStore {
    
    NSLog(@"sendURL: %@ fromStore: %d", url_add, fromStore);
    [self customLog:[NSString stringWithFormat:@"sendURL: %@ fromStore: %d", url_add, fromStore]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString* req = [URL stringByAppendingString:url_add];
    [request setURL:[NSURL URLWithString:req]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

        if (!error) {
            
            NSLog(@"Success send to %@", URL);
            [self customLog:[NSString stringWithFormat:@"Success send to %@", URL]];
            
            [self sendStore];
            
        } else {

            NSLog(@"Failed send to %@ %@", URL, [error localizedDescription]);
            [self customLog:[NSString stringWithFormat:@"Failed send to %@", URL]];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            NSString* req = [URL1 stringByAppendingString:url_add];
            [request setURL:[NSURL URLWithString:req]];

            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                
                if (!error) {
                    
                    NSLog(@"Success send to %@", URL1);
                    [self customLog:[NSString stringWithFormat:@"Success send to %@", URL1]];

                    [self sendStore];
                    
                } else {
                    
                    NSLog(@"Failed send to %@ %@", URL1, [error localizedDescription]);
                    [self customLog:[NSString stringWithFormat:@"Failed send to %@", URL1]];

                    [self addToStore:url_add];
                }
            }];
        }
    }];
}


- (void)sendStore {
    
    [self loadStoreFromFile];
    
    NSString *url = [self.list lastObject];
    if(url) {
    
        [self.list removeObject:url];
        [self saveStoreToFile];
        [self sendURL:url fromStore:YES];
    }
}

- (void)addToStore:(NSString*) url {
    
    [self loadStoreFromFile];
    [self.list addObject:url];
    [self saveStoreToFile];
}

- (void)saveStoreToFile {
    
    [[NSUserDefaults standardUserDefaults] setObject:self.list forKey:@"store"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadStoreFromFile {
    
    self.list = [[[NSUserDefaults standardUserDefaults] objectForKey:@"store"] mutableCopy];
    if(!self.list)
        self.list = [NSMutableArray array];
}

- (void)saveLogToFile {
    
    [[NSUserDefaults standardUserDefaults] setObject:self.log forKey:@"log"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadLogFromFile {
    
    self.log = [[[NSUserDefaults standardUserDefaults] objectForKey:@"log"] mutableCopy];
    if(!self.log)
        self.log = [NSMutableArray array];
}

- (void)customLog:(NSString *)str {
    
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YY.MM.DD hh:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [self loadLogFromFile];
    [self.log addObject:[NSString stringWithFormat:@"%@, %@", [dateFormatter stringFromDate:now], str]];
    [self saveLogToFile];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageIncoming" object:nil userInfo:nil];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    NSLog(@"didFinishLaunchingWithOptions");
    [self customLog:@"didFinishLaunchingWithOptions"];

    [Fabric with:@[CrashlyticsKit]];

    self.shareModel = [LocationShareModel sharedModel];
    self.shareModel.afterResume = NO;
    
    
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
            [self customLog:@"UIApplicationLaunchOptionsLocationKey"];

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
    [self customLog:[NSString stringWithFormat:@"locationManager didUpdateLocations: %@",locations]];
    
    for(int i = 0; i < locations.count; i++){
        
        CLLocation * newLocation = [locations objectAtIndex:i];
        CLLocationCoordinate2D theLocation = newLocation.coordinate;
        CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;
        
        self.myLocation = theLocation;
        self.myLocationAccuracy = theAccuracy;
    }
    
//    [self addLocationToPList:self.shareModel.afterResume];
    [self sendToServerLat:self.myLocation.latitude andLon:self.myLocation.longitude];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"error: %@",[error localizedDescription]);
    [self customLog:[NSString stringWithFormat:@"error: %@",[error localizedDescription]]];
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error {

    NSLog(@"error1: %@",[error localizedDescription]);
    [self customLog:[NSString stringWithFormat:@"error1: %@",[error localizedDescription]]];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    NSLog(@"applicationDidEnterBackground");
    [self customLog:@"applicationDidEnterBackground"];

    [self.shareModel.anotherLocationManager stopMonitoringSignificantLocationChanges];
    
    if(IS_OS_8_OR_LATER) {
        [self.shareModel.anotherLocationManager requestAlwaysAuthorization];
    }
    [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
    
}



- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    NSLog(@"applicationDidBecomeActive");
    [self customLog:@"applicationDidBecomeActive"];

    self.shareModel.afterResume = NO;
    
    if(self.shareModel.anotherLocationManager) {
        
        [self.shareModel.anotherLocationManager stopMonitoringSignificantLocationChanges];
    }
    
    self.shareModel.anotherLocationManager = [[CLLocationManager alloc]init];
    self.shareModel.anotherLocationManager.delegate = self;
    self.shareModel.anotherLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.shareModel.anotherLocationManager.activityType = CLActivityTypeOtherNavigation;
    
    if(IS_OS_8_OR_LATER) {
        
        [self.shareModel.anotherLocationManager requestAlwaysAuthorization];
    }
    
    [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
    
    NSLog(@"created");
    [self customLog:@"created"];

}

-(void)applicationWillTerminate:(UIApplication *)application {
    
    NSLog(@"applicationWillTerminate");
    [self customLog:@"applicationWillTerminate"];
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

@end
