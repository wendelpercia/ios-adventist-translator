//
//  MUListChannelController.h
//  Adventist_Translator
//
//  Created by Wendel O Percia on 07/05/17.
//
//

#import <Foundation/Foundation.h>

@interface MUListChannelController : NSObject

+ (NSMutableArray *) fetchAllChannels;
- (NSMutableArray *) connectTranslatorServer;
- (NSString *) getIPAddress;

@end
