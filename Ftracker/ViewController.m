//
//  ViewController.m
//  Ftracker
//
//  Created by VADIM KASSIN on 5/31/15.
//  Copyright (c) 2015 VADIM KASSIN. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController () {

    id _notificationObserver;
}

@end

@implementation ViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    NSString *identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    self.idLabel.text = identifier;
    
    _notificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"MessageIncoming" object:nil queue:[NSOperationQueue mainQueue]
                                                                                           usingBlock:^(NSNotification *notification) {
                                                                                               [self refresh];
                                                                                           }];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

- (void)refresh {

    self.textView.text = @"";
    
    AppDelegate* ad = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [ad loadLogFromFile];
    for (NSString *s in ad.log) {
        
        self.textView.text = [NSString stringWithFormat:@"%@---------------------------------------------\n%@\n", self.textView.text, s];
    }

}

- (void)viewDidAppear:(BOOL)animated {

    [self refresh];
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:_notificationObserver];
}

@end
