// Copyright 2009-2010 The 'Mumble for iOS' Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

#import "MUServerViewController.h"
#import "MUUserStateAcessoryView.h"
#import "MUNotificationController.h"
#import "MUColor.h"
#import "MUOperatingSystem.h"
#import "MUBackgroundView.h"
#import "MUServerTableViewCell.h"
#import "AboutViewController.h"
#import <MumbleKit/MKAudio.h>

#pragma mark -
#pragma mark MUChannelNavigationItem

@interface MUChannelNavigationItem : NSObject {
    id         _object;
    NSInteger  _indentLevel;
}

+ (MUChannelNavigationItem *) navigationItemWithObject:(id)obj indentLevel:(NSInteger)indentLevel;
- (id) initWithObject:(id)obj indentLevel:(NSInteger)indentLevel;
- (void) dealloc;
- (id) object;
- (NSInteger) indentLevel;
@end

@implementation MUChannelNavigationItem

+ (MUChannelNavigationItem *) navigationItemWithObject:(id)obj indentLevel:(NSInteger)indentLevel {
    return [[[MUChannelNavigationItem alloc] initWithObject:obj indentLevel:indentLevel] autorelease];
}

- (id) initWithObject:(id)obj indentLevel:(NSInteger)indentLevel {
    if (self = [super init]) {
        _object = obj;
        _indentLevel = indentLevel;
    }
    return self;
}

- (void) dealloc {
    [super dealloc];
}

- (id) object {
    return _object;
}

- (NSInteger) indentLevel {
    return _indentLevel;
}

@end

#pragma mark -
#pragma mark MUChannelNavigationViewController

@interface MUServerViewController () <UITableViewDelegate, UITableViewDataSource, AboutControllerDelegate> {
    MUServerViewControllerViewMode   _viewMode;
    MKServerModel                    *_serverModel;
    NSMutableArray                   *_modelItems;
    NSMutableDictionary              *_userIndexMap;
    NSMutableDictionary              *_channelIndexMap;
    BOOL                             _pttState;
    UIButton                         *_talkButton;
    UILabel                          *_lbMessage;
    UILabel                          *_caption;
    UITableView                      *_tableView;

    UIImageView                      *_translateLogo;
    UIImageView                      *_iatecLogo;
    
    MUServerTableViewCell            *_activeCell;
    UIButton                         *_btAbout;
}

- (NSInteger) indexForUser:(MKUser *)user;
- (void) reloadUser:(MKUser *)user;
- (void) reloadChannel:(MKChannel *)channel;
- (void) rebuildModelArrayFromChannel:(MKChannel *)channel;
- (void) addChannelTreeToModel:(MKChannel *)channel;
@end

@implementation MUServerViewController

#pragma mark -
#pragma mark Initialization and lifecycle

- (id) initWithServerModel:(MKServerModel *)serverModel {
    if ((self = [super init])) {
        _serverModel = [serverModel retain];
        [_serverModel addDelegate:self];
        _viewMode = MUServerViewControllerViewModeServer;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 400) style:UITableViewStylePlain];
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = false;
    
    _iatecLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IatecLogo"]];
    [_iatecLogo setFrame:CGRectMake( self.view.frame.size.width - 140, -100, _iatecLogo.frame.size.width, _iatecLogo.frame.size.height)];
    [_iatecLogo setAlpha:0.15f];
    [self.view addSubview:_iatecLogo];
    
    _translateLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"translatelogo"]];
    [_translateLogo setCenter:CGPointMake(self.view.frame.size.width / 2.0f, 140)];
    [self.view addSubview:_translateLogo];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    _tableView.bounces = false;
    
    [self.view addSubview:_tableView];
    
    _caption = [[UILabel alloc] init];
    _caption.text = NSLocalizedString(@"ChooseLanguage", nil);
    _caption.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _caption.textColor = [UIColor whiteColor];
    _caption.textAlignment = NSTextAlignmentCenter;
    _caption.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _caption.numberOfLines = 0;
    _caption.hidden = true;
    [self.view addSubview:_caption];
    
    _btAbout = [UIButton buttonWithType:UIButtonTypeInfoLight];
    _btAbout.tintColor = [UIColor whiteColor];
    [_btAbout setFrame:CGRectMake(10, 20, 44, 44)];
    [_btAbout addTarget:self action:@selector(showAbout) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btAbout];
}

