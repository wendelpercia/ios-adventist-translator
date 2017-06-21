//
//  TutorialController.h
//  Adventist Translator
//
//  Created by Dhiogo Brustolin on 6/20/17.
//
//

#import <UIKit/UIKit.h>

@class TutorialController;

@protocol TutorialControlerDelegate <NSObject>

@optional

-(void)TutorialControllerEnded:(TutorialController*)controller;

@end

@interface TutorialController : UIViewController
@property (retain, nonatomic) IBOutlet UILabel *lbTitle;
@property (retain, nonatomic) IBOutlet UIView *vwCards;
@property (retain, nonatomic) IBOutlet UIPageControl *psPosition;
@property (retain, nonatomic) IBOutlet UIButton *btAction;
@property (retain, nonatomic) id<TutorialControlerDelegate> delegate;

- (IBAction)Next:(id)sender;

@end
