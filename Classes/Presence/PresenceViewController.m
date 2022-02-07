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


#define kKeyOnline @"online"
#define kKeyBusy @"busy"
#define kKeyRinging @"ringing"
#define kKeyOffline @"offline"
#define kKeyCellphone @"cellphone"
#define kKeyVoicemail @"voicemail"
#define kKeyDnd @"dnd"
#define kKeyCallforward @"callforward"



@interface PresenceViewController ()

@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end


@implementation PresenceViewController

@synthesize topBar;
@synthesize arrayUsers;
@synthesize userMe;




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
    
    LOGD(@"viewDidAppear");
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:self.HUD];
    
    [self.HUD showAnimated:YES];
    
    
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
    
    [self downloadPresence];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    /*
     if (tableController.isEditing) {
     
     tableController.editing = NO;
     }
     */
    
    [self setUIColors];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    LOGD(@"viewDidAppear");
    
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    LOGD(@"viewWillDisappear");
    
    // --- ATTENZIONE: forza il viewDidLoad! ---
    self.view = NULL;
    // -----------------------------------------
    
    [self.refreshControl endRefreshing];
    
}



- (void)setUIColors{
    
    [_backButton setTintColor:[UIColor colorNamed: @"iconTint"]];
    
    //[self.presenceTableViewController.tableView setSeparatorColor:[UIColor colorNamed: @"accentColor"/*@"tableSeparator"*/]];
}


- (void)loadData {
    
    //LOGD(@"arrayUsers: %@", self.arrayUsers);
    
    [self.ibTableViewPresence reloadData];
}



#pragma mark - IBAction Functions

- (IBAction)ibaVisualizzaPreferiti:(id)sender {
    
    LOGD(@"ibaVisualizzaPreferiti");
    
}


- (IBAction)ibaVisualizzaGruppi:(id)sender {
    
    LOGD(@"ibaVisualizzaGruppi");
    
    PresenceSelectListGroupViewController *presenceSelectListGroupViewController = [[PresenceSelectListGroupViewController alloc] init];
        
    /*
    if (@available(iOS 13.0, *)) {
        
        [presenceSelectListGroupViewController setModalPresentationStyle:UIModalPresentationAutomatic];
        
    } else {
        // Fallback on earlier versions
        [presenceSelectListGroupViewController setModalPresentationStyle:UIModalPresentationFullScreen];
    }
    */
    [presenceSelectListGroupViewController setModalPresentationStyle:UIModalPresentationFullScreen];

    
    [self presentViewController:presenceSelectListGroupViewController animated:true completion:nil];
}


- (IBAction)ibaSelezionePresence:(id)sender {
    
    LOGD(@"ibaSelezionePresence");
    
    PresenceSelectListViewController *presenceSelectListViewController = [[PresenceSelectListViewController alloc] init];
    
    presenceSelectListViewController.presenceSelezionata = self.userMe.presence;

    [presenceSelectListViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];

    [presenceSelectListViewController setModalPresentationStyle:UIModalPresentationCustom];

    [self presentViewController:presenceSelectListViewController animated:true completion:nil];
    
}



