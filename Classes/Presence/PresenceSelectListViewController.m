//
//  PresenceSelectListViewController.m
//  NethCTI
//
//  Created by Democom S.r.l. on 02/02/22.
//

#import "PresenceSelectListViewController.h"
#import "MBProgressHUD.h"
#import "PresenceSelectListTableViewCell.h"





@interface PresenceSelectListViewController ()

@property (strong, nonatomic) MBProgressHUD *HUD;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *arrayPresence;
@property (strong, nonatomic) NSString *numeroInoltro;

@end



@implementation PresenceSelectListViewController

@synthesize presenceSelezionata;
@synthesize portableNethUserMe;



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"PresenceSelectListViewController - viewDidLoad");

    /*
    LinphoneProxyConfig *linphoneProxyConfig = bctbx_list_nth_data(linphone_core_get_proxy_config_list(LC), YES);

    BOOL proxy_config_register_is_enabled = linphone_proxy_config_register_enabled(linphoneProxyConfig);
    NSLog(@"proxy_config_register_is_enabled: %@", proxy_config_register_is_enabled ? @"YES" : @"NO");
    
    if (proxy_config_register_is_enabled == NO) {
        
        presenceSelezionata = kKeyDisconnesso;
    }
    */
    
    
    NSLog(@"portableNethUserMe: %@", portableNethUserMe);

    [self getProxyState];
    
    
    
    
    // --- MBProgressHUD ---
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:self.HUD];
    // ------------------------
    
    
    // --- UIRefreshControl ---
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    //self.refreshControl.tintColor = colorDivider;
    
    [self.refreshControl addTarget:self action:@selector(downloadPresenceList) forControlEvents:UIControlEventValueChanged];
    
    [self.ibTableViewSelezionePresence addSubview:self.refreshControl];
    // ------------------------
    
    
    
    [self.HUD showAnimated:YES];
    
    [self downloadPresenceList];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


- (IBAction)ibaChiudi:(id)sender {
    
    //NSLog(@"ibaChiudi");
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark === downloadPresence ===
#pragma mark -

- (void)downloadPresenceList {
    
    //NSLog(@"downloadListPresence");
    
    NethCTIAPI *api = [NethCTIAPI sharedInstance];
    
    [api getPresenceListWithSuccessHandler:^(NSArray *arrayPresence) {
        
        NSLog(@"arrayPresence: %@", arrayPresence);

        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Nascondo la ViewCaricamento
            [self.HUD hideAnimated:YES];
            
            [self.refreshControl endRefreshing];
            
            self.arrayPresence = [[NSMutableArray alloc] initWithArray:arrayPresence];
            
            [self.arrayPresence addObject:kKeyDisconnesso];
            //NSLog(@"self.arrayPresence: %@", self.arrayPresence);

            [self.ibTableViewSelezionePresence reloadData];
            
        });
        
    } errorHandler:^(NSInteger code, NSString * _Nullable messageDafault) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"getPresenceList ERROR code: %ld, messageDafault: %@", (long)code, messageDafault);
            
            // Nascondo la ViewCaricamento
            [self.HUD hideAnimated:YES];
            
            [self.refreshControl endRefreshing];
            
            [self showAlertError:code withError:messageDafault];
            
        });
        
        
    }];
    
}



#pragma mark -
#pragma mark === Table view data source ===
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //NSLog(@"arrayUsers.count: %d", self.arrayUsers.count);
    
    if (self.arrayPresence.count > 0) {
        
        self.ibLabelNessunDato.hidden = YES;
        
        return 1;
        
    }else {
        
        self.ibLabelNessunDato.hidden = NO;
        
        return 0;
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //NSLog(@"arrayUsers.count: %d", self.arrayUsers.count);
    
    return self.arrayPresence.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"cellForRowAtIndexPath indexPath.row: %ld", (long)indexPath.row);
    
    static NSString *CellIdentifier = @"idPresenceSelectListTableViewCell";
    
    PresenceSelectListTableViewCell *presenceSelectListTableViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!presenceSelectListTableViewCell) {
        
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PresenceSelectListTableViewCell class]) owner:self options:nil];
        
        presenceSelectListTableViewCell = (PresenceSelectListTableViewCell *)self.ibPresenceSelectListTableViewCell;
        
        self.ibPresenceSelectListTableViewCell = nil;
    }
    
    NSString *presenceCurrent = (NSString *)[self.arrayPresence objectAtIndex:indexPath.row];
    //NSLog(@"LOGD presenceCurrent: %@", presenceCurrent);
    
    [self setPresenceCell:presenceSelectListTableViewCell withPresence:presenceCurrent];
    
    
    
    return presenceSelectListTableViewCell;
}



