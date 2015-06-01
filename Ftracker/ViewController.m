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
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    self.idLabel.text = identifier;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
