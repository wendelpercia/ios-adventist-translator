// Copyright 2009-2010 The 'Mumble for iOS' Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

#import "MUWelcomeScreenPhone.h"

#import "MUPublicServerListController.h"
#import "MUFavouriteServerListController.h"
#import "MULanServerListController.h"
#import "MUPreferencesViewController.h"
#import "MUServerRootViewController.h"
#import "MUNotificationController.h"
#import "MULegalViewController.h"
#import "MUImage.h"
#import "MUOperatingSystem.h"
#import "MUBackgroundView.h"
#import "MUColor.h"
#import "MUConnectionController.h"
#import "MUApplicationDelegate.h"

@interface MUWelcomeScreen () {
    NSInteger    _aboutWebsiteButton;
    NSInteger    _aboutContribButton;
    NSInteger    _aboutLegalButton;
    UILabel* lbMessage;
    UIActivityIndicatorView* loading;
    
    UIImageView                      *_translateLogo;
    UIImageView                      *_iatecLogo;
    
    UIButton *_btReconnect;
}
@end

@implementation MUWelcomeScreen

- (id) init {
    self = [super init];
    return self;
}

- (void) dealloc {
    [lbMessage release];
    [loading release];
    
    [super dealloc];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    lbMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, self.view.frame.size.width, 20)];
    [lbMessage setFont:[UIFont systemFontOfSize:15]];
    [lbMessage setTextAlignment:NSTextAlignmentCenter];
    [lbMessage setTextColor:[UIColor whiteColor]];
    [lbMessage setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];

    [self.view addSubview:lbMessage];
    
    _iatecLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IatecLogo"]];
    [_iatecLogo setFrame:CGRectMake( self.view.frame.size.width - 140, -100, _iatecLogo.frame.size.width, _iatecLogo.frame.size.height)];
    [_iatecLogo setAlpha:0.15f];
    [self.view addSubview:_iatecLogo];
    
    _translateLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"translatelogo"]];
    [_translateLogo setCenter:CGPointMake(self.view.frame.size.width / 2.0f, 140)];
    [self.view addSubview:_translateLogo];

    loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [loading setCenter: self.view.center];
    
    [self.view addSubview:loading];
    [loading startAnimating];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MuConnecting) name:MUConnectingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MuConnectingError) name:MUConnectingErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MUConnectionOpened) name:MUConnectionOpenedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MUConnectionClosed) name:MUConnectionClosedNotification object:nil];
}

-(void)MuConnecting{
    [lbMessage setText:NSLocalizedString(@"Connecting", nil)];
    [loading startAnimating];
}

-(void)MuConnectingError {
    [lbMessage setText:NSLocalizedString(@"Connection Error", nil)];
    [loading stopAnimating];
    
    [self showReconnect];
}

-(void)MUConnectionOpened{
    [lbMessage setText:NSLocalizedString(@"Connected", nil)];
    [loading stopAnimating];
}

-(void)MUConnectionClosed{
    [lbMessage setText:NSLocalizedString(@"Connection Closed", nil)];
    [loading stopAnimating];
    
    [self showReconnect];
}

-(void)showReconnect{
    if (_btReconnect == nil){
        _btReconnect = [UIButton buttonWithType:UIButtonTypeSystem];
        _btReconnect.frame = CGRectMake(0, 0, 180, 44);
        [_btReconnect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btReconnect setTitle:NSLocalizedString(@"Reconnect", nil) forState:UIControlStateNormal];
        [_btReconnect setCenter:self.view.center];
        [_btReconnect addTarget:self action:@selector(Reconnect) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_btReconnect];
        
    }
}

-(void)Reconnect{
    [_btReconnect removeFromSuperview];
    [_btReconnect release];
    _btReconnect = nil;
    [loading startAnimating];
    
    MUApplicationDelegate* md = (MUApplicationDelegate*)[UIApplication sharedApplication].delegate;
    [md connect];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)[MUColor MainColor].CGColor, (id)[MUColor MainDarkerColor].CGColor];
    [self.view.layer insertSublayer:gradient atIndex:0];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
