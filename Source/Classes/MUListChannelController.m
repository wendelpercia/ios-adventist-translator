//
//  MUListChannelController.m
//  Adventist_Translator
//
//  Created by Wendel O Percia on 07/05/17.
//
//

#import "MUListChannelController.h"

#import "MUTranslatorChannel.h"


@implementation MUListChannelController

+ (NSMutableArray *) fetchAllChannels {
    
    NSMutableArray *channels = [[NSMutableArray alloc] init];
    
    MUTranslatorChannel *res = [[MUTranslatorChannel alloc] init];
    
    [res setPrimaryKey: -1];
    [res setDisplayName: NSLocalizedString(@"en", nil)];
    [channels addObject:res];
    [res release];

    res = [[MUTranslatorChannel alloc] init];
    [res setPrimaryKey: 0];
    [res setDisplayName: NSLocalizedString(@"es", nil)];
    [channels addObject:res];

    res = [[MUTranslatorChannel alloc] init];
    [res setPrimaryKey: 1];
    [res setDisplayName: NSLocalizedString(@"pt-BR", nil)];
    [channels addObject:res];

    res = [[MUTranslatorChannel alloc] init];
    [res setPrimaryKey: 2];
    [res setDisplayName: NSLocalizedString(@"fr", nil)];
    [channels addObject:res];
    
    
    return [channels autorelease];
}

@end