- (void) dealloc {
    [_serverModel removeDelegate:self];
    [_serverModel release];
    [_lbMessage release];
    [_tableView release];
    [super dealloc];
}

-(void)showAbout {
    AboutViewController* avc = [[AboutViewController alloc] init];
    [self presentViewController:avc animated:true completion:nil];
    avc.delegate = self;
    
    [avc release];
}

-(void)aboutClosed:(AboutViewController *)controller{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    if (_viewMode == MUServerViewControllerViewModeServer) {
        [self rebuildModelArrayFromChannel:[_serverModel rootChannel]];
    } else if (_viewMode == MUServerViewControllerViewModeChannel) {
        [self switchToChannelMode];
    }
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)[MUColor MainColor].CGColor, (id)[MUColor MainDarkerColor].CGColor];
    
    [self.view.layer insertSublayer:gradient atIndex:0];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger) indexForUser:(MKUser *)user {
    NSNumber *number = [_userIndexMap objectForKey:[NSNumber numberWithInteger:[user session]]];
    if (number) {
        return [number integerValue];
    }
    return NSNotFound;
}

- (NSInteger) indexForChannel:(MKChannel *)channel {
    NSNumber *number = [_channelIndexMap objectForKey:[NSNumber numberWithInteger:[channel channelId]]];
    if (number) {
        return [number integerValue];
    }
    return NSNotFound;
}

- (void) reloadUser:(MKUser *)user {
    NSInteger userIndex = [self indexForUser:user];
    if (userIndex != NSNotFound) {
        [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:userIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void) reloadChannel:(MKChannel *)channel {
    NSInteger idx = [self indexForChannel:channel];
    if (idx != NSNotFound) {
        [UIView animateWithDuration:0.2 animations:^{
            MKUser *connectedUser = [_serverModel connectedUser];
            MUServerTableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
            cell.Activated = connectedUser.channel == channel;
            [cell layoutIfNeeded];
        }];
    }
}

- (void) rebuildModelArrayFromChannel:(MKChannel *)channel {
    [_modelItems release];
    _modelItems = [[NSMutableArray alloc] init];
    
    [_userIndexMap release];
    _userIndexMap = [[NSMutableDictionary alloc] init];

    [_channelIndexMap release];
    _channelIndexMap = [[NSMutableDictionary alloc] init];

    [self addChannelTreeToModel:channel];
}

- (void) switchToServerMode {
    _viewMode = MUServerViewControllerViewModeServer;
    [self rebuildModelArrayFromChannel:[_serverModel rootChannel]];
}

- (void) switchToChannelMode {
    _viewMode = MUServerViewControllerViewModeChannel;
    
    [_modelItems release];
    _modelItems = [[NSMutableArray alloc] init];
    
    [_userIndexMap release];
    _userIndexMap = [[NSMutableDictionary alloc] init];
    
    [_channelIndexMap release];
    _channelIndexMap = [[NSMutableDictionary alloc] init];
    
    MKChannel *channel = [[_serverModel connectedUser] channel];
    for (MKUser *user in [channel users]) {
        [_userIndexMap setObject:[NSNumber numberWithUnsignedInteger:[_modelItems count]] forKey:[NSNumber numberWithUnsignedInteger:[user session]]];
        [_modelItems addObject:[MUChannelNavigationItem navigationItemWithObject:user indentLevel:0]];
    }
}

-(void)addChannelTreeToModel:(MKChannel *)channel {
    for (MKChannel *chan in [channel channels]) {
        [_channelIndexMap setObject:[NSNumber numberWithUnsignedInteger:[_modelItems count]] forKey:[NSNumber numberWithInteger:[chan channelId]]];
        [_modelItems addObject:[MUChannelNavigationItem navigationItemWithObject:chan indentLevel:0]];
    }
    
    CGFloat height = channel.channels.count * 54;
    
    _tableView.frame = CGRectMake(20, self.view.frame.size.height - height - 60, self.view.frame.size.width - 40, height);
    
    _caption.frame = CGRectMake(20, _tableView.frame.origin.y - 50, self.view.frame.size.width-40, 44);
    _caption.hidden = false;
}

#pragma mark - Table view data source



- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_modelItems count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ChannelNavigationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[MUServerTableViewCell alloc] initWithReuseIdentifier:CellIdentifier] autorelease];
        cell.backgroundColor = [UIColor clearColor];
    }

    MUChannelNavigationItem *navItem = [_modelItems objectAtIndex:[indexPath row]];
    id object = [navItem object];

    MKUser *connectedUser = [_serverModel connectedUser];

    cell.textLabel.font = [UIFont systemFontOfSize:18];
    if ([object class] == [MKChannel class]) {
        MKChannel *chan = object;
        cell.imageView.image = [UIImage imageNamed:[chan.channelDescription uppercaseString]];
        cell.textLabel.text = [chan channelName];
        if (chan == [connectedUser channel]) {
            cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
            ((MUServerTableViewCell*)cell).Activated = true;
        } else {
            ((MUServerTableViewCell*)cell).Activated = false;
        }
        cell.accessoryView = nil;
    }

    return cell;
}

