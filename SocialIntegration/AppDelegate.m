//
//  AppDelegate.m
//  SocialIntegration
//
//  Created by Omer Hagopian on 5/13/14.
//  Copyright (c) 2014 Omer Hagopian. All rights reserved.
//

#import "AppDelegate.h"
#import "NRSocialServiceManager.h"

@implementation AppDelegate

- (instancetype)init {
    self = [super init];
    if (self) {
        [NRSocialServiceManager sharedInstance];
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[NRSocialServiceManager sharedInstance] handleOpenURL:url sourceApplication:sourceApplication];
}

@end
