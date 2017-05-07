    //
//  MUOpenTranslationControler.m
//  Adventist_Translator
//
//  Created by Wendel O Percia on 07/05/17.
//
//

#import "MUTranslatorController.h"

#import "MUListChannelController.h"
#import "MUTranslatorChannel.h"
#import "MUChannelCell.h"

#import "MUOperatingSystem.h"

@interface MUTranslatorController () <UIAlertViewDelegate> {
    NSMutableArray     *_channelList;
}
@end

@implementation MUTranslatorController

#pragma mark - Navigation
#pragma mark Initialization

- (id) init {
    if ((self = [super init])) {
        // ...
    }
    
    return self;
}

- (void) dealloc {
    [_channelList release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewWillAppear:(BOOL)animated {
    
    /* Wendel - First Method Called */
    [super viewWillAppear:animated];
    
    [[self navigationItem] setTitle:NSLocalizedString(@"Favourite Servers", nil)];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (MUGetOperatingSystemVersion() >= MUMBLE_OS_IOS_7) {
        navBar.tintColor = [UIColor whiteColor];
        navBar.translucent = NO;
        navBar.backgroundColor = [UIColor blackColor];
    }
    navBar.barStyle = UIBarStyleBlackOpaque;
    
    if (MUGetOperatingSystemVersion() >= MUMBLE_OS_IOS_7) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    [self reloadChannels];
    
}

- (void) reloadChannels {
    [_channelList release];
    _channelList = [[MUListChannelController fetchAllChannels] retain];
    [_channelList sortUsingSelector:@selector(compare:)];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_channelList count];
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MUTranslatorChannel *channel = [_channelList objectAtIndex:[indexPath row]];
    MUChannelCell *cell = (MUChannelCell *)[tableView dequeueReusableCellWithIdentifier:[MUChannelCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[[MUChannelCell alloc] init] autorelease];
    }
    [cell populateFromFavouriteServer:channel];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return (UITableViewCell *) cell;
}

@end
