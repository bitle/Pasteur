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
    UIButton *button2yes;
    UIButton *button3yes;
    UIButton *button4yes;
    UIButton *button5yes;
    UIButton *button6yes;
    UIButton *button7yes;
    UIButton *button8yes;
    UIButton *button2no;
    UIButton *button3no;
    UIButton *button4no;
    UIButton *button5no;
    UIButton *button6no;
    UIButton *button7no;
    UIButton *button8no;
    UIButton *buttonSubmit;

    UITextView *textView1;
    UITextView *textView2;
    UITextView *textView3;
    UITextView *textView4;
    UITextView *textView5;
    UITextView *textView6;
    UITextView *textView7;
    UITextView *textView8;
    UITextView *textView9;

    UISegmentedControl *segmentedControl1;
    UISegmentedControl *segmentedControl2;
    UISegmentedControl *segmentedControl3;
    UISegmentedControl *segmentedControl4;
    UISegmentedControl *segmentedControl5;
    UISegmentedControl *segmentedControl6;
    UISegmentedControl *segmentedControl7;
    UISegmentedControl *segmentedControl8;
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
@property (nonatomic, strong) IBOutlet UIButton *button2yes;
@property (nonatomic, strong) IBOutlet UIButton *button3yes;
@property (nonatomic, strong) IBOutlet UIButton *button4yes;
@property (nonatomic, strong) IBOutlet UIButton *button5yes;
@property (nonatomic, strong) IBOutlet UIButton *button6yes;
@property (nonatomic, strong) IBOutlet UIButton *button7yes;
@property (nonatomic, strong) IBOutlet UIButton *button8yes;
@property (nonatomic, strong) IBOutlet UIButton *button2no;
@property (nonatomic, strong) IBOutlet UIButton *button3no;
@property (nonatomic, strong) IBOutlet UIButton *button4no;
@property (nonatomic, strong) IBOutlet UIButton *button5no;
@property (nonatomic, strong) IBOutlet UIButton *button6no;
@property (nonatomic, strong) IBOutlet UIButton *button7no;
@property (nonatomic, strong) IBOutlet UIButton *button8no;
@property (nonatomic, strong) IBOutlet UIButton *buttonSubmit;

@property (nonatomic, strong) IBOutlet UITextView *textView1;
@property (nonatomic, strong) IBOutlet UITextView *textView2;
@property (nonatomic, strong) IBOutlet UITextView *textView3;
@property (nonatomic, strong) IBOutlet UITextView *textView4;
@property (nonatomic, strong) IBOutlet UITextView *textView5;
@property (nonatomic, strong) IBOutlet UITextView *textView6;
@property (nonatomic, strong) IBOutlet UITextView *textView7;
@property (nonatomic, strong) IBOutlet UITextView *textView8;
@property (nonatomic, strong) IBOutlet UITextView *textView9;

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