-(void)changeServer:(NSInteger)index{
    MUChannelNavigationItem *navItem = [_modelItems objectAtIndex:index];
    id object = [navItem object];
    if ([object class] == [MKChannel class]) {
         MKUser *connectedUser = [_serverModel connectedUser];
        if (object==connectedUser.channel){
            [_serverModel joinChannel:[_serverModel rootChannel]];
        } else {
            [_serverModel joinChannel:object];
        }
    }
}

#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self changeServer:[indexPath row]];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

-(UITableView*)tableView{
    return _tableView;
}

#pragma mark - MKServerModel delegate

- (void) serverModel:(MKServerModel *)model joinedServerAsUser:(MKUser *)user {
    [self rebuildModelArrayFromChannel:[model rootChannel]];
    [self.tableView reloadData];
}

- (void) serverModel:(MKServerModel *)model userJoined:(MKUser *)user {
}

- (void) serverModel:(MKServerModel *)model userDisconnected:(MKUser *)user {
}

- (void) serverModel:(MKServerModel *)model userLeft:(MKUser *)user {
}

- (void) serverModel:(MKServerModel *)model userTalkStateChanged:(MKUser *)user {
    NSInteger userIndex = [self indexForUser:user];
    if (userIndex == NSNotFound) {
        return;
    }

    UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:userIndex inSection:0]];

    MKTalkState talkState = [user talkState];
    NSString *talkImageName = nil;
    if (talkState == MKTalkStatePassive)
        talkImageName = @"talking_off";
    else if (talkState == MKTalkStateTalking)
        talkImageName = @"talking_on";
    else if (talkState == MKTalkStateWhispering)
        talkImageName = @"talking_whisper";
    else if (talkState == MKTalkStateShouting)
        talkImageName = @"talking_alt";

    cell.imageView.image = [UIImage imageNamed:talkImageName];
}

