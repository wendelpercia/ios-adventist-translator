//
//  AboutViewController.h
//  Adventist Translator
//
//  Created by Dhiogo Brustolin on 7/3/17.
//
//

#import <UIKit/UIKit.h>

@class AboutViewController;

@protocol AboutControllerDelegate <NSObject>

-(void)aboutClosed:(AboutViewController*)controller;

@end


@interface AboutViewController : UIViewController
- (IBAction)CloseClicked:(id)sender;

@property (nonatomic,strong) id<AboutControllerDelegate> delegate;

@end
