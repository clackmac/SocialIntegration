//
//  NRSocialServiceManager.m
//  SocialIntegration
//
//  Created by Omer Hagopian on 5/13/14.
//  Copyright (c) 2014 Omer Hagopian. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "NRSocialServiceManager.h"

//OH: Permission tokem list https://developers.facebook.com/docs/reference/fql/permissions
#define kFacebookPermissions [NSArray arrayWithObjects:@"public_profile", @"read_stream", nil]
typedef void (^NRSocialServiceCompletionHandler)(BOOL completed, NSError *error);


@interface NRSocialServiceManager ()

@property (nonatomic, copy) NRSocialServiceCompletionHandler facebookLoginHandler;
@property (nonatomic, copy) NRSocialServiceCompletionHandler facebookLogoutHandler;

@end

@implementation NRSocialServiceManager

static dispatch_once_t * pred_Ref;

+ (instancetype)sharedInstance {
    
    static NRSocialServiceManager *_sharedInstance = nil;
    static dispatch_once_t pred;
    pred_Ref = &pred;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [NRSocialServiceManager new];
        [[NSNotificationCenter defaultCenter] addObserver:_sharedInstance selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:_sharedInstance selector:@selector(appDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
        
    });
    
    return _sharedInstance;
}

- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)source {
    
    [FBSession.activeSession setStateChangeHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        [self sessionStateChanged:session state:status error:error];
    }];
    
    NSString *schema = [url.scheme lowercaseString];
    if ([schema hasPrefix:@"fb"]) {
        return [FBAppCall handleOpenURL:url sourceApplication:source];
    }
    
    return NO;
}

#pragma mark - General

- (BOOL)isServiceAvailable:(SocialService)socialService {
    switch (socialService) {
        case SocialServiceFacebook:
            return [self isFacebookAvailable];
            break;
        case SocialServiceTwitter:
            return [self isTwitterAvailable];
            break;
        default:
            break;
    }
    
    return NO;
}

- (void)loginService:(SocialService)socialService onCompletion:(void(^)(BOOL granted, NSError *error))completionHandler {
    switch (socialService) {
        case SocialServiceFacebook: {
            [self loginFacebookOnCompletion:completionHandler];
        }
            break;
        default:{
            completionHandler(NO, [NSError errorWithDomain:@"LoginError" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Service not Available"}]);
        }
            break;
    }
        
}

- (void)logoutService:(SocialService)socialService onCompletion:(void(^)(BOOL granted, NSError *error))completionHandler {
    switch (socialService) {
        case SocialServiceFacebook: {
            [self logoutFacebookOnCompletion:completionHandler];
        }
            break;
        default:{
            completionHandler(NO, [NSError errorWithDomain:@"Logout" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Service not Available"}]);
        }
            break;
    }
    
}

- (void)getUserInfoForService:(SocialService)socialService onCompletion:(void(^)(NSDictionary *info, NSError *error))completionHandler {
    switch (socialService) {
        case SocialServiceFacebook: {
            [self getFacebookUserInfoOnCompletion:completionHandler];
        }
            break;
        default:
        break;
    }
}

#pragma mark - Facebook

- (void)getFacebookFeedForUser:(NSString *)userId onCompletion:(void(^)(NSDictionary *info, NSError *error))completionHandler {
    
    NSString *fqlQuery = @"SELECT post_id, created_time,  type, attachment FROM stream WHERE filter_key in (SELECT filter_key FROM stream_filter WHERE uid=me() AND type='newsfeed') AND is_hidden = 0 LIMIT 1";
    
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql" parameters:[NSDictionary dictionaryWithObjectsAndKeys: fqlQuery, @"q", nil]
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (completionHandler) {
                                  NSDictionary *info = nil;
                                  if ([result isKindOfClass:[NSDictionary class]]) {
                                      info = (NSDictionary *)result;
                                  }
                                  completionHandler(info,error);
                              }
                          }];
}

#pragma mark - Private
#pragma mark -

#pragma mark - Facebook

- (BOOL)isFacebookAvailable {
    return FBSession.activeSession.isOpen;
}

- (void)loginFacebookOnCompletion:(void(^)(BOOL granted, NSError *error))completionHandler {
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state != FBSessionStateOpen &&
        FBSession.activeSession.state != FBSessionStateOpenTokenExtended) {
        
        self.facebookLoginHandler = completionHandler;
        
        [FBSession.activeSession closeAndClearTokenInformation];
        // You must ALWAYS ask for public_profile permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:kFacebookPermissions
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
    }
    else
        completionHandler(YES, nil);
        
}

- (void)logoutFacebookOnCompletion:(void(^)(BOOL granted, NSError *error))completionHandler {
    self.facebookLogoutHandler = completionHandler;
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (void)getFacebookUserInfoOnCompletion:(void (^)(NSDictionary *, NSError *))completionHandler {
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (completionHandler) {
            NSDictionary *info = nil;
            if ([result isKindOfClass:[NSDictionary class]]) {
                info = (NSDictionary *)result;
            }
            completionHandler(info,error);
        }
    }];
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error {
#warning OH: should manage automatic calls from external. Recommended: use notifications
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Facebook : Session opened");
        // User logged-in
        if (self.facebookLoginHandler) {
            self.facebookLoginHandler(YES,nil);
            self.facebookLoginHandler = nil;
        }
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Facebook : Session closed");
        // User logged-out
        if (self.facebookLoginHandler) {
            self.facebookLoginHandler(NO,error);
            self.facebookLoginHandler = nil;
        }
        
        if (self.facebookLogoutHandler) {
            self.facebookLogoutHandler(YES, nil);
            self.facebookLogoutHandler = nil;
        }
    }
    
    // Handle errors
    if (error){
        NSLog(@"Facebook : Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
//            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"Facebook : User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
//                [self showMessage:alertText withTitle:alertTitle];
                
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
//                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
//        [self userLoggedOut];
    }
}

#pragma mark - Twitter

- (BOOL)isTwitterAvailable {
    return NO;
}

#pragma mark Notifications

- (void)appDidBecomeActive:(NSNotification *)notification {
    [FBAppCall handleDidBecomeActive];
}

- (void)appDidFinishLaunching:(NSNotification *)notification {
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
    }
}

@end
