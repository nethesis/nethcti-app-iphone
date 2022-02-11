//
//  PresenceSelectListGroupViewController.h
//  NethCTI
//
//  Created by Marco on 02/02/22.
//

#import <UIKit/UIKit.h>
#import "PresenceSelectListGroupTableViewCell.h"


// delegate custom
@protocol PresenceSelectListGroupDelegate <NSObject>

- (void)reloadPresenceWithGroup:(NSString * _Nullable) id_group;

@end



NS_ASSUME_NONNULL_BEGIN

@interface PresenceSelectListGroupViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *ibLabelTitolo;
@property (weak, nonatomic) IBOutlet UIButton *ibButtonChiudi;
@property (weak, nonatomic) IBOutlet UITableView *ibTableViewGruppi;
@property (weak, nonatomic) IBOutlet UILabel *ibLabelNessunDato;
@property (weak, nonatomic) IBOutlet UITableViewCell *ibPresenceSelectListGroupTableViewCell;


- (IBAction)ibaChiudi:(id)sender;


@property (strong, nonatomic) NSString *id_groupSelezionato;
@property(strong, nonatomic) NSMutableArray *arrayGroups;
@property (weak, nonatomic) id <PresenceSelectListGroupDelegate> presenceSelectListGroupDelegate;


@end

NS_ASSUME_NONNULL_END