- (void) serverModel:(MKServerModel *)model channelAdded:(MKChannel *)channel {
    if (_viewMode == MUServerViewControllerViewModeServer) {
        [self rebuildModelArrayFromChannel:[model rootChannel]];
        NSInteger idx = [self indexForChannel:channel];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void) serverModel:(MKServerModel *)model channelRemoved:(MKChannel *)channel {
    if (_viewMode == MUServerViewControllerViewModeServer) {
        [self rebuildModelArrayFromChannel:[model rootChannel]];
        [self.tableView reloadData];
    } else if (_viewMode == MUServerViewControllerViewModeChannel) {
        [self switchToChannelMode];
        [self.tableView reloadData];
    }
}

- (void) serverModel:(MKServerModel *)model channelMoved:(MKChannel *)channel {
    if (_viewMode == MUServerViewControllerViewModeServer) {
        [self rebuildModelArrayFromChannel:[model rootChannel]];
        [self.tableView reloadData];
    }
}

- (void) serverModel:(MKServerModel *)model channelRenamed:(MKChannel *)channel {
    if (_viewMode == MUServerViewControllerViewModeServer) {
        [self reloadChannel:channel];
    }
}

- (void) serverModel:(MKServerModel *)model userMoved:(MKUser *)user toChannel:(MKChannel *)chan fromChannel:(MKChannel *)prevChan byUser:(MKUser *)mover {
    if (_viewMode == MUServerViewControllerViewModeServer) {
        [self.tableView beginUpdates];
        if (user == [model connectedUser]) {
            [self reloadChannel:chan];
            [self reloadChannel:prevChan];
        }
    } else if (_viewMode == MUServerViewControllerViewModeChannel) {
        NSInteger userIdx = [self indexForUser:user];
        MKChannel *curChan = [[_serverModel connectedUser] channel];
        
        if (user == [model connectedUser]) {
            [self switchToChannelMode];
            [self.tableView reloadData];
        } else {
            // User is leaving
            [self.tableView beginUpdates];
            if (prevChan == curChan && userIdx != NSNotFound) {
                [self switchToChannelMode];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:userIdx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                // User is joining
            } else if (chan == curChan && userIdx == NSNotFound) {
                [self switchToChannelMode];
                userIdx = [self indexForUser:user];
                if (userIdx != NSNotFound) {
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:userIdx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                }
            }
            [self.tableView endUpdates];
        }
    }
}

- (void) serverModel:(MKServerModel *)model userSelfMuted:(MKUser *)user {
}

- (void) serverModel:(MKServerModel *)model userRemovedSelfMute:(MKUser *)user {
}

- (void) serverModel:(MKServerModel *)model userSelfMutedAndDeafened:(MKUser *)user {
}

- (void) serverModel:(MKServerModel *)model userRemovedSelfMuteAndDeafen:(MKUser *)user {
}

- (void) serverModel:(MKServerModel *)model userSelfMuteDeafenStateChanged:(MKUser *)user {
    [self reloadUser:user];
}

// --

- (void) serverModel:(MKServerModel *)model userMutedAndDeafened:(MKUser *)user byUser:(MKUser *)actor {
    [self reloadUser:user];
}

- (void) serverModel:(MKServerModel *)model userUnmutedAndUndeafened:(MKUser *)user byUser:(MKUser *)actor {
    [self reloadUser:user];
}

- (void) serverModel:(MKServerModel *)model userMuted:(MKUser *)user byUser:(MKUser *)actor {
    [self reloadUser:user];
}

- (void) serverModel:(MKServerModel *)model userUnmuted:(MKUser *)user byUser:(MKUser *)actor {
    [self reloadUser:user];
}

- (void) serverModel:(MKServerModel *)model userDeafened:(MKUser *)user byUser:(MKUser *)actor {
    [self reloadUser:user];
}

- (void) serverModel:(MKServerModel *)model userUndeafened:(MKUser *)user byUser:(MKUser *)actor {
    [self reloadUser:user];
}

- (void) serverModel:(MKServerModel *)model userSuppressed:(MKUser *)user byUser:(MKUser *)actor {
    [self reloadUser:user];
}

- (void) serverModel:(MKServerModel *)model userUnsuppressed:(MKUser *)user byUser:(MKUser *)actor {
    [self reloadUser:user];
}

- (void) serverModel:(MKServerModel *)model userMuteStateChanged:(MKUser *)user {
   [self reloadUser:user];
}

- (void) serverModel:(MKServerModel *)model userAuthenticatedStateChanged:(MKUser *)user {
    [self reloadUser:user];
}

- (void) serverModel:(MKServerModel *)model userPrioritySpeakerChanged:(MKUser *)user {
    [self reloadUser:user];
}

#pragma mark - Mode switch

- (void) toggleMode {
    if (_viewMode == MUServerViewControllerViewModeServer) {
        NSString *msg = NSLocalizedString(@"Switched to channel view mode.", nil);
        [[MUNotificationController sharedController] addNotification:msg];
        [self switchToChannelMode];
    } else if (_viewMode == MUServerViewControllerViewModeChannel) {
        NSString *msg = NSLocalizedString(@"Switched to server view mode.", nil);
        [[MUNotificationController sharedController] addNotification:msg];
        [self switchToServerMode];
    }

    [self.tableView reloadData];
    
    if (_viewMode == MUServerViewControllerViewModeServer) {
        MKChannel *cur = [[_serverModel connectedUser] channel];
        NSInteger idx = [self indexForChannel:cur];
    //    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end