#pragma mark -
#pragma mark === Table view delegate ===
#pragma mark -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *presenceSelezionata = (NSString *)[self.arrayPresence objectAtIndex:indexPath.row];
    //NSLog(@" presenceSelezionata: %@", presenceSelezionata);
    
    if ([presenceSelezionata isEqualToString:kKeyDisconnesso]) {
        // DISCONNESSO
        
        [self disabilitaProxy];
        
    }else {
        // altri casi
        
        if ([presenceSelezionata isEqualToString:kKeyCallforward]) {
            // INOLTRO
            
            [self visualizzaAlertInoltro];
            
        }else {
            
            [self.HUD showAnimated:YES];

            [self abilitaProxy];
            
            [self performSelector:@selector(impostaPresence:) withObject:presenceSelezionata afterDelay:1.0];
        }
        
    }
    
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSString *presenceCurrent = (NSString *)[self.arrayPresence objectAtIndex:indexPath.row];
    //NSLog(@" presenceCurrent: %@", presenceCurrent);
    
    [self setPresenceCell:(PresenceSelectListTableViewCell *)cell withPresence:presenceCurrent];
    
}





- (void)setPresenceCell:(PresenceSelectListTableViewCell *)presenceSelectListTableViewCell withPresence:(NSString *)presence {
    
    //NSLog(@"setPresenceCell: %@ - presence: %@", presenceSelectListTableViewCell, presence);
    
    if ([presence isEqualToString:kKeyOnline]) {
        // ONLINE
        
        presenceSelectListTableViewCell.ibLabelNome.text = NSLocalizedString(@"Disponibile", nil);
        
        presenceSelectListTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOnline"];
        presenceSelectListTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_online"];
        
        
    }else if ([presence isEqualToString:kKeyCellphone]) {
        // CELLPHONE
        
        presenceSelectListTableViewCell.ibLabelNome.text = NSLocalizedString(@"Cellulare", nil);
        
        presenceSelectListTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCellphone"];
        presenceSelectListTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_cellphone"];
        
        
    }else if ([presence isEqualToString:kKeyVoicemail]) {
        // VOICEMAIL
        
        presenceSelectListTableViewCell.ibLabelNome.text = NSLocalizedString(@"Casella Vocale", nil);
        
        presenceSelectListTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceVoicemail"];
        presenceSelectListTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_voicemail"];
        
        
    }else if ([presence isEqualToString:kKeyDnd]) {
        // DND
        
        presenceSelectListTableViewCell.ibLabelNome.text = NSLocalizedString(@"Non distrubare", nil);
        
        presenceSelectListTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceDnd"];
        presenceSelectListTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_dnd"];
        
    }else if ([presence isEqualToString:kKeyCallforward]) {
        // CALLFORWARD
        
        presenceSelectListTableViewCell.ibLabelNome.text = NSLocalizedString(@"Inoltro", nil);
        
        presenceSelectListTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCallforward"];
        presenceSelectListTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_callforward"];
        
    }else if([presence isEqualToString:kKeyDisconnesso]) {
        // DISCONNESSO
        
        presenceSelectListTableViewCell.ibLabelNome.text = NSLocalizedString(@"Disconnesso", nil);
        
        presenceSelectListTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOffline"];
        presenceSelectListTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_offline"];
    }
    
    
    // SELEZIONATO
    if ([self.presenceSelezionata isEqualToString:presence]) {
        
        presenceSelectListTableViewCell.ibLabelNome.textColor = [UIColor colorNamed: @"mainColor"];
        
        presenceSelectListTableViewCell.ibImageViewSelezionato.image = [UIImage imageNamed:@"icn_check_blu"];
        
    }else {
        
        presenceSelectListTableViewCell.ibLabelNome.textColor = [UIColor colorNamed: @"textColor"];
        
        presenceSelectListTableViewCell.ibImageViewSelezionato.image = nil;
    }
    
}


