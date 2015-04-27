//
//  ViewController.m
//  Bro2Bro
//
//  Created by Vik Denic on 4/26/15.
//  Copyright (c) 2015 nektar labs. All rights reserved.
//

#import "ViewController.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)onFBTapped:(UIButton *)sender
{
    [self _loginWithFacebook];
}


- (void)_loginWithFacebook {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[@"public_profile", @"user_friends", @"email"];

    // Login PFUser using Facebook
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user)
        {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
        } else {
            NSLog(@"User logged in through Facebook!");
        }
    }];
}

@end
