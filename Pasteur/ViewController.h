//
//  ViewController.h
//  Pasteur
//
//  Created by Damir Suleymanov on 11/10/12.
//  Copyright (c) 2012 Harvard University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    UITextView *textView;
    NSArray *questions;
    NSUInteger currentIndex;
}

@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (strong) NSArray *questions;

- (IBAction)updateQuestion;
@end
