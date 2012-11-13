//
//  AgreementViewController.m
//  Pasteur
//
//  Created by Damir Suleymanov on 11/12/12.
//  Copyright (c) 2012 Harvard University. All rights reserved.
//

#import "AgreementViewController.h"


@implementation AgreementViewController
@synthesize webView;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *agreeButton = [[UIBarButtonItem alloc] initWithTitle:@"Agree" style:UIBarButtonItemStyleBordered target:self action:@selector(buttonAgree:)];
    self.navigationItem.rightBarButtonItem = agreeButton;
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(buttonCancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;

    NSURL *url = [NSURL URLWithString:@"https://docs.google.com/document/pub?id=1stHetmKGzaiHdE4VWsokpFnQvi99K3KEEVoaJ4XCbiQ"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)buttonAgree:(id)sender {
    [delegate agreementViewDone: YES];
}

- (void)buttonCancel:(id)sender {
    [delegate agreementViewDone: NO];
}
@end
