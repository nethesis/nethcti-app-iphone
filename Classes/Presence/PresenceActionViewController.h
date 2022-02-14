//
//  PresenceActionViewController.h
//  NethCTI
//
//  Created by Marco on 14/02/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PresenceActionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *ibButtonChiudi;
@property (weak, nonatomic) IBOutlet UILabel *ibLabelTitolo;
@property (weak, nonatomic) IBOutlet UICollectionView *ibCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *ibImageViewSfondoStatus;
@property (weak, nonatomic) IBOutlet UILabel *ibLabelIniziali;
@property (weak, nonatomic) IBOutlet UIImageView *ibImageViewStatus;
@property (weak, nonatomic) IBOutlet UILabel *ibLabelNome;
@property (weak, nonatomic) IBOutlet UILabel *ibLabelMainExtension;
@property (weak, nonatomic) IBOutlet UIView *ibViewPresence;
@property (weak, nonatomic) IBOutlet UILabel *ibLabelStatusPresence;
@property (weak, nonatomic) IBOutlet UIButton *ibButtonPreferito;


@property(strong, nonatomic) PortablePresenceUser *portablePresenceUser;
@property(strong, nonatomic) PortableNethUser *portableNethUserMe;


- (IBAction)ibaChiudi:(id)sender;
- (IBAction)ibaSetPreferito:(id)sender;


@end

NS_ASSUME_NONNULL_END
