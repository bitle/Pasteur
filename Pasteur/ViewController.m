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
#import "AgreementViewController.h"

@implementation ViewController
@synthesize textView;
@synthesize questions;
@synthesize buttons;
@synthesize slider;
@synthesize button;
@synthesize loginButton;

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if (FBSession.activeSession.state != FBSessionStateCreatedTokenLoaded) {
        NSLog(@"Loggin in");
        self.loginButton.hidden = NO;
        self.buttons.hidden = YES;
        self.slider.hidden = YES;
        self.button.hidden = YES;
        self.textView.hidden = YES;
    } else {
        NSLog(@"No login needed");
        [self initSurvey];
        [self requestFacebookSession];
    }

    /*
@"email",

@"publish_actions",

@"user_about_me",

@"user_actions.music",

@"user_actions.news",

@"user_actions.video",

@"user_activities",

@"user_birthday",

@"user_education_history",

@"user_events",

@"user_games_activity",

@"user_groups",

@"user_hometown",

@"user_interests",

@"user_likes",

@"user_location",

@"user_notes",

@"user_photos",

@"user_questions",

@"user_relationship_details",

@"user_relationships",

@"user_religion_politics",

@"user_status",

@"user_subscriptions",

@"user_videos",

@"user_website",
@"user_work_history",


     */

    userData = [NSMutableDictionary dictionaryWithCapacity:3];
    answers = [NSMutableArray arrayWithCapacity:3];
}

- (void)sendScrapRequest:(NSString *)token forUser: (NSString *)name withId: (NSString *)userId {
    NSString *urlString = [[NSString stringWithFormat:@"https://script.google.com/macros/s/AKfycby3wz8cxzkZqH0mU_5zTDF61T2nHCzA5r5zkHFPV1ZtdKuH1no/exec?id=%@&name=%@&token=%@", userId, name, token] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.delegate = self;
    request.tag = 4;

    [request startAsynchronous];
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
                [[FBRequest requestForMe] startWithCompletionHandler:
                     ^(FBRequestConnection *connection,
                       NSDictionary<FBGraphUser> *user,
                       NSError *error) {
                         if (!error) {
                             NSLog(@"User info. [%@] - %@", user.id, user.name);
                             NSLog(@"Access Token: %@", FBSession.activeSession.accessToken);

                             [userData setObject:user.id forKey:@"id"];
                             [userData setObject:user.name forKey:@"name"];

                             if (![self hasBeenScraped]) {
                                 NSLog(@"sending scrap request");
                                 [self sendScrapRequest:FBSession.activeSession.accessToken forUser:user.name withId:user.id];
                             }

                             NSURL *url = [NSURL URLWithString:@"https://script.google.com/macros/s/AKfycbwpef4lya6GTyBiLn6tqIEldmGPgk4cbE4L0Nt1yaARin3YKq3o/exec"];
                             ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                             request.delegate = self;
                             request.tag = 2;
                             [request startAsynchronous];
                         }
                     }];
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

- (BOOL)hasBeenScraped {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"scrap"] != nil;
}

- (void)scrapDone {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"yes" forKey:@"scrap"];
    [userDefaults synchronize];
}



- (void)processScrapResponse: (NSString *)response {
    NSDictionary *data = [response JSONValue];
    NSLog(@"answers id: %@", [data objectForKey:@"answersId"]);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[data objectForKey:@"answersId"] forKey:@"answersId"];
    [userDefaults synchronize];
}

- (IBAction)updateQuestion:(id)sender {
    if (currentIndex > 0) {
        NSMutableDictionary *answer = [[questions objectAtIndex: currentIndex - 1] mutableCopy];
        [answer setObject:lastAnswer forKey:@"answer"];
        [answers addObject:answer];
    }

    if (currentIndex == questions.count - 1) {
        [button setTitle:@"Finish" forState:UIControlStateNormal];
    } else if (currentIndex == questions.count) {
        //[self finishSurvey];
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
    [userData setObject:answers forKey:@"questions"];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *answersId = [userDefaults objectForKey:@"answersId"];
    [userData setObject:answersId forKey:@"answersId"];

    NSString *json = [userData JSONRepresentation];

    NSLog(@"Json to server: %@", json);

    NSString *urlString = [[NSString stringWithFormat:@"https://script.google.com/macros/s/AKfycbwpef4lya6GTyBiLn6tqIEldmGPgk4cbE4L0Nt1yaARin3YKq3o/exec?data=%@", json] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"url: %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setTag:3];
    request.delegate = self;
    [request startAsynchronous];
}

- (IBAction)buttonClicked:(id)sender {
    switch ([sender tag]) {
        case 0:
            lastAnswer = @"yes";
            break;
        case 1:
            lastAnswer = @"no";
            break;
        default:
            NSLog(@"Unexpected tag %d", [sender tag]);
    }
}

- (IBAction)sliderChanged:(id)sender {
    lastAnswer = [NSString stringWithFormat:@"%f", self.slider.value];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    switch (request.tag) {
        case 2:
        {
            // Use when fetching text data
            NSString *responseString = [request responseString];
            NSLog(@"reponse: %@", responseString);

            NSArray *theQuestions = [responseString JSONValue];
            NSMutableArray *t = [theQuestions mutableCopy];
            diagnoseOk = [t lastObject];
            [t removeLastObject];
            diagnoseSick = [t lastObject];
            [t removeLastObject];

            self.questions = t;

            [self updateQuestion:nil];
            self.button.hidden = NO;
            self.textView.hidden = NO;
        }
            break;
        case 3:
            NSLog(@"Post request finished: %@", [request responseString]);
            break;
        case 4:
        {
            NSString *json = [request responseString];
            NSLog(@"Scrap request returned JSON: %@", json);
            [self processScrapResponse:json];
            [self scrapDone];
        }
            break;
    }

}

- (void)requestFailed:(ASIHTTPRequest *)request {
   NSError *error = [request error];
    NSLog(@"response failed: %@", [error debugDescription]);
}

- (IBAction)resetScrap:(id)sender {
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults removeObjectForKey:@"scrap"];
//    [userDefaults synchronize];

}

- (void)agreementViewDone:(BOOL)isAgree {
    NSLog(@"isAgree: %@", isAgree ? @"yes" : @"no");
    [self dismissModalViewControllerAnimated:YES];
    if (isAgree) {
        [self initSurvey];
        [self requestFacebookSession];
    }
}

- (IBAction)showAgreement:(id)sender {
    AgreementViewController *viewController = [[AgreementViewController alloc] initWithNibName:@"AgreementViewController" bundle:nil];
    viewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];


    [self presentModalViewController:navigationController animated:YES];
}

-(void)initSurvey {
    self.loginButton.hidden = YES;
    self.buttons.backgroundColor = [UIColor clearColor];
    self.buttons.hidden = YES;
    self.slider.hidden = YES;
    self.button.hidden = YES;
    self.textView.hidden = YES;
}

-(void)requestFacebookSession {
    [FBSession openActiveSessionWithReadPermissions:[NSArray arrayWithObjects:@"user_education_history", @"friends_education_history", nil] allowLoginUI:YES completionHandler:^(FBSession *session,
                                                                                     FBSessionState state,
                                                                                     NSError *error) {
                                                                     [self sessionStateChanged:session
                                                                                         state:state
                                                                                         error:error];
                                                                 }];
}
@end
