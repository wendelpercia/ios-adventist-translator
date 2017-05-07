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
#import "MUTranslatorController.h"

#import "MUApplicationDelegate.h"


@interface MUWelcomeScreenPhone () {
    UIAlertView  *_aboutView;
    NSInteger    _aboutWebsiteButton;
    NSInteger    _aboutContribButton;
    NSInteger    _aboutLegalButton;
}
@end

#define MUMBLE_LAUNCH_IMAGE_CREATION 0

@implementation MUWelcomeScreenPhone

- (id) init {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // ...
    }
    return self;
}

- (void) dealloc {
    [super dealloc];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationItem.title = @"Translator";
    self.navigationController.toolbarHidden = YES;

    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (MUGetOperatingSystemVersion() >= MUMBLE_OS_IOS_7) {
        navBar.tintColor = [UIColor whiteColor];
        navBar.translucent = NO;
        navBar.backgroundColor = [UIColor blackColor];
        //navBar.backgroundColor = [UIColor blueColor];
    }
    navBar.barStyle = UIBarStyleBlackOpaque;
    //navBar.barStyle = UIBarStyleBlackTranslucent;

    self.tableView.backgroundView = [MUBackgroundView backgroundView];
    
    if (MUGetOperatingSystemVersion() >= MUMBLE_OS_IOS_7) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.separatorInset = UIEdgeInsetsZero;
    } else {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }

    self.tableView.scrollEnabled = NO;
    
#if MUMBLE_LAUNCH_IMAGE_CREATION != 1
    UIBarButtonItem *about = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"About", nil)
                                                                style:UIBarButtonItemStyleBordered
                                                                target:self
                                                                action:@selector(aboutClicked:)];
    [self.navigationItem setRightBarButtonItem:about];
    [about release];
    
    UIBarButtonItem *prefs = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Preferences", nil)
                                                                style:UIBarButtonItemStyleBordered
                                                                target:self
                                                                action:@selector(prefsClicked:)];
    [self.navigationItem setLeftBarButtonItem:prefs];
    [prefs release];
#endif
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark -
#pragma mark TableView

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#if MUMBLE_LAUNCH_IMAGE_CREATION == 1
    return 1;
#endif
    if (section == 0)
        //return 3;
        //Table Lines
        return 1;
    return 0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIImage *img = [MUImage imageNamed:@"WelcomeScreenIcon"];
    UIImageView *imgView = [[[UIImageView alloc] initWithImage:img] autorelease];
    [imgView setContentMode:UIViewContentModeCenter];
    [imgView setFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
    return imgView;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
#if MUMBLE_LAUNCH_IMAGE_CREATION == 1
    CGFloat statusBarAndTitleBarHeight = 64;
    return [UIScreen mainScreen].bounds.size.height - statusBarAndTitleBarHeight;
#endif
    UIImage *img = [MUImage imageNamed:@"WelcomeScreenIcon"];
    return img.size.height;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"welcomeItem"];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"welcomeItem"] autorelease];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    /* Servers section. */
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Favourite Servers", nil);
        }
    }
    
    [[cell textLabel] setHidden: NO];

    return cell;
}

// Override to support row selection in the table view.
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /* Servers section. */
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            int *vai = 1;
            
            if (vai == 1) {
                MUTranslatorController *openTrans = [[[MUTranslatorController alloc] init] autorelease];
                [self.navigationController pushViewController:openTrans animated:YES];
            } else {
                MUFavouriteServerListController *favList = [[[MUFavouriteServerListController alloc] init] autorelease];
                [self.navigationController pushViewController:favList animated:YES];
            }
            
        }
    }
    
}

- (void) aboutClicked:(id)sender {
#ifdef MUMBLE_BETA_DIST
    NSString *aboutTitle = [NSString stringWithFormat:@"Translator %@ (%@)",
                            //[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
                            [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                            
                            [[NSBundle mainBundle] objectForInfoDictionaryKey:@"MumbleGitRevision"]];
#else
    NSString *aboutTitle = [NSString stringWithFormat:@"Translator %@",
                            //[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
                            [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
#endif
    NSString *aboutMessage = NSLocalizedString(@"aboutMessage", nil);
    
    UIAlertView *aboutView = [[UIAlertView alloc] initWithTitle:aboutTitle message:aboutMessage delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:NSLocalizedString(@"Legal", nil),
                                                                NSLocalizedString(@"Support", nil), nil];

    
    [aboutView show];
    [aboutView release];
}

- (void) prefsClicked:(id)sender {
    MUPreferencesViewController *prefs = [[[MUPreferencesViewController alloc] init] autorelease];
    [self.navigationController pushViewController:prefs animated:YES];
}

#pragma mark -
#pragma mark About Dialog

- (void) alertView:(UIAlertView *)alert didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.iatec.com"]];
    } else if (buttonIndex == 2) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.iatec.com"]];
    }
    
}

@end