- (void)impostaPresence:(NSString *)presenceSelezionata {
    
    //NSLog(@"impostaPresence: %@", presenceSelezionata);
    
    NethCTIAPI *api = [NethCTIAPI sharedInstance];
    
    [api postSetPresenceWithStatus:presenceSelezionata
                            number:@""
                    successHandler:^(NSString * _Nullable success) {
        
        //NSLog(@"success: %@", success);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Nascondo la ViewCaricamento
            [self.HUD hideAnimated:YES];
            
            // chiudi controller
            [self dismissViewControllerAnimated:YES completion:nil];
            
            // implementare nel completion?
            [self.presenceSelectListDelegate reloadPresence];
        });
        
        
    }
                      errorHandler:^(NSInteger errorCode, NSString * _Nullable errorDefault) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"postSetPresence ERROR code: %ld, errorDefault: %@", (long)errorCode, errorDefault);
            
            // Nascondo la ViewCaricamento
            [self.HUD hideAnimated:YES];
            
            [self showAlertError:errorCode withError:errorDefault];
            
        });
        
    }];
}



- (void)impostaInoltroWith:(UIAlertController *)alertControllerInoltro {

    //NSLog(@"impostaInoltroWith: %@", alertControllerInoltro);

    //NSLog(@"self.numeroInoltro: %@", self.numeroInoltro);
    
    NethCTIAPI *api = [NethCTIAPI sharedInstance];
    
    [api postSetPresenceWithStatus:kKeyCallforward
                            number:self.numeroInoltro
                    successHandler:^(NSString * _Nullable success) {
        
        //NSLog(@"success: %@", success);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Nascondo la ViewCaricamento
            [self.HUD hideAnimated:YES];
            
            // chiudo alert
            [alertControllerInoltro dismissViewControllerAnimated:YES completion:nil];
            
            // chiudo controller
            [self dismissViewControllerAnimated:YES completion:nil];
            
            // implementare nel completion?
            [self.presenceSelectListDelegate reloadPresence];
            
        });
        
    }
                      errorHandler:^(NSInteger errorCode, NSString * _Nullable messageDafault) {
        
        NSLog(@"postSetPresence errorCode: %ld - messageDafault: %@", (long)errorCode, messageDafault);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Nascondo la ViewCaricamento
            [self.HUD hideAnimated:YES];
            
            [self showAlertError:errorCode withError:messageDafault];
            
        });
        
    }];
    
}



- (void)visualizzaAlertInoltro {
    
    NSLog(@"visualizzaAlertInoltro");
    
    UIAlertController *alertControllerInoltro = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Inserisci", nil)
                                                                                    message:NSLocalizedString(@"Numero telefonico", nil)
                                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    [alertControllerInoltro addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        
        //textField.textColor = [UIColor blueColor];
        textField.placeholder = NSLocalizedString(@"Numero", nil);
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        //textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.keyboardType = UIKeyboardTypePhonePad;
        
    }];
    
    // OK
    [alertControllerInoltro addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action) {
        
        NSArray *arrayTextfields = alertControllerInoltro.textFields;
        UITextField *numeroTextField = arrayTextfields.firstObject;
        //UITextField * passwordfiled = textfields[1];
        
        //NSLog(@"numeroTextField: %@", numeroTextField.text);
        
        if ([numeroTextField.text isEqual:@""]) {
            
            // chiudo il precedente
            [alertControllerInoltro dismissViewControllerAnimated:YES completion:nil];
            
            
            // --- Alert avviso ---
            UIAlertController *alertControllerAvviso = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Attenzione", nil)
                                                                                           message:NSLocalizedString(@"Devi inserire il numero telefonico da utilizzare per inoltrare la chiamata", nil)
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            [alertControllerAvviso addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                      style:UIAlertActionStyleCancel
                                                                    handler:^(UIAlertAction *action) {
                
                [alertControllerAvviso dismissViewControllerAnimated:YES completion:nil];
                
            }]];
            
            [self presentViewController:alertControllerAvviso animated:YES completion:nil];
            // ---------------
            
            
        }else {
            
            
            // Controllo numeri
            NSCharacterSet *notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
            
            if ([numeroTextField.text rangeOfCharacterFromSet:notDigits].location == NSNotFound) {
                
                // numeroTextField.text consists only of the digits 0 through 9
                self.numeroInoltro = numeroTextField.text;

                [self.HUD showAnimated:YES];

                [self abilitaProxy];

                [self performSelector:@selector(impostaInoltroWith:) withObject:alertControllerInoltro afterDelay:1.0];
                
            }else {
                
                // --- Alert Avviso ---
                UIAlertController *alertControllerAvviso = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Attenzione", nil)
                                                                                               message:NSLocalizedString(@"Puoi inserire solo numeri", nil)
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                [alertControllerAvviso addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                          style:UIAlertActionStyleCancel
                                                                        handler:^(UIAlertAction *action) {
                    
                    // chiudi alert
                    [alertControllerAvviso dismissViewControllerAnimated:YES completion:nil];
                    
                }]];
                
                [self presentViewController:alertControllerAvviso animated:YES completion:nil];
            }
            // -----------------------
            
        }
        
    }]];
    
    // BTN Annulla
    [alertControllerInoltro addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Annulla", nil)
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action) {
        
        [alertControllerInoltro dismissViewControllerAnimated:YES completion:nil];
        
    }]];
    
    // Visualizza Alert INOLTRO
    [self presentViewController:alertControllerInoltro animated:YES completion:nil];
    
}



