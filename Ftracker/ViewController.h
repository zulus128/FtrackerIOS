//
//  ViewController.h
//  Ftracker
//
//  Created by VADIM KASSIN on 5/31/15.
//  Copyright (c) 2015 VADIM KASSIN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate> {
    
    CLLocationManager *lm; //core lcoation manager instance
    
}

@property (weak, nonatomic) IBOutlet UILabel *idLabel;

@end

