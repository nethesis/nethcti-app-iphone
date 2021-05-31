//
//  RecentCallTableViewCell.h
//  NethCTI
//
//  Created by Luca Giorgetti on 29/04/2021.
//

NS_ASSUME_NONNULL_BEGIN

@interface RecentCallTableViewCell : UITableViewCell
//@property (weak, nonatomic) IBOutlet UILabel *contactInitialLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameInitialsLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

- (IBAction)callTouchUpInside:(id)sender;

- (id)initWithIdentifier:(NSString *)identifier;
- (void)setRecentCall:(LinphoneCallLog *)recentCall;

@property (nonatomic, assign) LinphoneCallLog *callLog;

@end

NS_ASSUME_NONNULL_END
