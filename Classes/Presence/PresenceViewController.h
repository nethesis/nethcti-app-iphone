//
//  PresenceViewController.m
//  NethCTI
//
//  Created by Democom S.r.l. on 18/01/22.
//


#import <UIKit/UIKit.h>
#import "UICompositeView.h"
//#import "UIInterfaceStyleButton.h"
#import "PresenceSelectListViewController.h"
#import "PresenceSelectListGroupViewController.h"
#import "PresenceActionViewController.h"



@interface PresenceViewController : UIViewController <UICompositeViewDelegate, PresenceSelectListDelegate, PresenceSelectListGroupDelegate, PresenceActionDelegate>

@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *ibButtonSelezionaGruppi;
@property (weak, nonatomic) IBOutlet UILabel *ibLabelGruppi;
@property (weak, nonatomic) IBOutlet UIButton *ibButtonSelezionaPreferiti;
@property (weak, nonatomic) IBOutlet UILabel *ibLabelPreferiti;
@property (weak, nonatomic) IBOutlet UIButton *ibButtonSelezionePresence;
@property (weak, nonatomic) IBOutlet UITableViewCell *ibPresenceTableViewCell;
@property (weak, nonatomic) IBOutlet UITableView *ibTableViewPresence;
@property (weak, nonatomic) IBOutlet UILabel *ibLabelNessunDato;

@property(strong, nonatomic) PortableNethUser *portableNethUserMe;
@property(strong, nonatomic) NSString *id_groupSelezionato;


//- (void)loadData;


- (IBAction)onBackPressed:(id)sender;
- (IBAction)ibaSelezionePresence:(id)sender;
- (IBAction)ibaVisualizzaGruppi:(id)sender;
- (IBAction)ibaVisualizzaPreferiti:(id)sender;
- (IBAction)ibaVisualizzaAzioni:(UIButton *)sender;

@end
