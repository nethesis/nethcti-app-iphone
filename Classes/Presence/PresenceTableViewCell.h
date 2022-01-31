//
//  PresenceTableViewCell.h
//  NethCTI
//
//  Created by Marco on 19/01/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PresenceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *ibImageViewSfontoStatus;
@property (weak, nonatomic) IBOutlet UILabel *ibLabelIniziali;
@property (weak, nonatomic) IBOutlet UIImageView *ibImageViewStatus;
@property (weak, nonatomic) IBOutlet UILabel *ibLabelName;
@property (weak, nonatomic) IBOutlet UIView *ibViewSfondoLabelStatus;
@property (weak, nonatomic) IBOutlet UILabel *ibLabelStatus;
@property (weak, nonatomic) IBOutlet UIButton *ibButtonVisualizzaAzioni;


@end

NS_ASSUME_NONNULL_END
