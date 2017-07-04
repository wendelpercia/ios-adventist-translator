// Copyright 2009-2011 The 'Mumble for iOS' Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

#import "MUConnectionController.h"
#import "MUServerRootViewController.h"
#import "MUServerCertificateTrustViewController.h"
#import "MUCertificateController.h"
#import "MUCertificateChainBuilder.h"
#import "MUDatabase.h"
#import "MUOperatingSystem.h"
#import "MUHorizontalFlipTransitionDelegate.h"

#import <MumbleKit/MKConnection.h>
#import <MumbleKit/MKServerModel.h>
#import <MumbleKit/MKCertificate.h>

NSString *MUConnectionOpenedNotification = @"MUConnectionOpenedNotification";
NSString *MUConnectionClosedNotification = @"MUConnectionClosedNotification";
NSString *MUConnectingNotification = @"MUConnectingNotification";
NSString *MUConnectingErrorNotification = @"MUConnectingErrorNotification";

@interface MUConnectionController () <MKConnectionDelegate, MKServerModelDelegate, MUServerCertificateTrustViewControllerProtocol> {
    MKConnection               *_connection;
    MKServerModel              *_serverModel;
    MUServerRootViewController *_serverRoot;
    UIViewController           *_parentViewController;
    UIAlertView                *_alertView;
    NSTimer                    *_timer;
    int                        _numDots;

    UIAlertView                *_rejectAlertView;
    MKRejectReason             _rejectReason;

    NSString                   *_hostname;
    NSUInteger                 _port;
    NSString                   *_username;
    NSString                   *_password;

    id                         _transitioningDelegate;
}
- (void) establishConnection;
- (void) teardownConnection;
- (void) showConnectingMessage;
@end

@implementation MUConnectionController

+ (MUConnectionController *) sharedController {
    static MUConnectionController *nc;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        nc = [[MUConnectionController alloc] init];
    });
    return nc;
}

- (id) init {
    if ((self = [super init])) {
        if (MUGetOperatingSystemVersion() >= MUMBLE_OS_IOS_7) {
            _transitioningDelegate = [[MUHorizontalFlipTransitionDelegate alloc] init];
        }
    }
    return self;
}

- (void) dealloc {
    [super dealloc];

    [_transitioningDelegate release];
}

-(void)sendNotification:(NSString*)notification{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
    });
}

- (void) connetToHostname:(NSString *)hostName port:(NSUInteger)port withUsername:(NSString *)userName andPassword:(NSString *)password withParentViewController:(UIViewController *)parentViewController {
    _hostname = [hostName retain];
    _port = port;
    _username = [userName retain];
    _password = [password retain];
    
    [self establishConnection];
    [self showConnectingMessage];
    
    if(_parentViewController != nil){
        [_parentViewController release];
    }

    _parentViewController = [parentViewController retain];
}

- (BOOL) isConnected {
    return _connection != nil;
}

- (void) disconnectFromServer {
    [_serverRoot dismissModalViewControllerAnimated:YES];
    [self teardownConnection];
}

- (void) showConnectingMessage {
    [self sendNotification:MUConnectingNotification];
}

- (void) establishConnection {
    _connection = [[MKConnection alloc] init];
    [_connection setIgnoreSSLVerification:true];
    [_connection setDelegate:self];
    [_connection setForceTCP:[[NSUserDefaults standardUserDefaults] boolForKey:@"NetworkForceTCP"]];
    
    
    _serverModel = [[MKServerModel alloc] initWithConnection:_connection];
    [_serverModel addDelegate:self];
    
    _serverRoot = [[MUServerRootViewController alloc] initWithConnection:_connection andServerModel:_serverModel];
    
    // Set the connection's client cert if one is set in the app's preferences...
    NSData *certPersistentId = [[NSUserDefaults standardUserDefaults] objectForKey:@"DefaultCertificate"];
    if (certPersistentId != nil) {
        NSArray *certChain = [MUCertificateChainBuilder buildChainFromPersistentRef:certPersistentId];
        [_connection setCertificateChain:certChain];
    }
    
    [_connection connectToHost:_hostname port:_port];
}


