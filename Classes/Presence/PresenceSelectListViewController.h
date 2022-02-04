//
//  PresenceSelectListViewController.h
//  NethCTI
//
//  Created by Marco on 02/02/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PresenceSelectListViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIView *ibViewContenitore;
@property (weak, nonatomic) IBOutlet UIButton *ibButtonChiudi;
@property (weak, nonatomic) IBOutlet UILabel *ibLabelTitolo;
@property (weak, nonatomic) IBOutlet UITableView *ibTableViewSelezionePresence;
@property (weak, nonatomic) IBOutlet UILabel *ibLabelNessunDato;
@property (weak, nonatomic) IBOutlet UITableViewCell *ibPresenceSelectListTableViewCell;


- (IBAction)ibaChiudi:(id)sender;

@end

NS_ASSUME_NONNULL_END
