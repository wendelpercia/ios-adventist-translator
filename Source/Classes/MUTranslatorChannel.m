//
//  MUTranslatorChannel.m
//  Adventist_Translator
//
//  Created by Wendel O Percia on 07/05/17.
//
//

#import "MUTranslatorChannel.h"

@implementation MUTranslatorChannel

@synthesize primaryKey         = _pkey;
@synthesize displayName        = _displayName;

- (id) initWithDisplayName:(NSString *)displayName {
    self = [super init];
    if (self == nil)
        return nil;
    
    _pkey = -1;
    _displayName = [displayName copy];
    
    return self;
}


- (id) init {
    return [self initWithDisplayName:nil ];

}

- (void) dealloc {
    [_displayName release];
    [super dealloc];
}

- (id) copyWithZone:(NSZone *)zone {
    MUTranslatorChannel *transChannel = [[MUTranslatorChannel alloc] initWithDisplayName:_displayName];
    if ([self hasPrimaryKey])
        [transChannel setPrimaryKey:[self primaryKey]];
    return transChannel;
}

- (BOOL) hasPrimaryKey {
    return _pkey != -1;
}

- (NSComparisonResult) compare:(MUTranslatorChannel *)favServ {
    return [_displayName caseInsensitiveCompare:[favServ displayName]];
}

@end
