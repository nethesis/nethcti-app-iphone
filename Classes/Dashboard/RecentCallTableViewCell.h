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
- (id)initWithIdentifier:(NSString *)identifier;
- (void)setRecentCall:(NSString *)pippo;
- (void)setSize:(CGRect *)frame;
- (IBAction)callTouchUpInside:(id)sender;
@end

NS_ASSUME_NONNULL_END
