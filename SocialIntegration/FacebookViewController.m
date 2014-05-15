//
//  FacebookViewController.m
//  SocialIntegration
//
//  Created by Omer Hagopian on 5/13/14.
//  Copyright (c) 2014 Omer Hagopian. All rights reserved.
//

#import "FacebookViewController.h"

@interface FacebookViewController ()

@end

@implementation FacebookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Facebook";
    self.service = SocialServiceFacebook;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupNavBarButtons];
}

- (void)setupNavBarButtons {
    NSMutableArray *buttons = [NSMutableArray new];
    if ([self.socialManager isServiceAvailable:self.service]) {
        //Poner botones para ir a buscar data
        UIBarButtonItem *getData = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                               target:self action:@selector(getDataButtonAction:)];
        
        UIBarButtonItem *logout = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                target:self action:@selector(logoutButtonAction:)];
        [buttons addObject:getData];
        [buttons addObject:logout];
    }
    else {
        UIBarButtonItem *login = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                               target:self action:@selector(loginButtonAction:)];
        
        [buttons addObject:login];
    }
    
    self.navigationItem.rightBarButtonItems = buttons;
        
}

- (void)getDataButtonAction:(id)sender {
//    [self logText:@"Getting User Info..."];
//    [self.socialManager getUserInfoForService:SocialServiceFacebook onCompletion:^(NSDictionary *info, NSError *error) {
//        if (info) {
//            [self logText:[info description]];
//        }
//        if (error) {
//            [self logText:[error description]];
//        }
//    }];
    
    [self logText:@"Getting User Feed..."];
    [self.socialManager getFacebookFeedForUser:nil onCompletion:^(NSDictionary *info, NSError *error) {
        if (info) {
            [self logText:[info description]];
        }
        if (error) {
            [self logText:[error description]];
        }
    }];
}

- (void)loginButtonAction:(id)sender {
    [self logText:@"Logging in..."];
    [self.socialManager loginService:SocialServiceFacebook onCompletion:^(BOOL granted, NSError *error) {
        if (granted)
            [self logText:@"Login success"];
        else
            [self logText:[NSString stringWithFormat:@"Login Failed: %@", [error localizedDescription]]];
        [self setupNavBarButtons];
    }];
}

- (void)logoutButtonAction:(id)sender {
    [self logText:@"Logging out..."];
    [self.socialManager logoutService:SocialServiceFacebook onCompletion:^(BOOL granted, NSError *error) {
        if (granted)
            [self logText:@"Logout Ok"];
        else
            [self logText:[NSString stringWithFormat:@"Logout Failed: %@", [error localizedDescription]]];
        [self setupNavBarButtons];
    }];
}

@end
