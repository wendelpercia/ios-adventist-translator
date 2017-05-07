//
//  MUChannelCell.h
//  Adventist_Translator
//
//  Created by Wendel O Percia on 07/05/17.
//
//

#import <MumbleKit/MKServerPinger.h>

#import <Foundation/Foundation.h>

@class MUTranslatorChannel;

@interface MUChannelCell : UITableViewCell <MKServerPingerDelegate>
+ (NSString *) reuseIdentifier;
- (void) populateFromDisplayName:(NSString *)displayName;
- (void) populateFromFavouriteServer:(MUTranslatorChannel *)channel;

@end
