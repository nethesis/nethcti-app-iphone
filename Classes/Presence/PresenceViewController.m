//
//  PresenceViewController.m
//  NethCTI
//
//  Created by Democom S.r.l. on 18/01/22.
//

#import "PresenceViewController.h"
#import "PhoneMainView.h"
#import "PresenceTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "PresenceSelectListViewController.h"
#import "PresenceSelectListGroupViewController.h"
#import "PresenceActionViewController.h"



@interface PresenceViewController ()

@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (retain, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSMutableArray *arrayGruppiVisibili;
@property (assign) BOOL isGroupsFilter;
@property (strong, nonatomic) NSMutableArray *arrayUsersFiltered;
@property (strong, nonatomic) NSMutableArray *arrayUsersGruppoSelezionato;
@property (strong, nonatomic) NSArray *arrayAllUsers;

@end


@implementation PresenceViewController

@synthesize topBar;
@synthesize portableNethUserMe;
@synthesize id_groupSelezionato;



#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    
    if (compositeDescription == nil) {
        
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:StatusBarView.class
                                                                 tabBar:nil
                                                               sideMenu:SideMenuView.class
                                                             fullscreen:false
                                                         isLeftFragment:YES
                                                           fragmentWith:nil];
    }
    
    return compositeDescription;
}


- (UICompositeViewDescription *)compositeViewDescription {
    
    return self.class.compositeViewDescription;
}


#pragma mark - ViewController Functions

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //NSLog(@"viewDidLoad - PresenceViewController");
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:self.HUD];
    
    
    
    // --- UIRefreshControl ---
    // Initialize Refresh Control
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    //self.refreshControl.tintColor = colorDivider;
    
    // Configure Refresh Control
    [self.refreshControl addTarget:self action:@selector(downloadPresence) forControlEvents:UIControlEventValueChanged];
    
    // Configure View Controller
    [self.ibTableViewPresence addSubview:self.refreshControl];
    // ------------------------
    
    
    self.ibButtonSelezionePresence.titleLabel.adjustsFontSizeToFitWidth = 0.7;

    // --- Default filtro per gruppi selezionato ---
    self.id_groupSelezionato = @"";
    self.isGroupsFilter = YES;
    
    self.ibLabelPreferiti.textColor = [UIColor colorNamed:@"ColorTextBlack"];

    [self.ibButtonSelezionaPreferiti setImage:[UIImage imageNamed:@"icn_preferiti_off"] forState:UIControlStateNormal];
    self.ibButtonSelezionaPreferiti.backgroundColor = [UIColor colorNamed: @"SfondoButtons"];

    
    self.ibLabelGruppi.textColor = [UIColor colorNamed: @"mainColor"];

    [self.ibButtonSelezionaGruppi setImage:[UIImage imageNamed:@"icn_gruppi_on"] forState:UIControlStateNormal];
    self.ibButtonSelezionaGruppi.backgroundColor = [UIColor colorNamed: @"SfondoButtonsOn"];
    // ----------------------------------------------
    
    
    [self setMePresence];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //NSLog(@"viewWillAppear - PresenceViewController");

    [_backButton setTintColor:[UIColor colorNamed: @"iconTint"]];
    
    
    // Set observer
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(registrationUpdate:) name:kLinphoneRegistrationUpdate object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(globalStateUpdate:) name:kLinphoneGlobalStateUpdate object:nil];
    //[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(notifyReceived:) name:kLinphoneNotifyReceived object:nil];
    //[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(mainViewChanged:) name:kLinphoneMainViewChange object:nil];
    //[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(callUpdate:) name:kLinphoneCallUpdate object:nil];
    //[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onCallEncryptionChanged:) name:kLinphoneCallEncryptionChanged object:nil];
    
    [self.HUD showAnimated:YES];
    [self downloadPresence];
    
    // --- AGGIORNAMENTO DATI OGNI 3 SECONDI ---
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(downloadPresence) userInfo:nil repeats:YES];
    // ------------------------------------------
}


/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"viewDidAppear - PresenceViewController");
    
}
*/


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    //NSLog(@"viewWillDisappear - PresenceViewController");
    
    
    // Remove observer
    [NSNotificationCenter.defaultCenter removeObserver:self name:kLinphoneRegistrationUpdate object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:kLinphoneGlobalStateUpdate object:nil];
    //[NSNotificationCenter.defaultCenter removeObserver:self name:kLinphoneNotifyReceived object:nil];
    //[NSNotificationCenter.defaultCenter removeObserver:self name:kLinphoneCallUpdate object:nil];
    //[NSNotificationCenter.defaultCenter removeObserver:self name:kLinphoneMainViewChange object:nil];
    
    
    [self.refreshControl endRefreshing];
    
    [self.timer invalidate];
    self.timer = nil;
    
    // --- ATTENZIONE: forza il viewDidLoad! ---
    //self.view = NULL;
    // -----------------------------------------
}