- (IBAction)onBackPressed:(id)sender {
    
    LOGD(@"onBackPressed");
    
    [PhoneMainView.instance popCurrentView];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //LOGD(@"LOGD arrayUsers.count: %d", self.arrayUsers.count);
    
    if (self.arrayUsers.count > 0) {
        
        self.ibLabelNessunDato.hidden = YES;

        return 1;
        
    }else {
        
        self.ibLabelNessunDato.hidden = NO;
        
        return 0;
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //LOGD(@"LOGD arrayUsers.count: %d", self.arrayUsers.count);
    
    return self.arrayUsers.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"
    
    LOGD(@"LOGD cellForRowAtIndexPath indexPath.row: %d", indexPath.row);
    
    static NSString *CellIdentifier = @"idPresenceTableViewCell";
    
    PresenceTableViewCell *presenceTableViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!presenceTableViewCell) {
        
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PresenceTableViewCell class]) owner:self options:nil];
        
        presenceTableViewCell = (PresenceTableViewCell *)self.ibPresenceTableViewCell;
        
        self.ibPresenceTableViewCell = nil;
    }
    
    PortablePresenceUser *portablePresenceUser = (PortablePresenceUser *)[self.arrayUsers objectAtIndex:indexPath.row];
    //LOGD(@"LOGD portablePresenceUser: %@", portablePresenceUser.name);
    
    
    [presenceTableViewCell.ibImageViewSfontoStatus.layer setBorderWidth: 1.0];
    
    
    presenceTableViewCell.ibLabelIniziali.layer.masksToBounds = YES;
    presenceTableViewCell.ibLabelIniziali.layer.cornerRadius = 22.0;
    
    
    presenceTableViewCell.ibViewSfondoLabelStatus.layer.masksToBounds = YES;
    presenceTableViewCell.ibViewSfondoLabelStatus.layer.cornerRadius = 4.0;
    
    
    
    // --- INIZIALI NOME ---
    NSString *noteUtente = portablePresenceUser.name;
    NSArray *arrayFirstLastStrings = [noteUtente componentsSeparatedByString:@" "];
    
    NSString *nome = [arrayFirstLastStrings objectAtIndex:0];
    char nomeInitialChar = [nome characterAtIndex:0];
    
    //LOGD(@"LOGD nomeInitialChar: %c", nomeInitialChar);
    
    if (arrayFirstLastStrings.count > 1) {
        
        NSString *cognome = [arrayFirstLastStrings objectAtIndex:1];
        
        char cognomeInitialChar = [cognome characterAtIndex:0];
        //LOGD(@"LOGD cognomeInitialChar: %c", cognomeInitialChar);
        
        presenceTableViewCell.ibLabelIniziali.text = [NSString stringWithFormat:@"%c%c", nomeInitialChar, cognomeInitialChar];
        
    }else {
        
        presenceTableViewCell.ibLabelIniziali.text = [NSString stringWithFormat:@"%c", nomeInitialChar];
    }
    // ----------------------
    
    // NOME per esteso
    presenceTableViewCell.ibLabelName.text = noteUtente;
    
    
    [self setUserPresence:presenceTableViewCell withPortablePresenceUser:portablePresenceUser];
    
    
    
    return presenceTableViewCell;
}




