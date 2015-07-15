//
//  AppDelegate.h
//  Ftracker
//
//  Created by VADIM KASSIN on 5/31/15.
//  Copyright (c) 2015 VADIM KASSIN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationShareModel.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) NSMutableArray *list;
@property (strong,nonatomic) LocationShareModel * shareModel;
@property (nonatomic) CLLocationCoordinate2D myLastLocation;
@property (nonatomic) CLLocationAccuracy myLastLocationAccuracy;
@property (nonatomic) CLLocationCoordinate2D myLocation;
@property (nonatomic) CLLocationAccuracy myLocationAccuracy;

@end