#pragma mark - Event Functions

/**
 * Handle the update.
 * @param notif The nofication received.
 */
- (void)registrationUpdate:(NSNotification *)notification {
    
    //NSLog(@"registrationUpdate - notification: %@", notification);

    LinphoneProxyConfig *config = linphone_core_get_default_proxy_config(LC);
    
    [self proxyConfigUpdate:config];
}

- (void)globalStateUpdate:(NSNotification *)notification {
    
    //NSLog(@"globalStateUpdate - notification: %@", notification);

    [self registrationUpdate:nil];
}


- (void)proxyConfigUpdate:(LinphoneProxyConfig *)config {
    
    LinphoneRegistrationState state = LinphoneRegistrationNone;
    LinphoneGlobalState gstate = linphone_core_get_global_state(LC);
    
    NSString *message = nil;

    if ([PhoneMainView.instance.currentView equal:AssistantView.compositeViewDescription] ||
        [PhoneMainView.instance.currentView equal:CountryListView.compositeViewDescription]) {
        
        message = NSLocalizedString(@"Configuring account", nil);
        
    } else if (gstate == LinphoneGlobalOn && !linphone_core_is_network_reachable(LC)) {
        
        message = NSLocalizedString(@"Network down", nil);
        
    } else if (gstate == LinphoneGlobalConfiguring) {
        
        message = NSLocalizedString(@"Fetching remote configuration", nil);
        
    } else if (config == NULL) {
        
        state = LinphoneRegistrationNone;
        
        if (linphone_core_get_proxy_config_list(LC) != NULL) {
            
            message = NSLocalizedString(@"No default account", nil);
            
        }else {
            
            message = NSLocalizedString(@"No account configured", nil);
        }

    }else {
        
        state = linphone_proxy_config_get_state(config);

        switch (state) {
                
            case LinphoneRegistrationOk:
                
                message = NSLocalizedString(@"Connected", nil);
                
                break;
                
            case LinphoneRegistrationNone:
                
            case LinphoneRegistrationCleared:
                
                message = NSLocalizedString(@"Not connected", nil);
                
                break;
                
            case LinphoneRegistrationFailed:
                
                message = NSLocalizedString(@"Connection failed", nil);
                
                break;
                
            case LinphoneRegistrationProgress:
                
                message = NSLocalizedString(@"Connection in progress", nil);
                
                break;
                
            default:
                break;
        }
    }
    

    NSLog(@"message: %@", message);
    
    // Nascondo la ViewCaricamento
    [self.HUD hideAnimated:YES];
}



