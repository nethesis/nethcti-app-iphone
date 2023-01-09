//
//  RecentCallTableViewCell.h
//  NethCTI
//
//  Created by Luca Giorgetti on 29/04/2021.
//

#import <UIKit/UIKit.h>
#import "UIIconButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface RecentCallTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameInitialsLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIIconButton *callButton;
@property (weak, nonatomic) IBOutlet UIImageView *callIcon;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;

- (IBAction)callTouchUpInside:(id)event;

- (id)initWithIdentifier:(NSString *)identifier;
- (void)setRecentCall:(LinphoneCallLog *)recentCall;

@property (nonatomic, assign) LinphoneCallLog *callLog;

@end

NS_ASSUME_NONNULL_END
