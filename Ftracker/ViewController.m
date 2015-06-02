//
//  ViewController.m
//  Ftracker
//
//  Created by VADIM KASSIN on 5/31/15.
//  Copyright (c) 2015 VADIM KASSIN. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    NSString *identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    self.idLabel.text = identifier;
    
    lm = [[CLLocationManager alloc] init];
    lm.delegate = self;
    lm.desiredAccuracy = kCLLocationAccuracyBest;
    lm.distanceFilter = kCLDistanceFilterNone;
    [lm startUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//
//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
//    
//    //get the latest location
//    CLLocation *currentLocation = [locations lastObject];
//    
//    //get latest location coordinates
//    CLLocationDegrees Latitude = currentLocation.coordinate.latitude;
//    CLLocationDegrees Longitude = currentLocation.coordinate.longitude;
//    CLLocationCoordinate2D locationCoordinates = CLLocationCoordinate2DMake(Latitude, Longitude);
//    
//}

//-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
//    
//    for(int i=0;i<locations.count;i++){
//        CLLocation * newLocation = [locations objectAtIndex:i];
//        CLLocationCoordinate2D theLocation = newLocation.coordinate;
//        CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;
//        NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
//        
//        if (locationAge > 30.0)
//        {
//            continue;
//        }
//        
//        //Select only valid location and also location with good accuracy
//        if(newLocation!=nil&&theAccuracy>0
//           &&theAccuracy<2000
//           &&(!(theLocation.latitude==0.0&&theLocation.longitude==0.0))){
//            
//            self.myLastLocation = theLocation;
//            self.myLastLocationAccuracy= theAccuracy;
//            
//            NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
//            [dict setObject:[NSNumber numberWithFloat:theLocation.latitude] forKey:@"latitude"];
//            [dict setObject:[NSNumber numberWithFloat:theLocation.longitude] forKey:@"longitude"];
//            [dict setObject:[NSNumber numberWithFloat:theAccuracy] forKey:@"theAccuracy"];
//            
//            //Add the vallid location with good accuracy into an array
//            //Every 1 minute, I will select the best location based on accuracy and send to server
//            [self.shareModel.myLocationArray addObject:dict];
//        }
//    }
//    
//    //If the timer still valid, return it (Will not run the code below)
//    if (self.shareModel.timer) {
//        return;
//    }
//    
//    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
//    [self.shareModel.bgTask beginNewBackgroundTask];
//    
//    //Restart the locationMaanger after 1 minute
//    self.shareModel.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self
//                                                           selector:@selector(restartLocationUpdates)
//                                                           userInfo:nil
//                                                            repeats:NO];
//    
//    //Will only stop the locationManager after 10 seconds, so that we can get some accurate locations
//    //The location manager will only operate for 10 seconds to save battery
//    NSTimer * delay10Seconds;
//    delay10Seconds = [NSTimer scheduledTimerWithTimeInterval:10 target:self
//                                                    selector:@selector(stopLocationDelayBy10Seconds)
//                                                    userInfo:nil
//                                                     repeats:NO];
//}

@end