- (void)loadDataFiltered {
    
    //NSLog(@"loadDataFiltered");
    
    if (YES == self.isGroupsFilter) {
        // visualizza GRUPPI
        
        self.arrayUsersFiltered = [[NSMutableArray alloc] initWithArray:self.arrayUsersGruppoSelezionato];
        
    }else {
        //visualizza PREFERITI

        self.arrayUsersFiltered = [NSMutableArray new];
        
        // --- Rimozione delle NSUserDefaults ---
        //NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        //[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        // --------------------------------------
   
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //NSLog(@"defaults_keys: %@", [[defaults dictionaryRepresentation] allKeys]);

        if ([[[defaults dictionaryRepresentation] allKeys] containsObject:kKeyPreferiti]){
                        
            if ([defaults arrayForKey:kKeyPreferiti] != nil) {
                
                // getting an NSArray
                NSArray *arrayUsersPreferiti = [[NSArray alloc] initWithArray:[defaults arrayForKey:kKeyPreferiti]];

                if (arrayUsersPreferiti.count > 0) {
                    
                    for (NSString *usernameCorrente in arrayUsersPreferiti) {
                        
                        //NSLog(@"CERCO usernameCorrente: %@", usernameCorrente);

                        if (self.arrayAllUsers.count > 0) {
                            
                            for (PresenceUserObjc *presenceUserObjcCorrente in self.arrayAllUsers) {
                                
                                //NSLog(@"presenceUserObjcCorrente.username: %@", presenceUserObjcCorrente.username);

                                if ([presenceUserObjcCorrente.username isEqualToString:usernameCorrente]) {
                                    
                                    //NSLog(@"AGGIUNTO presenceUserObjcCorrente.username: %@", presenceUserObjcCorrente.username);
                                    
                                    [self.arrayUsersFiltered addObject:presenceUserObjcCorrente];
                                }
                            }
                        }
                    }
                    
                }else {
                    
                    NSLog(@"Nessun preferito salvato");
                }
            }
            
        }else {
            
            NSLog(@"key preferiti_username_nethesis NOT found!");
        }
    }
    
    
    // --- ordinamento dal più piccolo al più grande sulla chiave name ---
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *arrayUsersSorted = [self.arrayUsersFiltered sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.arrayUsersFiltered = [[NSMutableArray alloc]initWithArray:arrayUsersSorted];
    // -------------------------------------------------------------------
    
    
    [self.ibTableViewPresence reloadData];
}



#pragma mark - IBAction Functions

- (IBAction)ibaVisualizzaAzioni:(UIButton *)sender {
    
    //NSLog(@"ibaVisualizzaAzioni sender.tag: %ld", (long)sender.tag);

    PresenceUserObjc *presenceUserObjcSelezionato = (PresenceUserObjc *)[self.arrayUsersFiltered objectAtIndex:sender.tag];
    
    PresenceActionViewController *presenceActionViewController = [[PresenceActionViewController alloc] init];
    
    presenceActionViewController.presenceUserObjcSelezionato = presenceUserObjcSelezionato;
    presenceActionViewController.portableNethUserMe = self.portableNethUserMe;
    presenceActionViewController.presenceActionDelegate = self;
    
    [presenceActionViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];

    [presenceActionViewController setModalPresentationStyle:UIModalPresentationCustom];

    [self presentViewController:presenceActionViewController animated:true completion:nil];
    
}


- (IBAction)ibaVisualizzaPreferiti:(id)sender {
    
    //NSLog(@"ibaVisualizzaPreferiti");
    
    if (YES == self.isGroupsFilter) {

        self.isGroupsFilter = NO;
        
        self.ibLabelPreferiti.textColor = [UIColor colorNamed: @"mainColor"];
        
        [self.ibButtonSelezionaPreferiti setImage:[UIImage imageNamed:@"icn_preferiti_on"] forState:UIControlStateNormal];
        self.ibButtonSelezionaPreferiti.backgroundColor = [UIColor colorNamed: @"SfondoButtonsOn"];

        
        self.ibLabelGruppi.textColor = [UIColor colorNamed:@"ColorTextBlack"];

        [self.ibButtonSelezionaGruppi setImage:[UIImage imageNamed:@"icn_gruppi_off"] forState:UIControlStateNormal];
        self.ibButtonSelezionaGruppi.backgroundColor = [UIColor colorNamed: @"SfondoButtons"];

        [self loadDataFiltered];
    }
}


- (IBAction)ibaVisualizzaGruppi:(id)sender {
    
    //NSLog(@"ibaVisualizzaGruppi");
    
    if (YES == self.isGroupsFilter) {
        
        PresenceSelectListGroupViewController *presenceSelectListGroupViewController = [[PresenceSelectListGroupViewController alloc] init];
            
        presenceSelectListGroupViewController.arrayGroups = self.arrayGruppiVisibili;
        presenceSelectListGroupViewController.id_groupSelezionato = self.id_groupSelezionato;
        presenceSelectListGroupViewController.presenceSelectListGroupDelegate = self;

        /*
        if (@available(iOS 13.0, *)) {
            
            [presenceSelectListGroupViewController setModalPresentationStyle:UIModalPresentationAutomatic];
            
        } else {
            // Fallback on earlier versions
            [presenceSelectListGroupViewController setModalPresentationStyle:UIModalPresentationFullScreen];
        }
        */
        [presenceSelectListGroupViewController setModalPresentationStyle:UIModalPresentationOverFullScreen];

        
        [self presentViewController:presenceSelectListGroupViewController animated:true completion:nil];
        
    }else {
        
        self.isGroupsFilter = YES;
        
        self.ibLabelPreferiti.textColor = [UIColor colorNamed:@"ColorTextBlack"];

        [self.ibButtonSelezionaPreferiti setImage:[UIImage imageNamed:@"icn_preferiti_off"] forState:UIControlStateNormal];
        self.ibButtonSelezionaPreferiti.backgroundColor = [UIColor colorNamed: @"SfondoButtons"];

        
        self.ibLabelGruppi.textColor = [UIColor colorNamed: @"mainColor"];

        [self.ibButtonSelezionaGruppi setImage:[UIImage imageNamed:@"icn_gruppi_on"] forState:UIControlStateNormal];
        self.ibButtonSelezionaGruppi.backgroundColor = [UIColor colorNamed: @"SfondoButtonsOn"];

        
        [self loadDataFiltered];

    }
    

}


- (IBAction)ibaSelezionePresence:(id)sender {
    
    //NSLog(@"ibaSelezionePresence");
    
    PresenceSelectListViewController *presenceSelectListViewController = [[PresenceSelectListViewController alloc] init];
    
    presenceSelectListViewController.presenceSelezionata = self.portableNethUserMe.presence;
    presenceSelectListViewController.portableNethUserMe = self.portableNethUserMe;
    presenceSelectListViewController.presenceSelectListDelegate = self;
    
    [presenceSelectListViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];

    [presenceSelectListViewController setModalPresentationStyle:UIModalPresentationCustom];

    [self presentViewController:presenceSelectListViewController animated:true completion:nil];
}



- (IBAction)onBackPressed:(id)sender {
    
    //NSLog(@"onBackPressed");
    
    [PhoneMainView.instance popCurrentView];
}




#pragma mark -
#pragma mark === Table view data source ===
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //LOGD(@"LOGD arrayUsers.count: %d", self.arrayUsers.count);
    
    if (self.arrayUsersFiltered.count > 0) {
        
        self.ibLabelNessunDato.hidden = YES;

        return 1;
        
    }else {
        
        self.ibLabelNessunDato.hidden = NO;
        
        return 0;
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //LOGD(@"LOGD arrayUsers.count: %d", self.arrayUsers.count);
    
    return self.arrayUsersFiltered.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"
        
    static NSString *CellIdentifier = @"idPresenceTableViewCell";
    
    PresenceTableViewCell *presenceTableViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!presenceTableViewCell) {
        
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PresenceTableViewCell class]) owner:self options:nil];
        
        presenceTableViewCell = (PresenceTableViewCell *)self.ibPresenceTableViewCell;
        
        self.ibPresenceTableViewCell = nil;
    }
    
    PresenceUserObjc *presenceUserObjcCorrente = (PresenceUserObjc *)[self.arrayUsersFiltered objectAtIndex:indexPath.row];
    //NSLog(@"portablePresenceUser: %@", portablePresenceUser.name);
    
    presenceTableViewCell.ibButtonVisualizzaAzioni.tag = indexPath.row;
    
    // bordo status
    [presenceTableViewCell.ibImageViewBordoStatus.layer setBorderWidth: 1.0];
    
    
    
    // --- INIZIALI NOME ---
    NSString *noteUtente = presenceUserObjcCorrente.name;
    NSArray *arrayFirstLastStrings = [noteUtente componentsSeparatedByString:@" "];
    
    NSString *nome = [arrayFirstLastStrings objectAtIndex:0];
    char nomeInitialChar = [nome characterAtIndex:0];
    
    //NSLog(@"nomeInitialChar: %c", nomeInitialChar);
    
    if (arrayFirstLastStrings.count > 1) {
        
        NSString *cognome = [arrayFirstLastStrings objectAtIndex:1];
        
        char cognomeInitialChar = [cognome characterAtIndex:0];
        //NSLog(@"cognomeInitialChar: %c", cognomeInitialChar);
        
        presenceTableViewCell.ibLabelIniziali.text = [NSString stringWithFormat:@"%c%c", nomeInitialChar, cognomeInitialChar];
        
    }else {
        
        presenceTableViewCell.ibLabelIniziali.text = [NSString stringWithFormat:@"%c", nomeInitialChar];
    }
    // ----------------------
    
    
    // NOME utente
    presenceTableViewCell.ibLabelName.text = noteUtente;
    
    
    [self setUserPresence:presenceTableViewCell withPresenceUserObjc:presenceUserObjcCorrente];
    
    if ([presenceUserObjcCorrente.username isEqualToString:self.portableNethUserMe.username]) {
        
        presenceTableViewCell.ibButtonVisualizzaAzioni.hidden = YES;
        
    }else {
        
        presenceTableViewCell.ibButtonVisualizzaAzioni.hidden = NO;
    }
    
    return presenceTableViewCell;
}



