//
//  AgreementViewController.h
//  Pasteur
//
//  Created by Damir Suleymanov on 11/12/12.
//  Copyright (c) 2012 Harvard University. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AgreementViewDelegate
- (void)agreementViewDone:(BOOL)isAgree;
@end

@interface AgreementViewController : UIViewController {
    UIWebView *webView;
    id<AgreementViewDelegate> delegate;
}

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic) id delegate;
@end
