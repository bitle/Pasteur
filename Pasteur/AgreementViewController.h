//
//  AgreementViewController.h
//  Pasteur
//
//  Created by Damir Suleymanov on 11/12/12.
//  Copyright (c) 2012 Harvard University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AgreementViewController : UIViewController {
    UIWebView *webView;
    id delegate;
}

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic) id delegate;
@end
