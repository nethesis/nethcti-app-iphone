//
//  RecentCallTableViewCell.h
//  NethCTI
//
//  Created by Luca Giorgetti on 29/04/2021.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecentCallTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameInitialLabel;
@property (weak, nonatomic) IBOutlet UIImageView *callStatusImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

- (IBAction)onCallPressed:(id)sender;
@end

NS_ASSUME_NONNULL_END
