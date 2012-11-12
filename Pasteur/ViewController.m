//
//  ViewController.m
//  Pasteur
//
//  Created by Damir Suleymanov on 11/10/12.
//  Copyright (c) 2012 Harvard University. All rights reserved.
//

#import <ASIHTTPRequest/ASIHTTPRequest.h>
#import <FacebookSDK/FacebookSDK.h>
#import "ViewController.h"
#import "SBJson.h"

@implementation ViewController
@synthesize textView;
@synthesize questions;
@synthesize buttons;
@synthesize slider;
@synthesize button;

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
    self.buttons.backgroundColor = [UIColor clearColor];
    self.buttons.hidden = YES;

    self.slider.hidden = YES;
    self.button.hidden = YES;
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

                 NSURL *url = [NSURL URLWithString:@"https://script.google.com/macros/s/AKfycbw0SfPRzLUVPHAnTVrXtdw5BThxGGiHyO7YaMmxmqpUycxjtto/exec"];
                 ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                 request.delegate = self;
                 [request startAsynchronous];
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

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    NSLog(@"reponse: %@", responseString);

    NSArray *theQuestions = [responseString JSONValue];
    self.questions = theQuestions;

    [self updateQuestion:nil];
    self.button.hidden = NO;
}

- (IBAction)updateQuestion:(id)sender {
    if (currentIndex == questions.count - 1) {
        self.button.titleLabel.text = @"Finish";
    } else if (currentIndex == questions.count) {
        [self finishSurvey];
        return;
    }

    NSDictionary *question = [questions objectAtIndex: currentIndex++];
    self.textView.text = [question objectForKey:@"question"];

    NSLog(@"type: %@", [question objectForKey:@"type"]);
    if ([@"slider" isEqualToString: [question objectForKey:@"type"]]) {
        self.slider.hidden = NO;
        self.buttons.hidden = YES;
    } else if ([@"bool" isEqualToString: [question objectForKey:@"type"]]) {
        self.slider.hidden = YES;
        self.buttons.hidden = NO;
    }
}

- (void)finishSurvey {
    NSLog(@"Finish Survey");
}

- (IBAction)buttonClicked:(id)sender {
    switch ([sender tag]) {
        case 0:
            NSLog(@"Yes");
            break;
        case 1:
            NSLog(@"No");
            break;
        default:
            NSLog(@"Unexpected tag %d", [sender tag]);
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
   NSError *error = [request error];
    NSLog(@"response failed: %@", [error debugDescription]);
}
@end
