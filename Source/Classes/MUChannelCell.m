//
//  MUChannelCell.m
//  Adventist_Translator
//
//  Created by Wendel O Percia on 07/05/17.
//
//


#import "MUChannelCell.h"

#import "MUColor.h"
#import "MUTranslatorChannel.h"

@interface MUChannelCell () {
    NSString        *_displayname;
}
@end

@implementation MUChannelCell

+ (NSString *) reuseIdentifier {
    return @"ServerCell";
}

- (id) init {
    return [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[MUChannelCell reuseIdentifier]];
}

- (void) dealloc {
    [_displayname release];
    [super dealloc];
}

- (void) populateFromDisplayName:(NSString *)displayName {
    [_displayname release];
    _displayname = [displayName copy];
    
    self.textLabel.text = _displayname;
}

- (void) populateFromFavouriteServer:(MUTranslatorChannel *)favServ {
    [_displayname release];
    _displayname = [[favServ displayName] copy];
    
    self.textLabel.text = _displayname;
    //self.imageView.image = [self drawPingImageWithPingValue:999 andUserCount:0 isFull:NO];
    
    //self.imageView.image = [UIImage imageNamed:@"BR"];
}


- (UIImage *) drawPingImageWithPingValue:(NSUInteger)pingMs andUserCount:(NSUInteger)userCount isFull:(BOOL)isFull {
    UIImage *img = nil;
    
    UIColor *pingColor = [MUColor badPingColor];
    if (pingMs <= 125)
        pingColor = [MUColor goodPingColor];
    else if (pingMs > 125 && pingMs <= 250)
        pingColor = [MUColor mediumPingColor];
    else if (pingMs > 250)
        pingColor = [MUColor badPingColor];
    NSString *pingStr = [NSString stringWithFormat:@"%lu\nms", (unsigned long)pingMs];
    if (pingMs >= 999)
        pingStr = @"∞\nms";
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(66.0f, 32.0f), NO, [[UIScreen mainScreen] scale]);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, pingColor.CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, 32.0, 32.0));
    
    CGContextSetTextDrawingMode(ctx, kCGTextFill);
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    [pingStr drawInRect:CGRectMake(0.0, 0.0, 32.0, 32.0)
               withFont:[UIFont boldSystemFontOfSize:12]
          lineBreakMode:UILineBreakModeTailTruncation
              alignment:UITextAlignmentCenter];
    
    if (!isFull) {
        // Non-full servers get the mild iOS blue color
        CGContextSetFillColorWithColor(ctx, [MUColor userCountColor].CGColor);
    } else {
        // Mark full servers with the same red as we use for
        // 'bad' pings...
        CGContextSetFillColorWithColor(ctx, [MUColor badPingColor].CGColor);
    }
    CGContextFillRect(ctx, CGRectMake(34.0, 0, 32.0, 32.0));
    
    CGContextSetTextDrawingMode(ctx, kCGTextFill);
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    NSString *usersStr = [NSString stringWithFormat:NSLocalizedString(@"%lu\nppl", @"user count"), (unsigned long)userCount];
    [usersStr drawInRect:CGRectMake(34.0, 0.0, 32.0, 32.0)
                withFont:[UIFont boldSystemFontOfSize:12]
           lineBreakMode:UILineBreakModeTailTruncation
               alignment:UITextAlignmentCenter];
    
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

- (void) serverPingerResult:(MKServerPingerResult *)result {
    NSUInteger pingValue = (NSUInteger)(result->ping * 1000.0f);
    NSUInteger userCount = (NSUInteger)(result->cur_users);
    BOOL isFull = result->cur_users == result->max_users;
    self.imageView.image = [self drawPingImageWithPingValue:pingValue andUserCount:userCount isFull:isFull];
}

@end