- (void)setUserPresence:(PresenceTableViewCell *)presenceTableViewCell withPortablePresenceUser: (PortablePresenceUser *)portablePresenceUser {
    
    LOGD(@"LOGD setMePresence");
    
    NSString *presence = portablePresenceUser.presence;
    LOGD(@"LOGD presence: %@", presence);
    
    if ([presence isEqualToString:kKeyOnline]) {
        // ONLINE
        
        [presenceTableViewCell.ibImageViewSfontoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceOnline"] CGColor]];
        
        presenceTableViewCell.ibViewSfondoLabelStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOnline"];
        
        presenceTableViewCell.ibLabelStatus.text = @"DISPONIBILE";
        
        presenceTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOnline"];
        presenceTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_online"];
        
        
    }else if ([presence isEqualToString:kKeyBusy]) {
        // BUSY
        
        [presenceTableViewCell.ibImageViewSfontoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceBusy"] CGColor]];
        
        presenceTableViewCell.ibViewSfondoLabelStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceBusy"];
        
        presenceTableViewCell.ibLabelStatus.text = @"BUSY";
        
        presenceTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceBusy"];
        presenceTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_busy"];
        
        
    }else if ([presence isEqualToString:kKeyRinging]) {
        // INCOMING
        
        [presenceTableViewCell.ibImageViewSfontoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceIncoming"] CGColor]];
        
        presenceTableViewCell.ibViewSfondoLabelStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceIncoming"];
        
        presenceTableViewCell.ibLabelStatus.text = @"INCOMING";
        
        presenceTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceIncoming"];
        presenceTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_incoming"];
        
        
    }else if ([presence isEqualToString:kKeyOffline]) {
        // OFFLINE
        
        [presenceTableViewCell.ibImageViewSfontoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceOffline"] CGColor]];
        
        presenceTableViewCell.ibViewSfondoLabelStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOffline"];
        
        presenceTableViewCell.ibLabelStatus.text = @"OFFLINE";
        
        presenceTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOffline"];
        presenceTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_offline"];
        
        
    }else if ([presence isEqualToString:kKeyCellphone]) {
        // CELLPHONE
        
        [presenceTableViewCell.ibImageViewSfontoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceCellphone"] CGColor]];
        
        presenceTableViewCell.ibViewSfondoLabelStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCellphone"];
        
        presenceTableViewCell.ibLabelStatus.text = @"CELLULARE";
        
        presenceTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCellphone"];
        presenceTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_cellphone"];
        
        
    }else if ([presence isEqualToString:kKeyVoicemail]) {
        // VOICEMAIL
        
        [presenceTableViewCell.ibImageViewSfontoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceVoicemail"] CGColor]];
        
        presenceTableViewCell.ibViewSfondoLabelStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceVoicemail"];
        
        presenceTableViewCell.ibLabelStatus.text = @"CASELLA VOCALE";
        
        presenceTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceVoicemail"];
        presenceTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_voicemail"];
        
        
    }else if ([presence isEqualToString:kKeyDnd]) {
        // DND
        
        [presenceTableViewCell.ibImageViewSfontoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceDnd"] CGColor]];
        
        presenceTableViewCell.ibViewSfondoLabelStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceDnd"];
        
        presenceTableViewCell.ibLabelStatus.text = @"NON DISTURBARE";
        
        presenceTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceDnd"];
        presenceTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_dnd"];
        
        
    }else if ([presence isEqualToString:kKeyCallforward]) {
        // CALLFORWORD
        
        [presenceTableViewCell.ibImageViewSfontoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceCallforward"] CGColor]];
        
        presenceTableViewCell.ibViewSfondoLabelStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCallforward"];
        
        presenceTableViewCell.ibLabelStatus.text = @"INOLTRO";
        
        presenceTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCallforward"];
        presenceTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_callforward"];
        
        
    }else {
        // DEFAULT
        
        [presenceTableViewCell.ibImageViewSfontoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceOffline"] CGColor]];
        
        presenceTableViewCell.ibViewSfondoLabelStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOffline"];
        
        presenceTableViewCell.ibLabelStatus.text = @"N/D";
        
        presenceTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOffline"];
        presenceTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_offline"];
        
    }
    
}



- (void)setMePresence {
    
    LOGD(@"LOGD setMePresence");
    
    NSString *presence = self.userMe.presence;
    LOGD(@"LOGD presence: %@", presence);
    
    if ([presence isEqualToString:kKeyOnline]) {
        // ONLINE
        
        [self.ibButtonSelezionePresence setTitle:@"DISPONIBILE" forState:UIControlStateNormal];
        
        self.ibButtonSelezionePresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOnline"];
        
        [self.ibButtonSelezionePresence setImage:[UIImage imageNamed:@"icn_cerchio_online"] forState:UIControlStateNormal];
        
    }else if ([presence isEqualToString:kKeyBusy]) {
        // BUSY
        
        [self.ibButtonSelezionePresence setTitle:@"BUSY" forState:UIControlStateNormal];
        
        self.ibButtonSelezionePresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceBusy"];
        
        [self.ibButtonSelezionePresence setImage:[UIImage imageNamed:@"icn_cerchio_busy"] forState:UIControlStateNormal];
        
    }else if ([presence isEqualToString:kKeyRinging]) {
        // INCOMING
        
        [self.ibButtonSelezionePresence setTitle:@"INCOMING" forState:UIControlStateNormal];
        
        self.ibButtonSelezionePresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceIncoming"];
        
        [self.ibButtonSelezionePresence setImage:[UIImage imageNamed:@"icn_cerchio_incoming"] forState:UIControlStateNormal];
        
    }else if ([presence isEqualToString:kKeyOffline]) {
        // OFFLINE
        
        [self.ibButtonSelezionePresence setTitle:@"OFFLINE" forState:UIControlStateNormal];
        
        self.ibButtonSelezionePresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOffline"];
        
        [self.ibButtonSelezionePresence setImage:[UIImage imageNamed:@"icn_cerchio_offline"] forState:UIControlStateNormal];
        
    }else if ([presence isEqualToString:kKeyCellphone]) {
        // CELLPHONE
        
        [self.ibButtonSelezionePresence setTitle:@"CELLULARE" forState:UIControlStateNormal];
        
        self.ibButtonSelezionePresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCellphone"];
        
        [self.ibButtonSelezionePresence setImage:[UIImage imageNamed:@"icn_cerchio_cellphone"] forState:UIControlStateNormal];
        
    }else if ([presence isEqualToString:kKeyVoicemail]) {
        // VOICEMAIL
        
        [self.ibButtonSelezionePresence setTitle:@"CASELLA VOCALE" forState:UIControlStateNormal];
        
        self.ibButtonSelezionePresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceVoicemail"];
        
        [self.ibButtonSelezionePresence setImage:[UIImage imageNamed:@"icn_cerchio_voicemail"] forState:UIControlStateNormal];
        
    }else if ([presence isEqualToString:kKeyDnd]) {
        // DND
        
        [self.ibButtonSelezionePresence setTitle:@"NON DISTURBARE" forState:UIControlStateNormal];
        
        self.ibButtonSelezionePresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceDnd"];
        
        [self.ibButtonSelezionePresence setImage:[UIImage imageNamed:@"icn_cerchio_dnd"] forState:UIControlStateNormal];
        
    }else if ([presence isEqualToString:kKeyCallforward]) {
        // CALLFORWORD
        
        [self.ibButtonSelezionePresence setTitle:@"INOLTRO" forState:UIControlStateNormal];
        
        self.ibButtonSelezionePresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCallforward"];
        
        [self.ibButtonSelezionePresence setImage:[UIImage imageNamed:@"icn_cerchio_callforward"] forState:UIControlStateNormal];
        
    }else {
        // DEFAULT
        
        [self.ibButtonSelezionePresence setTitle:@"ND" forState:UIControlStateNormal];
        
        self.ibButtonSelezionePresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOffline"];
        
        [self.ibButtonSelezionePresence setImage:[UIImage imageNamed:@"icn_cerchio_offline"] forState:UIControlStateNormal];
    }
    
}


#pragma mark -
#pragma mark === downloadPresence ===
#pragma mark -

- (void)downloadPresence {
    
    LOGD(@"downloadPresence");
    
    NethCTIAPI *api = [NethCTIAPI sharedInstance];
    
    // Download info utente
    [api getUserMeWithSuccessHandler:^(PortableNethUser *portableNethUser) {
        
        printf("portableNethUser.mainextension: %@", portableNethUser.mainExtension);
        
        LOGD(@"portableNethUser.recallOnBusy: %@", portableNethUser.recallOnBusy);
        
        LOGD(@"portableNethUser.permissionsSpy: %@", portableNethUser.permissionsSpy ? @"Yes" : @"No");
        
        LOGD(@"portableNethUser.permissionsIntrude: %@", portableNethUser.permissionsIntrude ? @"Yes" : @"No");
        
        LOGD(@"portableNethUser.permissionsRecording: %@", portableNethUser.permissionsRecording ? @"Yes" : @"No");
        
        LOGD(@"portableNethUser.permissionsPickup: %@", portableNethUser.permissionsPickup ? @"Yes" : @"No");
        
        //printf("portableNethUser.mainextension: %@", portableNethUser.arrayPermissionsIdGroups);
        LOGD(@"portableNethUser.arrayPermissionsIdGroups: %@", portableNethUser.arrayPermissionsIdGroups);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.userMe = portableNethUser;
            
            [self setMePresence];
        });
        
        
        
        
        // Download GRUPPI
        [api getGroupsWithSuccessHandler:^(NSArray *arrayGroups) {
            
            //LOGD(@"arrayGroups.count: %d", arrayGroups.count)
            
            
            // Download utenti
            [api getUserAllWithSuccessHandler:^(NSArray *arrayUsers) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //LOGD(@"arrayUsers.firstObject: %@", arrayUsers.firstObject);
                    
                    //PortablePresenceUser *firstPortablePresenceUser = arrayUsers.firstObject;
                    //LOGD(@"firstPortablePresenceUser.presence: %@", firstPortablePresenceUser.presence);
                    
                    //LOGD(@"firstPortablePresenceUser.mainExtension: %@", firstPortablePresenceUser.mainExtension);
                    
                    
                    NSMutableArray *arrayGruppiVisibili = [NSMutableArray new];
                    
                    for (NSString *idGroupEnableCorrente in portableNethUser.arrayPermissionsIdGroups) {
                        
                        //LOGD(@"idGroupEnableCorrente: %@", idGroupEnableCorrente);
                        
                        for (PortableGroup *groupCorrente in arrayGroups) {
                            
                            if (idGroupEnableCorrente == groupCorrente.id_group) {
                                
                                LOGD(@"AGGIUNTO id_group: %@", groupCorrente.id_group);
                                
                                [arrayGruppiVisibili addObject:groupCorrente];
                            }
                        }
                    }
                    
                    LOGD(@"arrayGruppiVisibili.count: %d", arrayGruppiVisibili.count);
                    
                    // --- Selezione default primo gruppo ---
                    PortableGroup *groupVisibileSelezionato = arrayGruppiVisibili.firstObject;
                    //LOGD(@"groupVisibileSelezionato: %@", groupVisibileSelezionato);
                    
                    self.ibLabelGruppi.text = [[NSString stringWithFormat:@"GRUPPI (%@)", groupVisibileSelezionato.name] uppercaseString];
                    
                    LOGD(@"groupVisibileSelezionato.users: %@", groupVisibileSelezionato.users);
                    // --------------------------------------
                    
                    
                    LOGD(@"arrayUsers.count: %d", arrayUsers.count);
                    
                    NSMutableArray *arrayUsersVisibili = [NSMutableArray new];
                    
                    
                    for (PortablePresenceUser *userCorrente in arrayUsers) {
                        
                        //LOGD(@"userCorrente.username: %@", userCorrente.username);
                        //LOGD(@"userCorrente.name: %@", userCorrente.name);
                        
                        for (NSString *keyUsernameCorrente in groupVisibileSelezionato.users) {
                            
                            if (userCorrente.username == keyUsernameCorrente) {
                                
                                LOGD(@"AGGIUNTO userCorrente.username: %@", userCorrente.username);
                                
                                [arrayUsersVisibili addObject:userCorrente];
                            }
                        }
                    }
                    
                    LOGD(@"arrayUsersVisibili.count: %d", arrayUsersVisibili.count);
                    
                    
                    
                    
                    
                    // Nascondo la ViewCaricamento
                    [self.HUD hideAnimated:YES];
                    
                    [self.refreshControl endRefreshing];
                    
                    PortablePresenceUser *firstPortablePresenceUser = (PortablePresenceUser *)arrayUsersVisibili.firstObject;
                    LOGD(@"firstPortablePresenceUser: %@", firstPortablePresenceUser);
                    
                    self.arrayUsers = arrayUsersVisibili;
                    
                    [self loadData];
                    
                });
                
                
                
                
            } errorHandler:^(NSInteger code, NSString * _Nullable string) {
                
                /*
                 dispatch_async(dispatch_get_main_queue(), ^{
                 
                 // Nascondo la ViewCaricamento
                 [self.HUD hideAnimated:YES];
                 
                 [self.refreshControl endRefreshing];
                 
                 // Get me error handling.
                 LOGE(@"API_ERROR: %@", string);
                 
                 [self performSelectorOnMainThread:@selector(showErrorController:)
                 withObject:string
                 waitUntilDone:YES];
                 });
                 */
            }];
            
        } errorHandler:^(NSInteger code, NSString * _Nullable string) {
            
            /*
             dispatch_async(dispatch_get_main_queue(), ^{
             
             // Nascondo la ViewCaricamento
             [self.HUD hideAnimated:YES];
             
             [self.refreshControl endRefreshing];
             
             // Get me error handling.
             LOGE(@"API_ERROR: %@", string);
             
             [self performSelectorOnMainThread:@selector(showErrorController:)
             withObject:string
             waitUntilDone:YES];
             });
             */
            
        }];
        
        
    } errorHandler:^(NSInteger code, NSString * _Nullable string) {
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //NSLog(@"API_ERROR: %@, code: %li", string, (long)code);
            
            // Nascondo la ViewCaricamento
            [self.HUD hideAnimated:YES];
            
            [self.refreshControl endRefreshing];
            
            /*
             // Get me error handling.
             LOGE(@"API_ERROR: %@", string);
             
             [self performSelectorOnMainThread:@selector(showErrorController:)
             withObject:string
             waitUntilDone:YES];
             */
        });
        
    }];
    
}


@end
