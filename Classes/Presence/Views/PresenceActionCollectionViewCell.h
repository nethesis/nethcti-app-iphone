//
//  PresenceActionCollectionViewCell.h
//  NethCTI
//
//  Created by Democom S.r.l. on 15/02/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PresenceActionCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *ibButtonAzione;
@property (weak, nonatomic) IBOutlet UILabel *ibLabelNomeAzione;

@end

NS_ASSUME_NONNULL_END
