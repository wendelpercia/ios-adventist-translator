// Copyright 2009-2010 The 'Mumble for iOS' Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

#import "MUVersionChecker.h"

@interface MUApplicationDelegate : NSObject <UIApplicationDelegate>
- (void) reloadPreferences;
+ (NSString*)languageSelectedStringForKey:(NSString*) key;
@end
