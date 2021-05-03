//
//  RecentCallTableViewCell.h
//  NethCTI
//
//  Created by Luca Giorgetti on 29/04/2021.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecentCallTableViewCell : UITableViewCell
//@property (weak, nonatomic) IBOutlet UILabel *contactInitialLabel;

- (id)initWithIdentifier:(NSString *)identifier;
- (void)setRecentCall:(NSString *)pippo;
- (void)setSize:(CGRect *)frame;
@end

NS_ASSUME_NONNULL_END
