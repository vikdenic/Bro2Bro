//
//  ViewController.m
//  Bro2Bro
//
//  Created by Vik Denic on 4/26/15.
//  Copyright (c) 2015 nektar labs. All rights reserved.
//

#import "ViewController.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Parse/PFFile.h>
#import <ParseUI/ParseUI.h>

@interface ViewController ()

@property (strong, nonatomic) IBOutlet PFImageView *profileImageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([PFUser currentUser])
    {
        self.profileImageView.file = [[PFUser currentUser] objectForKey:@"profileImage"];
        [self.profileImageView loadInBackground];
    }
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
            [self _loadData];
        }
    }];
}

- (void)_loadData {
    // ...
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
    
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;

            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            NSString *location = userData[@"location"][@"name"];

            NSLog(@"%@ %@ %@", facebookID, name, location);

            PFUser *currentUser = [PFUser currentUser];
            [currentUser setObject:name forKey:@"name"];
            [currentUser saveInBackground];

            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];

            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];

            // Now add the data to the UI elements
            // Run network request asynchronously
            [NSURLConnection sendAsynchronousRequest:urlRequest
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:
             ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                 if (connectionError == nil && data != nil) {

                     PFFile *file = [PFFile fileWithData:data];
                     [currentUser setObject:file forKey:@"profileImage"];
                     [currentUser saveInBackground];
                 }
             }];
        }
    }];
}

@end
