//
//  ViewController.h
//  Pasteur
//
//  Created by Damir Suleymanov on 11/10/12.
//  Copyright (c) 2012 Harvard University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ASIHTTPRequest/ASIHTTPRequest.h>
#import "AgreementViewController.h"

@interface ViewController : UIViewController <UIScrollViewDelegate, AgreementViewDelegate, CLLocationManagerDelegate, ASIHTTPRequestDelegate> {
    
    CLLocationManager *locationManager;
    CLLocation *bestEffortAtLocation;
    
    NSArray *questions;
    NSMutableArray *answers;
    NSUInteger currentIndex;
    UIButton *loginButton;
    NSMutableDictionary *userData;
    NSString *lastAnswer;

    UIScrollView *scrollView;
    UIView *tempView;
    
    BOOL shouldChangePage;
    NSUInteger schedulledPage;
    UILabel *confirmationLabel;
    UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, strong) CLLocation *bestEffortAtLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) IBOutlet UIButton *loginButton;
@property (strong) NSArray *questions;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *tempView;

@property (nonatomic, strong) IBOutlet UILabel *confirmationLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)updateQuestion:(id)sender;
- (IBAction)showAgreement:(id)sender;

-(void)reset;
- (void)startLocationTracker;
- (void)stopUpdatingLocation;
@end
