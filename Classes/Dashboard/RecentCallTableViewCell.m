//
//  RecentCallTableViewCell.m
//  NethCTI
//
//  Created by Luca Giorgetti on 29/04/2021.
//

#import "RecentCallTableViewCell.h"
#import "PhoneMainView.h"

@implementation RecentCallTableViewCell
@synthesize callLog;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
        callLog = nil;
        
        UIGestureRecognizer *tapParent = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHistoryDetails:)];
        [_stackView addGestureRecognizer:tapParent];
        // [tapParent release];
    }
    return self;
}

- (void)setRecentCall:(LinphoneCallLog *)recentCall {
    if(recentCall == nil) {
        LOGW(@"Cannot update history cell: null calllog");
        return;
    }
    
    self.layer.masksToBounds = false;
    self.layer.shadowColor = (__bridge CGColorRef _Nullable)(UIColor.blackColor);
    self.layer.shadowOffset = CGSizeMake(1.0, 3.0);
    self.layer.shadowOpacity = 0.5;
    
    CGRect shadowFrame = self.layer.bounds;
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
    self.layer.shadowPath = shadowPath;
    
    self.callLog = recentCall;
    
    [self setCallIcon:_callIcon byLog:recentCall];
    
    const LinphoneAddress *addr = linphone_call_log_get_from_address(recentCall);
    
    [_addressLabel setTextColor:[UIColor getColorByName:@"MainColor"]];
    [ContactDisplay setDisplayNameLabel:_nameLabel forAddress:addr withAddressLabel:_addressLabel];
    [ContactDisplay setDisplayInitialsLabel:_nameInitialsLabel forAddress:addr];
}

/// Retreive the right icon from the call log status.
/// This method is shared with old history table view controller.
/// @param view UIImageView to change icon.
/// @param log Linphone Call Log to show.
- (void)setCallIcon:(UIImageView *)view byLog:(LinphoneCallLog *)log {
    const BOOL outgoing = linphone_call_log_get_dir(log) == LinphoneCallOutgoing;
    const BOOL missed = linphone_call_log_get_status(log) == LinphoneCallMissed;
    
    if (outgoing) {
        [view setImage:[UIImage imageNamed:@"nethcti_call_status_outgoing.png"]];
    } else if (missed) {
        [view setImage:[UIImage imageNamed:@"nethcti_call_status_missed.png"]];
    } else {
        [view setImage:[UIImage imageNamed:@"nethcti_call_status_incoming.png"]];
    }
}

- (IBAction)callTouchUpInside:(id)event {
    if(callLog == nil) {
        return;
    }
    
    const LinphoneAddress *addr = linphone_call_log_get_remote_address(callLog);
    [LinphoneManager.instance call:addr];
}

- (IBAction)showHistoryDetails:(id)event {
    if (callLog == nil) {
        return;
    }

    HistoryDetailsView *view = VIEW(HistoryDetailsView);
    if (linphone_call_log_get_call_id(callLog) != NULL) {
        // Go to History details view
        const char *log = linphone_call_log_get_call_id(callLog);
        [view setCallLogId:[NSString stringWithUTF8String:log]];
    }
    
    [PhoneMainView.instance changeCurrentView:view.compositeViewDescription];
}

-(void)setSize:(CGRect *)frame {
    [self setFrame:*frame];
}

@end
