//
//  PresenceSelectListTableViewCell.h
//  NethCTI
//
//  Created by Marco on 04/02/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PresenceSelectListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *ibImageViewStatus;
@property (weak, nonatomic) IBOutlet UILabel *ibLabelNome;
@property (weak, nonatomic) IBOutlet UIImageView *ibImageViewSelezionato;

@end

NS_ASSUME_NONNULL_END
