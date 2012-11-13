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
#import "UIButton+Glossy.h"
#import "AgreementViewController.h"

@implementation ViewController
@synthesize questions;
@synthesize slider;
@synthesize loginButton;
@synthesize scrollView;
@synthesize tempView;

@synthesize button1;
@synthesize button2yes;
@synthesize button3yes;
@synthesize button4yes;
@synthesize button5yes;
@synthesize button6yes;
@synthesize button7yes;
@synthesize button8yes;
@synthesize button2no;
@synthesize button3no;
@synthesize button4no;
@synthesize button5no;
@synthesize button6no;
@synthesize button7no;
@synthesize button8no;
@synthesize buttonSubmit;
@synthesize label;

@synthesize textView1;
@synthesize textView2;
@synthesize textView3;
@synthesize textView4;
@synthesize textView5;
@synthesize textView6;
@synthesize textView7;
@synthesize textView8;
@synthesize textView9;

@synthesize segmentedControl1;
@synthesize segmentedControl2;
@synthesize segmentedControl3;
@synthesize segmentedControl4;
@synthesize segmentedControl5;
@synthesize segmentedControl6;
@synthesize segmentedControl7;
@synthesize segmentedControl8;



- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if (FBSession.activeSession.state != FBSessionStateCreatedTokenLoaded) {
        NSLog(@"Loggin in");
        self.loginButton.hidden = NO;
        self.tempView.hidden = YES;
    } else {
        NSLog(@"No login needed");
        [self initSurvey];
        [self requestFacebookSession];
    }

    UIImage *buttonImage = [[UIImage imageNamed:@"greyButton@2x.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"greyButtonHighlight@2x.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];

    [buttonSubmit setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [buttonSubmit setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];

    UIImage *fb1 = [UIImage imageNamed:@"fb-login-button-small@2x.png"];
    UIImage *fb2 = [UIImage imageNamed:@"fb-login-button-small-pressed@2x.png"];

    [loginButton setBackgroundImage:fb1 forState:UIControlStateNormal];
    [loginButton setBackgroundImage:fb2 forState:UIControlStateHighlighted];

    self.tempView.backgroundColor = [UIColor clearColor];
    self.scrollView.backgroundColor = [UIColor clearColor];

    userData = [NSMutableDictionary dictionaryWithCapacity:3];
    answers = [NSMutableArray arrayWithCapacity:8];
    for (int i = 0; i < 8; i++) {
        [answers addObject:@""];
    }
    self.label.hidden = YES;

    self.textView1.backgroundColor = [UIColor clearColor];
    self.textView2.backgroundColor = [UIColor clearColor];
    self.textView3.backgroundColor = [UIColor clearColor];
    self.textView4.backgroundColor = [UIColor clearColor];
    self.textView5.backgroundColor = [UIColor clearColor];
    self.textView6.backgroundColor = [UIColor clearColor];
    self.textView7.backgroundColor = [UIColor clearColor];
    self.textView8.backgroundColor = [UIColor clearColor];
    self.textView9.backgroundColor = [UIColor clearColor];

    [segmentedControl1 setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [segmentedControl2 setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [segmentedControl3 setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [segmentedControl4 setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [segmentedControl5 setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [segmentedControl6 setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [segmentedControl7 setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [segmentedControl8 setSelectedSegmentIndex:UISegmentedControlNoSegment];
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
    isButton = YES;
    if ([sender tag] == 0) {
        UISegmentedControl *s = sender;
        NSString *a = s.selectedSegmentIndex == 0 ? @"yes" : @"no";
        [answers replaceObjectAtIndex:currentIndex withObject:a];
    } else if ([sender tag] == 1) {
        //[answers replaceObjectAtIndex:currentIndex withObject:@"yes"];
    } else if ([sender tag] == 2) {
        NSLog(@"answers: %@", answers);
        [self finishSurvey];
    } else if ([sender tag] == 3) {
        [answers replaceObjectAtIndex:currentIndex withObject: [NSString stringWithFormat: @"%d", self.segmentedControl1.selectedSegmentIndex]];
    }
    currentIndex++;
    CGRect frame = self.scrollView.frame;
    frame.origin.x += frame.size.width*currentIndex;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

- (void)finishSurvey {
    NSLog(@"Finish Survey");
    self.tempView.hidden = YES;
    self.label.hidden = NO;
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
    [self updateQuestion:sender];
}

- (IBAction)sliderChanged:(id)sender {

    float f = self.slider.value;
    NSString *text = nil;
    if (f < 1) {
        text = @"Bad";
    } else if (1 <= f && f < 2) {
        text = @"Not so well";
    } else if (2 <= f && f < 3) {
        text = @"Just OK";
    } else if (3 <= f && f < 4) {
        text = @"Good";
    } else if (4 <= f && f <= 5) {
        text = @"Excellent";
    }
    lastAnswer = text;
    [self.button1 setTitle:text forState:UIControlStateNormal];
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
        }
            break;
        case 3:
            NSLog(@"Post request finished: %@", [request responseString]);
            self.tempView.hidden = YES;
            self.label.hidden = NO;
            //[self reset];
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
    self.tempView.hidden = NO;


    self.scrollView.contentSize = CGSizeMake(2880.0, scrollView.frame.size.height);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    [self.tempView addSubview: self.scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    isButton = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView1 {
    if (isButton) {
        return;
    }
    CGFloat pageWidth = scrollView.frame.size.width;
    currentIndex = (NSUInteger)(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1);
    NSLog(@"scrollViewDidScroll: %d", currentIndex);
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

- (void)reset {
    currentIndex = 0;
    for (int i = 0; i < 8; i++) {
        [answers replaceObjectAtIndex:i withObject:@""];
    }

    CGRect frame = self.scrollView.frame;
    frame.origin.x += frame.size.width*currentIndex;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];

    self.tempView.hidden = NO;
    self.label.hidden = YES;

    [segmentedControl1 setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [segmentedControl2 setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [segmentedControl3 setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [segmentedControl4 setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [segmentedControl5 setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [segmentedControl6 setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [segmentedControl7 setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [segmentedControl8 setSelectedSegmentIndex:UISegmentedControlNoSegment];
}
@end
