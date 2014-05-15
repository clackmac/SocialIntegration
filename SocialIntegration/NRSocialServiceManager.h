//
//  NRSocialServiceManager.h
//  SocialIntegration
//
//  Created by Omer Hagopian on 5/13/14.
//  Copyright (c) 2014 Omer Hagopian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SocialServiceNone,
    SocialServiceFacebook,
    SocialServiceTwitter
} SocialService;

@interface NRSocialServiceManager : NSObject

+ (instancetype)sharedInstance;
- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)source;

#pragma  - General

- (BOOL)isServiceAvailable:(SocialService)socialService;

- (void)loginService:(SocialService)socialService onCompletion:(void(^)(BOOL granted, NSError *error))completionHandler;
- (void)logoutService:(SocialService)socialService onCompletion:(void(^)(BOOL granted, NSError *error))completionHandler;

- (void)getUserInfoForService:(SocialService)socialService onCompletion:(void(^)(NSDictionary *info, NSError *error))completionHandler;

#pragma - Facebook

- (void)getFacebookFeedForUser:(NSString *)userId onCompletion:(void(^)(NSDictionary *info, NSError *error))completionHandler;

@end
