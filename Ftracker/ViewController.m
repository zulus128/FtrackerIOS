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
    
//    lm = [[CLLocationManager alloc] init];
//    lm.delegate = self;
//    lm.desiredAccuracy = kCLLocationAccuracyBest;
//    lm.distanceFilter = kCLDistanceFilterNone;
//    [lm startUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
//    NSLog(@"lat = %f lon = %f", Latitude, Longitude);
//    
//}


@end
