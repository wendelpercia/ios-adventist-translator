//
//  CardView.m
//  Adventist Translator
//
//  Created by Dhiogo Brustolin on 6/20/17.
//
//

#import "CardView.h"

@implementation CardView {
    UILabel* lbTitle;
    UIImageView* iv;
    UILabel* lbMessage;
}

-(instancetype)init{
    self = [self initWithFrame:CGRectMake(0, 0, 260, 400)];
    [self initialize];
    return  self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    [self initialize];
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [self initialize];
    return  self;
}

-(void)initialize {
    CGSize size = self.frame.size;
    
    iv = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, size.width - 30, size.height / 2 - 15)];
    [iv setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    
    lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, size.height / 2 + 15, size.width - 30, 20)];
    lbTitle.textAlignment = NSTextAlignmentCenter;
    lbTitle.font = [UIFont boldSystemFontOfSize:17];
    [lbTitle setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    
    lbMessage = [[UILabel alloc] initWithFrame:CGRectMake(15, lbTitle.frame.origin.y + 35, size.width - 30, size.height - 65 - lbTitle.frame.origin.y)];
    lbMessage.textAlignment = NSTextAlignmentCenter;
    lbMessage.numberOfLines = 0;
    lbMessage.font = [UIFont systemFontOfSize:15];
    [lbMessage setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:iv];
    [self addSubview:lbTitle];
    [self addSubview:lbMessage];
}

-(void)setImage:(UIImage *)image{
    iv.image = image;
}

-(void)setTitle:(NSString *)title{
    lbTitle.text = title;
}

-(void)setContent:(NSString *)content{
    lbMessage.text = content;
}

-(UIImage*)image{
    return iv.image;
}

-(NSString*)title{
    return lbTitle.text;
}

-(NSString*)content{
    return lbMessage.text;
}


@end
