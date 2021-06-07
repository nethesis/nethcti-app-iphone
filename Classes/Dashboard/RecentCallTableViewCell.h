//
//  RecentCallTableViewCell.h
//  NethCTI
//
//  Created by Luca Giorgetti on 29/04/2021.
//

NS_ASSUME_NONNULL_BEGIN

@interface RecentCallTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameInitialsLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *callButton;

- (IBAction)callTouchUpInside:(id)event;

- (id)initWithIdentifier:(NSString *)identifier;
- (void)setRecentCall:(LinphoneCallLog *)recentCall;

@property (nonatomic, assign) LinphoneCallLog *callLog;

@end

NS_ASSUME_NONNULL_END