- (void) teardownConnection{
    [self teardownConnectionWithNotification:true];
}

- (void) teardownConnectionWithNotification:(BOOL)sendNotification {
    [_serverModel removeDelegate:self];
    [_serverModel release];
    _serverModel = nil;
    [_connection setDelegate:nil];
    [_connection disconnect];
    [_connection release]; 
    _connection = nil;
    [_timer invalidate];
    [_serverRoot release];
    _serverRoot = nil;
    
    // Reset app badge. The connection is no more.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    if (sendNotification)
        [self sendNotification:MUConnectionClosedNotification];
}
            
- (void) updateTitle {
    ++_numDots;
    if (_numDots > 3)
        _numDots = 0;

    NSString *dots = @"   ";
    if (_numDots == 1) { dots = @".  "; }
    if (_numDots == 2) { dots = @".. "; }
    if (_numDots == 3) { dots = @"..."; }
    
    [_alertView setTitle:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Connecting", nil), dots]];
}

#pragma mark - MKConnectionDelegate

- (void) connectionOpened:(MKConnection *)conn {
    NSArray *tokens = [MUDatabase accessTokensForServerWithHostname:[conn hostname] port:[conn port]];
    [conn authenticateWithUsername:_username password:_password accessTokens:tokens];
    [self sendNotification:MUConnectionOpenedNotification];
}

- (void) connection:(MKConnection *)conn closedWithError:(NSError *)err {
    if (err) {
        [self teardownConnectionWithNotification:false];
        [self sendNotification:MUConnectingErrorNotification];
    }
}

- (void) connection:(MKConnection*)conn unableToConnectWithError:(NSError *)err {
    [self teardownConnectionWithNotification:false];
    [self sendNotification:MUConnectingErrorNotification];
}

// The connection encountered an invalid SSL certificate chain.
- (void) connection:(MKConnection *)conn trustFailureInCertificateChain:(NSArray *)chain {
    [conn setIgnoreSSLVerification:YES];
    [conn reconnect];
}

// The server rejected our connection.
- (void) connection:(MKConnection *)conn rejectedWithReason:(MKRejectReason)reason explanation:(NSString *)explanation {
    [self teardownConnection];
    
   /* switch (reason) {
        case MKRejectReasonNone:
        case MKRejectReasonWrongVersion:
        case MKRejectReasonInvalidUsername:
        case MKRejectReasonWrongUserPassword:
        case MKRejectReasonWrongServerPassword:
        case MKRejectReasonUsernameInUse:
        case MKRejectReasonServerIsFull:
        case MKRejectReasonNoCertificate:
            break;
    }*/
}

#pragma mark - MKServerModelDelegate

- (void) serverModel:(MKServerModel *)model joinedServerAsUser:(MKUser *)user {
    [MUDatabase storeUsername:[user userName] forServerWithHostname:[model hostname] port:[model port]];

    //self hideConnectingView];

    [_serverRoot takeOwnershipOfConnectionDelegate];

    [_username release];
    _username = nil;
    [_hostname release];
    _hostname = nil;
    [_password release];
    _password = nil;

    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
        if (MUGetOperatingSystemVersion() >= MUMBLE_OS_IOS_7) {
            [_serverRoot setTransitioningDelegate:_transitioningDelegate];
        } else {
            [_serverRoot setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        }
    }

    [_parentViewController presentModalViewController:_serverRoot animated:YES];
    [_parentViewController release];
    _parentViewController = nil;
}

- (void) serverCertificateTrustViewControllerDidDismiss:(MUServerCertificateTrustViewController *)trustView {
    [self showConnectingMessage];
    [_connection reconnect];
}

@end
