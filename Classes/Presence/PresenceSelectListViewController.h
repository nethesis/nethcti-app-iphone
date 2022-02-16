//
//  PresenceSelectListViewController.h
//  NethCTI
//
//  Created by Democom S.r.l. on 02/02/22.
//

#import <UIKit/UIKit.h>


// delegate custom
@protocol PresenceSelectListDelegate <NSObject>

- (void)reloadPresence;

@end


NS_ASSUME_NONNULL_BEGIN

@interface PresenceSelectListViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIView *ibViewContenitore;
@property (weak, nonatomic) IBOutlet UIButton *ibButtonChiudi;
@property (weak, nonatomic) IBOutlet UILabel *ibLabelTitolo;
@property (weak, nonatomic) IBOutlet UITableView *ibTableViewSelezionePresence;
@property (weak, nonatomic) IBOutlet UILabel *ibLabelNessunDato;
@property (weak, nonatomic) IBOutlet UITableViewCell *ibPresenceSelectListTableViewCell;


- (IBAction)ibaChiudi:(id)sender;


@property (strong, nonatomic) NSString *presenceSelezionata;
@property (weak, nonatomic) id <PresenceSelectListDelegate> presenceSelectListDelegate;


@end

NS_ASSUME_NONNULL_END
