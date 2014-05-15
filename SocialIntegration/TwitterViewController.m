//
//  FacebookViewController.m
//  SocialIntegration
//
//  Created by Omer Hagopian on 5/13/14.
//  Copyright (c) 2014 Omer Hagopian. All rights reserved.
//

#import "TwitterViewController.h"

@interface TwitterViewController ()

@end

@implementation TwitterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Twitter";
    self.service = SocialServiceTwitter;
}

@end
