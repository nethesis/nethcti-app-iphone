//
//  PresenceViewController.m
//  NethCTI
//
//  Created by Democom S.r.l. on 18/01/22.
//


#import <UIKit/UIKit.h>
#import "UICompositeView.h"
//#import "UIInterfaceStyleButton.h"



@interface PresenceViewController : UIViewController <UICompositeViewDelegate>

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

@property(strong, nonatomic) NSMutableArray *arrayUsers;
@property(strong, nonatomic) PortableNethUser *userMe;


- (void)loadData;


- (IBAction)onBackPressed:(id)sender;
- (IBAction)ibaSelezionePresence:(id)sender;
- (IBAction)ibaVisualizzaGruppi:(id)sender;
- (IBAction)ibaVisualizzaPreferiti:(id)sender;

@end
