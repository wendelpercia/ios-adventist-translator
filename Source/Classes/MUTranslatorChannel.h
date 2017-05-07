//
//  MUTranslatorChannel.h
//  Adventist_Translator
//
//  Created by Wendel O Percia on 07/05/17.
//
//

#import <Foundation/Foundation.h>

@interface MUTranslatorChannel : NSObject <NSCopying>

- (id) initWithDisplayName:(NSString *)displayName;

- (id) init;
- (void) dealloc;

@property (assign)  NSInteger   primaryKey;
@property (copy)    NSString    *displayName;


- (BOOL) hasPrimaryKey;
- (NSComparisonResult) compare:(MUTranslatorChannel *)favServ;

@end
