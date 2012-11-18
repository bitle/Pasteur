//
//  ViewController.h
//  Pasteur
//
//  Created by Damir Suleymanov on 11/10/12.
//  Copyright (c) 2012 Harvard University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgreementViewController.h"

@interface ViewController : UIViewController <UIScrollViewDelegate, AgreementViewDelegate, CLLocationManagerDelegate> {
    
    CLLocationManager *locationManager;
    CLLocation *bestEffortAtLocation;
    
    NSArray *questions;
    NSMutableArray *answers;
    NSUInteger currentIndex;
    UISlider *slider;
    UIButton *button;
    UIButton *loginButton;
    NSMutableDictionary *userData;
    NSString *lastAnswer;
    BOOL isButton;

    NSString *diagnoseOk;
    NSString *diagnoseSick;
    UIScrollView *scrollView;
    UIView *tempView;

    UILabel *label;

    UIButton *button1;
    UIButton *buttonSubmit;

    UISegmentedControl *segmentedControl1;
    UISegmentedControl *segmentedControl2;
    UISegmentedControl *segmentedControl3;
    UISegmentedControl *segmentedControl4;
    UISegmentedControl *segmentedControl5;
    UISegmentedControl *segmentedControl6;
    UISegmentedControl *segmentedControl7;
    UISegmentedControl *segmentedControl8;
    
    BOOL shouldChangePage;
    NSUInteger schedulledPage;

    NSArray *strings;
}

@property (nonatomic, strong) CLLocation *bestEffortAtLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) IBOutlet UISlider *slider;
@property (nonatomic, strong) IBOutlet UIButton *loginButton;
@property (strong) NSArray *questions;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *tempView;

@property (nonatomic, strong) IBOutlet UILabel *label;

@property (nonatomic, strong) IBOutlet UIButton *button1;
@property (nonatomic, strong) IBOutlet UIButton *buttonSubmit;

@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl1;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl2;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl3;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl4;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl5;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl6;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl7;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl8;

- (IBAction)updateQuestion:(id)sender;
- (IBAction)buttonClicked:(id)sender;
- (IBAction)sliderChanged:(id)sender;
- (IBAction)showAgreement:(id)sender;

-(void)reset;
- (void)startLocationTracker;
- (void)stopUpdatingLocation;
@end
