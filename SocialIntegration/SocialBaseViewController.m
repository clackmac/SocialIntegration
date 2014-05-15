//
//  SocialBaseViewController.m
//  SocialIntegration
//
//  Created by Omer Hagopian on 5/13/14.
//  Copyright (c) 2014 Omer Hagopian. All rights reserved.
//

#import "SocialBaseViewController.h"

@interface SocialBaseViewController () <UIAlertViewDelegate>

@end

@implementation SocialBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.service = SocialServiceNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.textView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
    self.textView.editable = NO;
    [self.view addSubview:self.textView];
    
    self.socialManager = [NRSocialServiceManager sharedInstance];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSString *message = [self.socialManager isServiceAvailable:SocialServiceFacebook] ? @"Service Available" : @"Service Unavailable";
    [self logText:message];
}

- (void)logText:(NSString *)text {
    self.textView.text = [NSString stringWithFormat:@"%@\n%@",text, self.textView.text];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake ) {
        // shaking has began.
        [[[UIAlertView alloc] initWithTitle:@"Delete Log?" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 0) {
        self.textView.text = @"";
    }
}

@end
