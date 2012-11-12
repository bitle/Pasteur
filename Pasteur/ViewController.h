//
//  ViewController.h
//  Pasteur
//
//  Created by Damir Suleymanov on 11/10/12.
//  Copyright (c) 2012 Harvard University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIScrollViewDelegate> {
    UITextView *textView;
    NSArray *questions;
    NSUInteger currentIndex;
    UIView *buttons;
    UISlider *slider;
    UIButton *button;
}

@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UISlider *slider;
@property (nonatomic, strong) IBOutlet UIView *buttons;
@property (nonatomic, strong) IBOutlet UIButton *button;
@property (strong) NSArray *questions;

- (IBAction)updateQuestion:(id)sender;
- (IBAction)buttonClicked:(id)sender;
@end
