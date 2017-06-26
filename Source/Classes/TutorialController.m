//
//  TutorialController.m
//  Adventist Translator
//
//  Created by Dhiogo Brustolin on 6/20/17.
//
//

#import "TutorialController.h"
#import "MUColor.h"
#import "CardView.h"

@interface TutorialController ()

@end

@implementation TutorialController {
    CardView* cvSecurity;
    CardView* cvPhones;
    CardView* cvNetwork;
    NSArray<CardView*>* cards;
    
    CAGradientLayer *gradient;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)[MUColor MainColor].CGColor, (id)[MUColor MainDarkerColor].CGColor];
    
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    
    cvSecurity = [[CardView alloc] init];
    cvSecurity.title = NSLocalizedString(@"PROTECTION", nil);
    cvSecurity.content = NSLocalizedString(@"SecurityCardDescription", nil);
    cvSecurity.image = [UIImage imageNamed:@"Protection"];
    
    cvPhones = [[CardView alloc] init];
    cvPhones.title = NSLocalizedString(@"USE YOUR PHONE", nil);
    cvPhones.content = NSLocalizedString(@"PhoneCardDescription", nil);
    cvPhones.image = [UIImage imageNamed:@"Phones"];
    
    cvNetwork = [[CardView alloc] init];
    cvNetwork.title = NSLocalizedString(@"INTERNET", nil);
    cvNetwork.content = NSLocalizedString(@"NetworkCardDescription", nil);
    cvNetwork.image = [UIImage imageNamed:@"Internet"];
    
    cvNetwork.autoresizingMask  =
    cvPhones.autoresizingMask   =
    cvSecurity.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    cards = [[NSArray alloc] initWithObjects:cvSecurity,cvPhones,cvNetwork, nil];
    
    CGRect frame = CGRectInset(_vwCards.bounds, 30,0);
    for (CardView* cv in cards) {
        cv.frame = frame;
        cv.layer.cornerRadius = 10;
        cv.layer.shadowColor = [UIColor blackColor].CGColor;
        cv.layer.shadowRadius = 2;
        cv.layer.shadowOpacity = 0.5f;
        cv.layer.shadowOffset = CGSizeMake(0, 2);
        
        [_vwCards addSubview:cv];
        frame.origin.x += _vwCards.frame.size.width;
    }
    [self toStep:0];
}

- (IBAction)Next:(id)sender {
    if (_psPosition.currentPage < 2){
        [UIView animateWithDuration:0.3 animations:^{
            [self toStep:_psPosition.currentPage + 1];
        }];
    } else {
        if ([self.delegate respondsToSelector:@selector(TutorialControllerEnded:)]) {
            [self.delegate TutorialControllerEnded:self];
        }
    }
}

-(void)toStep:(long)step{
    switch (step) {
        case 0:{
             _lbTitle.text = NSLocalizedString(@"SecurityDescription", nil);
            [_btAction setTitle:NSLocalizedString(@"NEXT", nil) forState:UIControlStateNormal];
        }
            break;
        case 1:{
            _lbTitle.text = NSLocalizedString(@"PhoneDescription", nil);
            [_btAction setTitle:NSLocalizedString(@"NEXT", nil) forState:UIControlStateNormal];
        }
            break;
        case 2: {
            _lbTitle.text = NSLocalizedString(@"NetworkDescription", nil);
            [_btAction setTitle:NSLocalizedString(@"BEGIN", nil) forState:UIControlStateNormal];
        }
            break;
    }
    
    CGRect frame = CGRectInset(_vwCards.bounds, 30,0);
    frame.origin.x -= step * _vwCards.frame.size.width;
    
    for (CardView* cv in cards) {
        cv.frame = frame;
        frame.origin.x += _vwCards.frame.size.width;
    }
    
    
    _psPosition.currentPage = step;
}

-(void)viewDidLayoutSubviews{
    gradient.frame = self.view.bounds;
}

- (void)dealloc {
    [_lbTitle release];
    [_vwCards release];
    [_psPosition release];
    [_btAction release];
    [cvPhones release];
    [cvSecurity release];
    [cvNetwork release];
    [_delegate release];
    
    [super dealloc];
}
@end
