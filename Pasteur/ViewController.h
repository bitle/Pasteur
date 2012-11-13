//
//  ViewController.h
//  Pasteur
//
//  Created by Damir Suleymanov on 11/10/12.
//  Copyright (c) 2012 Harvard University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgreementViewController.h"

@interface ViewController : UIViewController <UIScrollViewDelegate, AgreementViewDelegate> {
    UITextView *textView;
    NSArray *questions;
    NSMutableArray *answers;
    NSUInteger currentIndex;
    UIView *buttons;
    UISlider *slider;
    UIButton *button;
    NSMutableDictionary *userData;
    NSString *lastAnswer;

    NSString *diagnoseOk;
    NSString *diagnoseSick;
}

@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UISlider *slider;
@property (nonatomic, strong) IBOutlet UIView *buttons;
@property (nonatomic, strong) IBOutlet UIButton *button;
@property (strong) NSArray *questions;

- (IBAction)updateQuestion:(id)sender;
- (IBAction)buttonClicked:(id)sender;
- (IBAction)sliderChanged:(id)sender;
- (IBAction)resetScrap:(id)sender;
@end
