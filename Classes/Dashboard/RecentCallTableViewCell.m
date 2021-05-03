//
//  RecentCallTableViewCell.m
//  NethCTI
//
//  Created by Luca Giorgetti on 29/04/2021.
//

#import "RecentCallTableViewCell.h"

@implementation RecentCallTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onCallPressed:(id)sender {
}

- (id)initWithIdentifier:(NSString *)identifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if (self != nil) {
        NSArray *arrayOfViews =
            [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
        if ([arrayOfViews count] >= 1) {
            // resize cell to match .nib size. It is needed when resized the cell to
            // correctly adapt its height too
            UIView *sub = ((UIView *)[arrayOfViews objectAtIndex:0]);
            [self setFrame:CGRectMake(0, 0, sub.frame.size.width, sub.frame.size.height)];
            [self addSubview:sub];
        }
    }
    return self;
}

- (void)setRecentCall:(NSString *)pippo {
    self.layer.masksToBounds = false;
    self.layer.shadowColor = (__bridge CGColorRef _Nullable)(UIColor.blackColor);
    self.layer.shadowOffset = CGSizeMake(1.0, 3.0);
    self.layer.shadowOpacity = 0.5;
    
    CGRect shadowFrame = self.layer.bounds;
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
    self.layer.shadowPath = shadowPath;
    
    [_pug2hbe0h8gq430h setText:pippo];
    /*
    [cell.contactInitialLabel setText:@"U"];
    [cell.nameInitialLabel setText:@"Utente prova"];
    //[cell.numberLabel setText:@"sip: 213@123.123.12.12"];
    [ContactDisplay setDisplayNameLabel:_nameLabel forAddress:addr];

    [_avatarImage setImage:[FastAddressBook imageForAddress:addr] bordered:NO withRoundedRadius:YES];

    _durationLabel.text = [LinphoneUtils durationToString:linphone_call_get_duration(call)];
    */
}

- (IBAction)callTouchUpInside:(id)sender {
    LOGE(@"Call");
}

-(void)setSize:(CGRect *)frame {
    [self setFrame:*frame];
}

@end
