//
//  ViewController.m
//  Pasteur
//
//  Created by Damir Suleymanov on 11/10/12.
//  Copyright (c) 2012 Harvard University. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "ViewController.h"
#import "SBJson.h"

@implementation CLLocation (Strings)

- (NSString *)localizedCoordinateString {
    if (self.horizontalAccuracy < 0) {
        return @"Data Unavailable";
    }
    
    return [NSString stringWithFormat:@"{lat: %f, lon: %f}", self.coordinate.latitude, self.coordinate.longitude];
}

@end

@implementation ViewController
@synthesize bestEffortAtLocation;
@synthesize locationManager;
@synthesize questions;
@synthesize loginButton;
@synthesize scrollView;
@synthesize tempView;
@synthesize confirmationLabel;
@synthesize activityIndicator;

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
        [self startLocationTracker];
        [self fetchQuestionsAsync];
    }

    UIImage *fb1 = [UIImage imageNamed:@"fb-login-button-small@2x.png"];
    UIImage *fb2 = [UIImage imageNamed:@"fb-login-button-small-pressed@2x.png"];

    [loginButton setBackgroundImage:fb1 forState:UIControlStateNormal];
    [loginButton setBackgroundImage:fb2 forState:UIControlStateHighlighted];

    self.tempView.backgroundColor = [UIColor clearColor];
    self.scrollView.backgroundColor = [UIColor clearColor];

    userData = [NSMutableDictionary dictionaryWithCapacity:3];

    self.confirmationLabel.hidden = YES;
}

- (UITextView *)createTextView: (NSUInteger)page withText: (NSString *)text {
    CGFloat x = 41 + 320*page;
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(x, 383, 238, 52)];
    textView.editable = false;
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [UIColor whiteColor];
    textView.font = [UIFont boldSystemFontOfSize:18];
    textView.text = text;
    textView.textAlignment = NSTextAlignmentCenter;

    return textView;
}

- (UISegmentedControl *)createSegmentControl: (NSArray *)segments onPage: (NSUInteger)page {
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems: segments];
    [segmentedControl addTarget:self action:@selector(updateQuestion:) forControlEvents: UIControlEventValueChanged];
    CGRect frame = segmentedControl.frame;
    frame.origin.x = 160 + 320*page - frame.size.width / 2;
    frame.origin.y = 496;

    segmentedControl.frame = frame;
    return segmentedControl;
}

