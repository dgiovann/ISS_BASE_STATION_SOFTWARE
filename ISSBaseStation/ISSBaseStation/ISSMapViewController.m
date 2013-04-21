//
//  ISSMapViewController.m
//  ISSBaseStation
//
//  Created by Matthew Thomas on 4/20/13.
//  Copyright (c) 2013 Matthew Thomas. All rights reserved.
//

#import "ISSMapViewController.h"

@interface ISSMapViewController ()

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation ISSMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mc.stwing.upenn.edu:3000"]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}


@end
