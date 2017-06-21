//
//  TutorialController.h
//  Adventist Translator
//
//  Created by Dhiogo Brustolin on 6/20/17.
//
//

#import <UIKit/UIKit.h>

@interface TutorialController : UIViewController
@property (retain, nonatomic) IBOutlet UILabel *lbTitle;
@property (retain, nonatomic) IBOutlet UIView *vwCards;
@property (retain, nonatomic) IBOutlet UIPageControl *psPosition;
@property (retain, nonatomic) IBOutlet UIButton *btAction;

- (IBAction)Next:(id)sender;

@end
