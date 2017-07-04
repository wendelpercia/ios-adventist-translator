//
//  AboutViewController.m
//  Adventist Translator
//
//  Created by Dhiogo Brustolin on 7/3/17.
//
//

#import "AboutViewController.h"
#import "MUColor.h"

@interface AboutViewController () {
    CAGradientLayer *gradient;
}

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    gradient = [CAGradientLayer layer];
    
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)[MUColor MainColor].CGColor, (id)[MUColor MainDarkerColor].CGColor];
    
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)CloseClicked:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(aboutClosed:) ]){
        [self.delegate aboutClosed:self];
    }
    
}

-(void)viewDidLayoutSubviews{
    gradient.frame = self.view.bounds;
}

@end