- (void)createQuestions: (NSArray *)theQuestions {
    self.tempView.hidden = NO;

    answers = [NSMutableArray arrayWithCapacity: theQuestions.count - 2];
    for (int i = 0; i < theQuestions.count - 2; i++) {
        [answers addObject:@""];
    }

    self.scrollView.contentSize = CGSizeMake(theQuestions.count*320, self.scrollView.frame.size.height);
    for (NSUInteger i = 0; i < theQuestions.count - 1; i++) {
        NSDictionary *questionModel = [theQuestions objectAtIndex:i];
        NSString *questionString = [questionModel objectForKey:@"question"];
        NSString *type = [questionModel objectForKey:@"type"];

        if ([type isEqualToString:@"segment"]) {
            [self.scrollView addSubview: [self createTextView: i withText:questionString]];
            NSArray *segments = [questionModel objectForKey:@"segments"];

            UISegmentedControl *sc = [self createSegmentControl:segments onPage:i];
                        [self.scrollView addSubview:sc];
        } else if ([type isEqualToString:@"submit"]) {
            [self.scrollView addSubview: [self createTextView: i withText:questionString]];
             // create Button
            CGFloat x = 113 + 320*i;
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, 478, 95, 36)];
            UIImage *buttonImage = [[UIImage imageNamed:@"greyButton@2x.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
            UIImage *buttonImageHighlight = [[UIImage imageNamed:@"greyButtonHighlight@2x.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];

            [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
            [button setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];

            [button setTitle:@"Submit" forState:UIControlStateNormal];
            [button setTitle:@"Submit" forState:UIControlStateHighlighted];
            button.tag = 2;

            CGFloat r = (float)151.0/255.0;
            CGFloat g = r;
            CGFloat b = r;

            button.titleLabel.shadowOffset = CGSizeMake(0, 1);
            button.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
            button.titleLabel.shadowColor = [UIColor whiteColor];
            button.titleLabel.textColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];

            [button addTarget:self action:@selector(updateQuestion:) forControlEvents: UIControlEventTouchUpInside];

            [self.scrollView addSubview:button];
        } else if ([type isEqualToString:@"confirmation"]) {
            // don't create anything but text view
            self.confirmationLabel.text = questionString;
        }
    }
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

- (void)fetchQuestionsAsync {
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    NSURL *url = [NSURL URLWithString:@"https://script.google.com/macros/s/AKfycbwpef4lya6GTyBiLn6tqIEldmGPgk4cbE4L0Nt1yaARin3YKq3o/exec"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.delegate = self;
    request.tag = 2;
    [request startAsynchronous];
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
    if ([sender tag] == 2) {
        NSLog(@"answers: %@", answers);
        [self finishSurvey];
    } else {
        [answers replaceObjectAtIndex:currentIndex withObject: [NSString stringWithFormat: @"%d", [sender selectedSegmentIndex]]];
    }

    NSInteger offset = self.scrollView.contentOffset.x;
    if (offset % 320 == 0) {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width*(currentIndex+1);
        frame.origin.y = 0;
        [self.scrollView scrollRectToVisible:frame animated:YES];
    } else {
        shouldChangePage = YES;
        schedulledPage = currentIndex + 1;
    }
}

- (void)finishSurvey {
    self.tempView.hidden = YES;
    self.confirmationLabel.hidden = NO;
    [userData setObject:answers forKey:@"questions"];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *answersId = [userDefaults objectForKey:@"answersId"];
    [userData setObject:answersId forKey:@"answersId"];
    
    NSMutableDictionary *cords = [NSMutableDictionary dictionaryWithCapacity:2];

    [cords setObject: [NSNumber numberWithDouble:self.bestEffortAtLocation.coordinate.latitude] forKey:@"lat"];
    [cords setObject:[NSNumber numberWithDouble:self.bestEffortAtLocation.coordinate.longitude] forKey:@"lon"];
    
    [userData setObject: cords forKey:@"cord"];

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

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSLog(@"request finished: %d", request.tag);
    NSLog(@"response string: %@", [request responseString]);
    switch (request.tag) {
        case 2:
        {
            // Use when fetching text data
            NSString *responseString = [request responseString];
            NSArray *theQuestions = [responseString JSONValue];

            self.questions = theQuestions;
            [self createQuestions: theQuestions];
            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden = YES;
        }
            break;
        case 3:
            self.tempView.hidden = YES;
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
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
}

- (void)agreementViewDone:(BOOL)isAgree {
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


    self.scrollView.contentSize = CGSizeMake(9*scrollView.frame.size.width, scrollView.frame.size.height);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    [self.tempView addSubview: self.scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView1 {
    CGFloat pageWidth = scrollView.frame.size.width;
    currentIndex = (NSUInteger)(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1);
    NSInteger offset = scrollView.contentOffset.x;
    if (offset % 320 == 0) {
        NSLog(@"done scrolling");
        [self scroll];
    }
}

- (void)scroll {
    if (shouldChangePage) {
        shouldChangePage = NO;
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width*(schedulledPage);
        frame.origin.y = 0;
        NSLog(@"New offset: %f", frame.origin.x);
        [self.scrollView scrollRectToVisible:frame animated:YES];
    }
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
    answers = nil;

    CGRect frame = self.scrollView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:NO];
    for(UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }

    self.scrollView.contentSize = CGSizeMake(320, self.scrollView.frame.size.height);

    [self fetchQuestionsAsync];

    self.tempView.hidden = NO;
    self.confirmationLabel.hidden = YES;
}

- (void)startLocationTracker {
    NSLog(@"startLocationTracker");
    self.locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [locationManager startUpdatingLocation];
}


#pragma mark - Location Delegate
/*
 * We want to get and store a location measurement that meets the desired accuracy. For this example, we are
 *      going to use horizontal accuracy as the deciding factor. In other cases, you may wish to use vertical
 *      accuracy, or both together.
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // store all of the measurements, just so we can see what kind of data we might receive
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) return;
    // test the measurement to see if it is more accurate than the previous measurement
    if (bestEffortAtLocation == nil || bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        // store the location as the "best effort"
        self.bestEffortAtLocation = newLocation;
        NSLog(@"Got new location: %@", [newLocation localizedCoordinateString]);
        // test the measurement to see if it meets the desired accuracy
        //
        // IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue
        // accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of
        // acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
        //
        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
            // we have a measurement that meets our requirements, so we can stop updating the location
            //
            // IMPORTANT!!! Minimize power usage by stopping the location manager as soon as possible.
            //
            [self stopUpdatingLocation];
            // we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation) object:nil];
        }
    }
}

- (void)stopUpdatingLocation {
    NSLog(@"stopUpdatingLocation");
    [locationManager stopUpdatingLocation];
    locationManager.delegate = nil;
    self.locationManager = nil;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // The location "unknown" error simply means the manager is currently unable to get the location.
    // We can ignore this error for the scenario of getting a single location fix, because we already have a
    // timeout that will stop the location manager to save power.
    if ([error code] != kCLErrorLocationUnknown) {
        [self stopUpdatingLocation];
    }
}
@end
