//
//  ViewController.m
//  Pasteur
//
//  Created by Damir Suleymanov on 11/10/12.
//  Copyright (c) 2012 Harvard University. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "ViewController.h"

@implementation ViewController
@synthesize textView;

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if (FBSession.activeSession.state != FBSessionStateCreatedTokenLoaded) {
        NSLog(@"Loggin in");
    } else {
        NSLog(@"No login needed");
    }

    [FBSession openActiveSessionWithReadPermissions:[NSArray arrayWithObjects:@"user_education_history", @"friends_education_history", nil] allowLoginUI:YES completionHandler:^(FBSession *session,
                                                                             FBSessionState state,
                                                                             NSError *error) {
                                                             [self sessionStateChanged:session
                                                                                 state:state
                                                                                 error:error];
                                                         }];

    //NSURL *url = [NSURL URLWithString:@"https://google.com"];
    //NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    //[self.webView loadRequest:requestObj];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                 NSLog(@"User info. [%@] - %@", user.id, user.name);
                 NSLog(@"Access Token: %@", FBSession.activeSession.accessToken);


                 //NSString *str = [NSString stringWithFormat:@"https://script.google.com/macros/s/AKfycbxwe6-wxW_gjoW05iKNiG_T0qez9uBWueYBQwWxf6g8qYQlSzse/exec?uid=%@&access_token=%@", user.id, FBSession.activeSession.accessToken];
                 //NSURL *url = [NSURL URLWithString:str];
                 //NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
                 //[self.webView loadRequest:requestObj];
             }
         }];
    }
}

/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                NSLog(@"User session found");
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            NSLog(@"Login failed");
            break;
        default:
            break;
    }

//    [[NSNotificationCenter defaultCenter]
//     postNotificationName:FBSessionStateChangedNotification
//     object:session];

    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