#pragma mark -
#pragma mark === Table view delegate ===
#pragma mark -
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"didSelectRowAtIndexPath: %ld", (long)indexPath.row);

    PortablePresenceUser *portablePresenceUserSelezionato = (PortablePresenceUser *)[self.arrayUsers objectAtIndex:indexPath.row];

    PresenceActionViewController *presenceActionViewController = [[PresenceActionViewController alloc] init];
    
    presenceActionViewController.portablePresenceUser = portablePresenceUserSelezionato;
    presenceActionViewController.portableNethUserMe = self.userMe;
    
    [presenceActionViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];

    [presenceActionViewController setModalPresentationStyle:UIModalPresentationCustom];

    [self presentViewController:presenceActionViewController animated:true completion:nil];
}
*/

/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}
*/



- (void)setUserPresence:(PresenceTableViewCell *)presenceTableViewCell withPresenceUserObjc: (PresenceUserObjc *)presenceUserObjc {
    
    NSString *presence = presenceUserObjc.mainPresence;
    //NSLog(@"presence: %@", presence);
    
    if ([presence isEqualToString:kKeyOnline]) {
        // ONLINE
        
        [presenceTableViewCell.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceOnline"] CGColor]];
        
        presenceTableViewCell.ibViewSfondoLabelStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOnline"];
        
        presenceTableViewCell.ibLabelStatus.text = NSLocalizedString(@"DISPONIBILE", nil);
        
        presenceTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOnline"];
        presenceTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_online"];
        
        
    }else if ([presence isEqualToString:kKeyBusy]) {
        // BUSY
        
        [presenceTableViewCell.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceBusy"] CGColor]];
        
        presenceTableViewCell.ibViewSfondoLabelStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceBusy"];
        
        presenceTableViewCell.ibLabelStatus.text = NSLocalizedString(@"OCCUPATO", nil);
        
        presenceTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceBusy"];
        presenceTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_busy"];
        
        
    }else if ([presence isEqualToString:kKeyRinging]) {
        // INCOMING
        
        [presenceTableViewCell.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceIncoming"] CGColor]];
        
        presenceTableViewCell.ibViewSfondoLabelStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceIncoming"];
        
        presenceTableViewCell.ibLabelStatus.text = NSLocalizedString(@"IN ENTRATA", nil);
        
        presenceTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceIncoming"];
        presenceTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_incoming"];
        
        
    }else if ([presence isEqualToString:kKeyOffline]) {
        // OFFLINE
        
        [presenceTableViewCell.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceOffline"] CGColor]];
        
        presenceTableViewCell.ibViewSfondoLabelStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOffline"];
        
        presenceTableViewCell.ibLabelStatus.text = NSLocalizedString(@"NON DISPONIBILE", nil);
        
        presenceTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOffline"];
        presenceTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_offline"];
        
        
    }else if ([presence isEqualToString:kKeyCellphone]) {
        // CELLPHONE
        
        [presenceTableViewCell.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceCellphone"] CGColor]];
        
        presenceTableViewCell.ibViewSfondoLabelStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCellphone"];
        
        presenceTableViewCell.ibLabelStatus.text = NSLocalizedString(@"CELLULARE", nil);
        
        presenceTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCellphone"];
        presenceTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_cellphone"];
        
        
    }else if ([presence isEqualToString:kKeyVoicemail]) {
        // VOICEMAIL
        
        [presenceTableViewCell.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceVoicemail"] CGColor]];
        
        presenceTableViewCell.ibViewSfondoLabelStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceVoicemail"];
        
        presenceTableViewCell.ibLabelStatus.text = NSLocalizedString(@"CASELLA VOCALE", nil);
        
        presenceTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceVoicemail"];
        presenceTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_voicemail"];
        
        
    }else if ([presence isEqualToString:kKeyDnd]) {
        // DND
        
        [presenceTableViewCell.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceDnd"] CGColor]];
        
        presenceTableViewCell.ibViewSfondoLabelStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceDnd"];
        
        presenceTableViewCell.ibLabelStatus.text = NSLocalizedString(@"NON DISTURBARE", nil);
        
        presenceTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceDnd"];
        presenceTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_dnd"];
        
        
    }else if ([presence isEqualToString:kKeyCallforward]) {
        // CALLFORWORD
        
        [presenceTableViewCell.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceCallforward"] CGColor]];
        
        presenceTableViewCell.ibViewSfondoLabelStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCallforward"];
        
        presenceTableViewCell.ibLabelStatus.text = NSLocalizedString(@"INOLTRO", nil);
        
        presenceTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCallforward"];
        presenceTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_callforward"];
        
        
    }else {
        // Default
        
        [presenceTableViewCell.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceOffline"] CGColor]];
        
        presenceTableViewCell.ibViewSfondoLabelStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOffline"];
        
        presenceTableViewCell.ibLabelStatus.text = NSLocalizedString(@"N/D", nil);
        
        presenceTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOffline"];
        presenceTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_offline"];
    }
    
}



- (void)setMePresence {
    
    //NSLog(@"setMePresence");
    
    NSString *presence = self.portableNethUserMe.presence;
    //NSLog(@"presence: %@", presence);
    
    
    NSString *username = self.portableNethUserMe.intern;
    //NSLog(@"username: %@", username);

    const MSList *proxies = linphone_core_get_proxy_config_list(LC);

    while (username &&
           proxies &&
           strcmp(username.UTF8String, linphone_address_get_username(linphone_proxy_config_get_identity_address(proxies->data))) != 0) {
        
        proxies = proxies->next;
    }
    
    if (proxies) {
        
        LinphoneProxyConfig *linphoneProxyConfig = NULL;

        linphoneProxyConfig = proxies->data;
        //NSLog(@"proxy: %@", proxy);
        
        BOOL is_proxy_config_register_enabled = linphone_proxy_config_register_enabled(linphoneProxyConfig);
        //NSLog(@"is_proxy_config_register_enabled: %@", is_proxy_config_register_enabled ? @"YES" : @"NO");
        
        if (NO == is_proxy_config_register_enabled) {
            
            presence = kKeyDisconnesso;
        }
        
    }else {
        
        NSLog(@"proxies nil!");
    }
    
    
    if ([presence isEqualToString:kKeyOnline]) {
        // ONLINE
        
        [self.ibButtonSelezionePresence setTitle:NSLocalizedString(@"DISPONIBILE", nil) forState:UIControlStateNormal];
        
        self.ibButtonSelezionePresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOnline"];
        
        [self.ibButtonSelezionePresence setImage:[UIImage imageNamed:@"icn_cerchio_online"] forState:UIControlStateNormal];
        
    }else if ([presence isEqualToString:kKeyBusy]) {
        // BUSY
        
        [self.ibButtonSelezionePresence setTitle:NSLocalizedString(@"OCCUPATO", nil) forState:UIControlStateNormal];
        
        self.ibButtonSelezionePresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceBusy"];
        
        [self.ibButtonSelezionePresence setImage:[UIImage imageNamed:@"icn_cerchio_busy"] forState:UIControlStateNormal];
        
    }else if ([presence isEqualToString:kKeyRinging]) {
        // INCOMING
        
        [self.ibButtonSelezionePresence setTitle:NSLocalizedString(@"IN ENTRATA", nil) forState:UIControlStateNormal];
        
        self.ibButtonSelezionePresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceIncoming"];
        
        [self.ibButtonSelezionePresence setImage:[UIImage imageNamed:@"icn_cerchio_incoming"] forState:UIControlStateNormal];
        
    }else if ([presence isEqualToString:kKeyOffline]) {
        // OFFLINE
        
        [self.ibButtonSelezionePresence setTitle:NSLocalizedString(@"NON DISPONIBILE", nil) forState:UIControlStateNormal];
        
        self.ibButtonSelezionePresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOffline"];
        
        [self.ibButtonSelezionePresence setImage:[UIImage imageNamed:@"icn_cerchio_offline"] forState:UIControlStateNormal];
        
    }else if ([presence isEqualToString:kKeyCellphone]) {
        // CELLPHONE
        
        [self.ibButtonSelezionePresence setTitle:NSLocalizedString(@"CELLULARE", nil) forState:UIControlStateNormal];
        
        self.ibButtonSelezionePresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCellphone"];
        
        [self.ibButtonSelezionePresence setImage:[UIImage imageNamed:@"icn_cerchio_cellphone"] forState:UIControlStateNormal];
        
    }else if ([presence isEqualToString:kKeyVoicemail]) {
        // VOICEMAIL
        
        [self.ibButtonSelezionePresence setTitle:NSLocalizedString(@"CASELLA VOCALE", nil) forState:UIControlStateNormal];
        
        self.ibButtonSelezionePresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceVoicemail"];
        
        [self.ibButtonSelezionePresence setImage:[UIImage imageNamed:@"icn_cerchio_voicemail"] forState:UIControlStateNormal];
        
    }else if ([presence isEqualToString:kKeyDnd]) {
        // DND
        
        [self.ibButtonSelezionePresence setTitle:NSLocalizedString(@"NON DISTURBARE", nil) forState:UIControlStateNormal];
        
        self.ibButtonSelezionePresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceDnd"];
        
        [self.ibButtonSelezionePresence setImage:[UIImage imageNamed:@"icn_cerchio_dnd"] forState:UIControlStateNormal];
        
    }else if ([presence isEqualToString:kKeyCallforward]) {
        // CALLFORWORD
        
        [self.ibButtonSelezionePresence setTitle:NSLocalizedString(@"INOLTRO", nil) forState:UIControlStateNormal];
        
        self.ibButtonSelezionePresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCallforward"];
        
        [self.ibButtonSelezionePresence setImage:[UIImage imageNamed:@"icn_cerchio_callforward"] forState:UIControlStateNormal];
        
    } else if([presence isEqualToString:kKeyDisconnesso]) {
        // DISCONNESSO
        
        [self.ibButtonSelezionePresence setTitle:NSLocalizedString(@"Disconnesso", nil) forState:UIControlStateNormal];
        
        self.ibButtonSelezionePresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOffline"];
        
        [self.ibButtonSelezionePresence setImage:[UIImage imageNamed:@"icn_cerchio_offline"] forState:UIControlStateNormal];
        
    }else {
        // Default
        
        [self.ibButtonSelezionePresence setTitle:NSLocalizedString(@"N/D", nil) forState:UIControlStateNormal];
        
        self.ibButtonSelezionePresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOffline"];
        
        [self.ibButtonSelezionePresence setImage:[UIImage imageNamed:@"icn_cerchio_offline"] forState:UIControlStateNormal];
    }
    
}



#pragma mark -
#pragma mark === downloadPresence ===
#pragma mark -

- (void)downloadPresence {
    
    //NSLog(@"downloadPresence");
    
    NethCTIAPI *api = [NethCTIAPI sharedInstance];
    
    // Download INFO UTENTE
    [api getUserMeWithSuccessHandler:^(PortableNethUser *portableNethUser) {
        
        //NSLog(@"portableNethUser: %@", portableNethUser);

        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.portableNethUserMe = portableNethUser;
            
            [self setMePresence];
        });
                
        //NSLog(@"self.userMe.arrayPermissionsIdGroups: %@", self.userMe.arrayPermissionsIdGroups);

        // Download GRUPPI
        [api getGroupsWithSuccessHandler:^(NSArray *arrayGroups) {
            
            //NSLog(@"arrayGroups: %@", arrayGroups);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                                
                self.arrayGruppiVisibili = [NSMutableArray new];
                
                for (NSString *idGroupEnableCorrente in self.portableNethUserMe.arrayPermissionsIdGroups) {
                    
                    //NSLog(@"idGroupEnableCorrente: %@", idGroupEnableCorrente);
                    
                    for (GroupObjc *groupCorrente in arrayGroups) {
                        
                        if ([idGroupEnableCorrente isEqualToString:groupCorrente.id_group]) {
                            
                            //NSLog(@"AGGIUNTO id_group: %@", groupCorrente.id_group);
                            
                            [self.arrayGruppiVisibili addObject:groupCorrente];
                        }
                    }
                }
                
                
                // --- ordinamento dal più piccolo al più grande sulla chiave name ---
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
                NSArray *arrayGroupsSorted = [self.arrayGruppiVisibili sortedArrayUsingDescriptors:@[sortDescriptor]];
                self.arrayGruppiVisibili = [[NSMutableArray alloc]initWithArray:arrayGroupsSorted];
                // -------------------------------------------------------------------
                
            });

            
            
            // Download UTENTI
            [api getUserAllWithSuccessHandler:^(NSArray *arrayUsers) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                                                            
                    //NSLog(@"id_groupSelezionato: %@", self.id_groupSelezionato);
                    //NSLog(@"self.arrayGruppiVisibili: %@", self.arrayGruppiVisibili);

                    self.arrayAllUsers = [[NSArray alloc] initWithArray:arrayUsers];
                    
                    GroupObjc *groupVisibileSelezionato = nil;
                    
                    if ([self.id_groupSelezionato isEqualToString:@""]) {
                        
                        // --- Selezione default primo gruppo ---
                        groupVisibileSelezionato = self.arrayGruppiVisibili.firstObject;
                        
                        self.id_groupSelezionato = groupVisibileSelezionato.id_group;
                        // --------------------------------------
                                                
                    }else {
                        
                        for (GroupObjc *gruppoVisibileCorrente in self.arrayGruppiVisibili) {
                            
                            if ([self.id_groupSelezionato isEqualToString:gruppoVisibileCorrente.id_group]) {
                                
                                //NSLog(@"gruppoVisibileCorrente.id_group: %@", gruppoVisibileCorrente.id_group);
                                
                                groupVisibileSelezionato = gruppoVisibileCorrente;
                            }
                        }
                    }
                    
                    //NSLog(@"groupVisibileSelezionato.users: %@", groupVisibileSelezionato.users);
                    //NSLog(@"groupVisibileSelezionato.count: %lu", (unsigned long)groupVisibileSelezionato.users.count);
                    

                    self.ibLabelGruppi.text = [[NSString stringWithFormat:@"%@", groupVisibileSelezionato.name] uppercaseString];
                    
                    
                    self.arrayUsersGruppoSelezionato = [NSMutableArray new];
                    
                    for (NSString *keyUsernameCorrente in groupVisibileSelezionato.users) {
                        
                        //NSLog(@"CERCO keyUsernameCorrente: %@", keyUsernameCorrente);

                        for (PresenceUserObjc *userFromAllCorrente in self.arrayAllUsers) {
                            
                            //NSLog(@"userFromAllCorrente.username: %@", userFromAllCorrente.username);

                            if ([userFromAllCorrente.username isEqualToString:keyUsernameCorrente]) {
                                
                                //NSLog(@"AGGIUNTO userCorrente.username: %@", userFromAllCorrente.username);
                                
                                [self.arrayUsersGruppoSelezionato addObject:userFromAllCorrente];
                            }
                        }
                    }
                    
                    
                    //NSLog(@"arrayUsersVisibili.count: %lu", (unsigned long)arrayUsersVisibili.count);
                    
                    
                    
                    [self loadDataFiltered];
                    
                    
                    // Nascondo la ViewCaricamento
                    [self.HUD hideAnimated:YES];
                    
                    [self.refreshControl endRefreshing];
                });
                
                
                
                
            } errorHandler:^(NSInteger code, NSString * _Nullable messageDefault) {
                
                NSLog(@"getUserAll ERROR code: %ld, string: %@", (long)code, messageDefault);

                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // Nascondo la ViewCaricamento
                    [self.HUD hideAnimated:YES];
                    
                    [self.refreshControl endRefreshing];
                    
                    [self showAlertError:code withError:messageDefault];
                    
                });

            }];
            
        } errorHandler:^(NSInteger code, NSString * _Nullable messageDefault) {
            
            NSLog(@"getGroups ERROR code: %ld, string: %@", (long)code, messageDefault);

            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Nascondo la ViewCaricamento
                [self.HUD hideAnimated:YES];
                
                [self.refreshControl endRefreshing];
                
                [self showAlertError:code withError:messageDefault];
                
            });
                         
        }];
        
    } errorHandler:^(NSInteger code, NSString * _Nullable messageDefault) {
        
        NSLog(@"getUserMe API_ERROR code: %ld, string: %@", (long)code, messageDefault);

        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Nascondo la ViewCaricamento
            [self.HUD hideAnimated:YES];
            
            [self.refreshControl endRefreshing];
            
            [self showAlertError:code withError:messageDefault];
                        
        });
        
    }];
    
}



#pragma mark -
#pragma mark === PresenceSselectListeViewController delegate ===
#pragma mark -

- (void)reloadPresence {
    
    //NSLog(@"reloadPresence");
    
    [self.HUD showAnimated:YES];

    [self downloadPresence];
}


#pragma mark -
#pragma mark === PresenceSelectListeViewController delegate ===
#pragma mark -

- (void)reloadPresenceWithGroup:(NSString * _Nullable) id_group {
    
    //NSLog(@"reloadPresenceWithGroup: %@", id_group);
    
    self.id_groupSelezionato = id_group;
    
    [self.HUD showAnimated:YES];
    
    [self downloadPresence];
}



#pragma mark -
#pragma mark === PresenceActionViewController delegate ===
#pragma mark -

- (void)reloadPresenceFromAction {
    
    //NSLog(@"reloadPresenceFromAction");
        
    [self.HUD showAnimated:YES];
    
    [self downloadPresence];
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
                
    UIAlertController *alertControllerAvviso = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", nil)
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




@end