- (void)showAlertError:(NSInteger *)codeError withError:(NSString *)stringError {
    
    NSString *message = @"";
    
    NSInteger code = codeError;
    
    switch (code) {
        case 2:
            
            message = NSLocalizedStringFromTable(@"Network connection unavailable", @"NethLocalizable", nil);
            break;
            
        case 401:
            
            message = NSLocalizedStringFromTable(@"Session expired. To see contacts you need to logout and login again.", @"NethLocalizable", nil);
            break;
            
        default:{
            
            message = stringError;
            
            break;
        }
    }
    
    UIAlertController *alertControllerAvviso = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Attenzione", nil)
                                                                                   message:message
                                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    // btn OK
    [alertControllerAvviso addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                              style:UIAlertActionStyleCancel
                                                            handler:^(UIAlertAction *action) {
        
        // chiudi alert
        [alertControllerAvviso dismissViewControllerAnimated:YES completion:nil];
        
    }]];
    
    [self presentViewController:alertControllerAvviso animated:YES completion:nil];
}



- (void)abilitaProxy {
 
    NSString *username = portableNethUserMe.intern;
    NSLog(@"username: %@", username);

    const MSList *proxies = linphone_core_get_proxy_config_list(LC);

    while (username &&
           proxies &&
           strcmp(username.UTF8String, linphone_address_get_username(linphone_proxy_config_get_identity_address(proxies->data))) != 0) {
        
        proxies = proxies->next;
    }
    
    LinphoneProxyConfig *linphoneProxyConfig = NULL;
    
    if (proxies) {
        
        linphoneProxyConfig = proxies->data;
        
        linphone_proxy_config_enable_register(linphoneProxyConfig, YES);

        // --- setup new proxycfg ---
        //linphone_proxy_config_done(linphoneProxyConfig);
        // --------------------------
    }
    
}


- (void)disabilitaProxy {
    
    NSString *username = portableNethUserMe.intern;
    NSLog(@"username: %@", username);

    const MSList *proxies = linphone_core_get_proxy_config_list(LC);

    while (username &&
           proxies &&
           strcmp(username.UTF8String, linphone_address_get_username(linphone_proxy_config_get_identity_address(proxies->data))) != 0) {
        
        proxies = proxies->next;
    }
    
    LinphoneProxyConfig *linphoneProxyConfig = NULL;
    
    if (proxies) {
        
        linphoneProxyConfig = proxies->data;
        
        linphone_proxy_config_enable_register(linphoneProxyConfig, NO);

        // --- setup new proxycfg ---
        //linphone_proxy_config_done(linphoneProxyConfig);
        // --------------------------
    }
    
    
    presenceSelezionata = kKeyDisconnesso;

    [self.ibTableViewSelezionePresence reloadData];

    
    // chiudi controller
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // implementare nel completion?
    [self.presenceSelectListDelegate reloadPresence];
    
}


- (void)getProxyState {
    
    NSLog(@"getProxyFrom");
    
    NSString *username = portableNethUserMe.intern;
    NSLog(@"username: %@", username);

    const MSList *proxies = linphone_core_get_proxy_config_list(LC);

    while (username &&
           proxies &&
           strcmp(username.UTF8String, linphone_address_get_username(linphone_proxy_config_get_identity_address(proxies->data))) != 0) {
        
        proxies = proxies->next;
    }
    
    LinphoneProxyConfig *linphoneProxyConfig = NULL;
    
    if (proxies) {
        
        linphoneProxyConfig = proxies->data;
        //NSLog(@"proxy: %@", proxy);
        
        BOOL is_proxy_config_register_enabled = linphone_proxy_config_register_enabled(linphoneProxyConfig);
        NSLog(@"is_proxy_config_register_enabled: %@", is_proxy_config_register_enabled ? @"YES" : @"NO");
        
        if (NO == is_proxy_config_register_enabled) {
            
            presenceSelezionata = kKeyDisconnesso;
        }
        
    }else {
        
        NSLog(@"proxies nil!!!");
    }
    
}


@end
