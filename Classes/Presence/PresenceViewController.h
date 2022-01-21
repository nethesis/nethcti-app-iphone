//
//  PresenceTableViewController.m
//  NethCTI
//
//  Created by Democom S.r.l. on 18/01/22.
//


#import <UIKit/UIKit.h>
#import "UICompositeView.h"
#import "PresenceTableViewController.h"
//#import "UIInterfaceStyleButton.h"



@interface PresenceViewController : UIViewController <UICompositeViewDelegate>

@property (strong, nonatomic) IBOutlet PresenceTableViewController *presenceTableViewController;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *ibButtonGruppi;
@property (weak, nonatomic) IBOutlet UILabel *ibLabelGruppi;
@property (weak, nonatomic) IBOutlet UIButton *ibButtonPreferiti;
@property (weak, nonatomic) IBOutlet UILabel *ibLabelPreferiti;
@property (weak, nonatomic) IBOutlet UIButton *ibButtonSelezionePresence;

- (IBAction)onBackPressed:(id)sender;
- (IBAction)ibaSelezionePresence:(id)sender;
- (IBAction)ibaVisualizzaGruppi:(id)sender;
- (IBAction)ibaVisualizzaPreferiti:(id)sender;

@end
