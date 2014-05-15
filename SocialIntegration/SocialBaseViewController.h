//
//  SocialBaseViewController.h
//  SocialIntegration
//
//  Created by Omer Hagopian on 5/13/14.
//  Copyright (c) 2014 Omer Hagopian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NRSocialServiceManager.h"

@interface SocialBaseViewController : UIViewController

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NRSocialServiceManager *socialManager;
@property (nonatomic, assign) SocialService service;

- (void)logText:(NSString *)text;

@end
