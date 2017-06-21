// Copyright 2014 The 'Mumble for iOS' Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

#import "MUServerTableViewCell.h"

@implementation MUServerTableViewCell

- (id) initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = true;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5f];
    }
    return self;
}

-(void)setActivated:(bool)Activated{
    _Activated = Activated;
    [self setNeedsLayout];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.frame = CGRectMake(0, 5, self.frame.size.width, self.frame.size.height - 10);
    
    
    self.imageView.frame = CGRectMake(
        0,
        0,
        _Activated?self.imageView.image.size.width:10,
        self.contentView.frame.size.height
    );

    self.textLabel.frame = CGRectMake(
        self.imageView.frame.size.width + 20,
        0,
        CGRectGetWidth(self.frame) - (CGRectGetMinX(self.imageView.frame) + 60),
        self.contentView.frame.size.height
    );
}

@end
