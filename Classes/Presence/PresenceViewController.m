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
@property (retain, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSMutableArray *arrayGruppiVisibili;

@end


@implementation PresenceViewController

@synthesize topBar;
@synthesize arrayUsers;
@synthesize userMe;
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
    
    LOGD(@"viewDidAppear");
    
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

    self.id_groupSelezionato = @"";
    
    /*
    if(![NethCTIAPI.sharedInstance isUserAuthenticated]) {
        // This method should send more error codes than one.
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:401], @"code", nil];
        
        [NSNotificationCenter.defaultCenter postNotificationName:kNethesisPhonebookPermissionRejection
                                                          object:self
                                                        userInfo:dict];

    }else {
        */
        [self.HUD showAnimated:YES];

        [self downloadPresence];
        
        
        // --- AGGIORNAMENTO DATI OGNI 10 SECONDI ---
        self.timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(downloadPresence) userInfo:nil repeats:YES];
        // ------------------------------------------
    //}
    
    

    
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
    
    NSLog(@"viewDidAppear");
    
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    NSLog(@"viewWillDisappear");
    
    // --- ATTENZIONE: forza il viewDidLoad! ---
    self.view = NULL;
    // -----------------------------------------
    
    [self.refreshControl endRefreshing];
    
    self.timer = nil;
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

- (IBAction)ibaVisualizzaAzioni:(UIButton *)sender {
    
    //NSLog(@"ibaVisualizzaAzioni sender.tag: %ld", (long)sender.tag);

    PortablePresenceUser *portablePresenceUserSelezionato = (PortablePresenceUser *)[self.arrayUsers objectAtIndex:sender.tag];
    //NSLog(@"portablePresenceUserSelezionato.name: %@", portablePresenceUserSelezionato.name);
    
    PresenceActionViewController *presenceActionViewController = [[PresenceActionViewController alloc] init];
    
    presenceActionViewController.portablePresenceUser = portablePresenceUserSelezionato;
    presenceActionViewController.portableNethUserMe = self.userMe;
    
    [presenceActionViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];

    [presenceActionViewController setModalPresentationStyle:UIModalPresentationCustom];

    [self presentViewController:presenceActionViewController animated:true completion:nil];
    
}


- (IBAction)ibaVisualizzaPreferiti:(id)sender {
    
    NSLog(@"ibaVisualizzaPreferiti");
    
}


- (IBAction)ibaVisualizzaGruppi:(id)sender {
    
    NSLog(@"ibaVisualizzaGruppi");
    
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
}


- (IBAction)ibaSelezionePresence:(id)sender {
    
    NSLog(@"ibaSelezionePresence");
    
    PresenceSelectListViewController *presenceSelectListViewController = [[PresenceSelectListViewController alloc] init];
    
    presenceSelectListViewController.presenceSelezionata = self.userMe.mainPresence;
    presenceSelectListViewController.presenceSelectListDelegate = self;
    
    [presenceSelectListViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];

    [presenceSelectListViewController setModalPresentationStyle:UIModalPresentationCustom];

    [self presentViewController:presenceSelectListViewController animated:true completion:nil];
    
}



- (IBAction)onBackPressed:(id)sender {
    
    NSLog(@"onBackPressed");
    
    [PhoneMainView.instance popCurrentView];
}




#pragma mark -
#pragma mark === Table view data source ===
#pragma mark -

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
    
    presenceTableViewCell.ibButtonVisualizzaAzioni.tag = indexPath.row;
    
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



#pragma mark -
#pragma mark === Table view delegate ===
#pragma mark -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"didSelectRowAtIndexPath: %ld", (long)indexPath.row);

    /*
    PortablePresenceUser *portablePresenceUserSelezionato = (PortablePresenceUser *)[self.arrayUsers objectAtIndex:indexPath.row];

    PresenceActionViewController *presenceActionViewController = [[PresenceActionViewController alloc] init];
    
    presenceActionViewController.portablePresenceUser = portablePresenceUserSelezionato;
    presenceActionViewController.portableNethUserMe = self.userMe;
    
    [presenceActionViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];

    [presenceActionViewController setModalPresentationStyle:UIModalPresentationCustom];

    [self presentViewController:presenceActionViewController animated:true completion:nil];
    
    */
}


/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}
*/



- (void)setUserPresence:(PresenceTableViewCell *)presenceTableViewCell withPortablePresenceUser: (PortablePresenceUser *)portablePresenceUser {
    
    LOGD(@"LOGD setMePresence");
    
    NSString *presence = portablePresenceUser.mainPresence;
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
    
    NSLog(@"setMePresence");
    
    NSString *presence = self.userMe.mainPresence;
    NSLog(@"presence: %@", presence);
    
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
    
    NSLog(@"downloadPresence");
    
    NethCTIAPI *api = [NethCTIAPI sharedInstance];
    
    // Download INFO UTENTE
    [api getUserMeWithSuccessHandler:^(PortableNethUser *portableNethUser) {
        
        NSLog(@"portableNethUser.mainPresence: %@", portableNethUser.mainPresence);

        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.userMe = portableNethUser;
            
            [self setMePresence];
        });
                
        
        // Download GRUPPI
        [api getGroupsWithSuccessHandler:^(NSArray *arrayGroups) {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.arrayGruppiVisibili = [NSMutableArray new];
                
                for (NSString *idGroupEnableCorrente in self.userMe.arrayPermissionsIdGroups) {
                    
                    //NSLog(@"idGroupEnableCorrente: %@", idGroupEnableCorrente);
                    
                    for (PortableGroup *groupCorrente in arrayGroups) {
                        
                        if ([idGroupEnableCorrente isEqualToString:groupCorrente.id_group]) {
                            
                            //NSLog(@"AGGIUNTO id_group: %@", groupCorrente.id_group);
                            
                            [self.arrayGruppiVisibili addObject:groupCorrente];
                        }
                    }
                }
                
            });

            
            
            // Download UTENTI
            [api getUserAllWithSuccessHandler:^(NSArray *arrayUsers) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                                                            
                    //NSLog(@"id_groupSelezionato: %@", self.id_groupSelezionato);
                    //NSLog(@"self.arrayGruppiVisibili: %@", self.arrayGruppiVisibili);

                    PortableGroup *groupVisibileSelezionato = nil;
                    
                    if ([self.id_groupSelezionato isEqualToString:@""]) {
                        
                        // --- Selezione default primo gruppo ---
                        groupVisibileSelezionato = self.arrayGruppiVisibili.firstObject;
                        
                        self.id_groupSelezionato = groupVisibileSelezionato.id_group;
                        // --------------------------------------
                                                
                    }else {
                        
                        for (PortableGroup *gruppoVisibileCorrente in self.arrayGruppiVisibili) {
                            
                            if ([self.id_groupSelezionato isEqualToString:gruppoVisibileCorrente.id_group]) {
                                
                                //NSLog(@"gruppoVisibileCorrente.id_group: %@", gruppoVisibileCorrente.id_group);
                                
                                groupVisibileSelezionato = gruppoVisibileCorrente;
                            }
                        }
                    }
                    
                    //NSLog(@"groupVisibileSelezionato.users: %@", groupVisibileSelezionato.users);
                    //NSLog(@"groupVisibileSelezionato.count: %lu", (unsigned long)groupVisibileSelezionato.users.count);
                    

                    self.ibLabelGruppi.text = [[NSString stringWithFormat:@"GRUPPI (%@)", groupVisibileSelezionato.name] uppercaseString];
                    
                    
                    NSMutableArray *arrayUsersVisibili = [NSMutableArray new];
                    
                    for (NSString *keyUsernameCorrente in groupVisibileSelezionato.users) {
                        
                        //NSLog(@"CERCO keyUsernameCorrente: %@", keyUsernameCorrente);

                        for (PortablePresenceUser *userFromAllCorrente in arrayUsers) {
                            
                            //NSLog(@"userFromAllCorrente.username: %@", userFromAllCorrente.username);

                            if ([userFromAllCorrente.username isEqualToString:keyUsernameCorrente]) {
                                
                                //NSLog(@"AGGIUNTO userCorrente.username: %@", userFromAllCorrente.username);
                                
                                [arrayUsersVisibili addObject:userFromAllCorrente];
                            }
                        }
                    }
                    
                    
                    //NSLog(@"arrayUsersVisibili.count: %lu", (unsigned long)arrayUsersVisibili.count);

                    self.arrayUsers = arrayUsersVisibili;
                    
                    [self loadData];
                    
                    
                    // Nascondo la ViewCaricamento
                    [self.HUD hideAnimated:YES];
                    
                    [self.refreshControl endRefreshing];
                });
                
                
                
                
            } errorHandler:^(NSInteger code, NSString * _Nullable string) {
                
                NSLog(@"API_ERROR code: %ld, string: %@", (long)code, string);

                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // Nascondo la ViewCaricamento
                    [self.HUD hideAnimated:YES];
                    
                    [self.refreshControl endRefreshing];
                    
                    [self showAlertError:code withError:string];
                    
                });

            }];
            
        } errorHandler:^(NSInteger code, NSString * _Nullable string) {
            
            NSLog(@"API_ERROR code: %ld, string: %@", (long)code, string);

            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Nascondo la ViewCaricamento
                [self.HUD hideAnimated:YES];
                
                [self.refreshControl endRefreshing];
                
                [self showAlertError:code withError:string];
                
            });
                         
        }];
        
    } errorHandler:^(NSInteger code, NSString * _Nullable string) {
        
        NSLog(@"API_ERROR code: %ld, string: %@", (long)code, string);

        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Nascondo la ViewCaricamento
            [self.HUD hideAnimated:YES];
            
            [self.refreshControl endRefreshing];
            
            [self showAlertError:code withError:string];
                        
        });
        
    }];
    
}



#pragma mark -
#pragma mark === PresenceSselectListeViewController delegate ===
#pragma mark -

// delegate custom
- (void)reloadPresence {
    
    NSLog(@"reloadPresence");
    
    [self.HUD showAnimated:YES];

    
    [self downloadPresence];

    
}


#pragma mark -
#pragma mark === PresenceSselectListeViewController delegate ===
#pragma mark -

// delegate custom
- (void)reloadPresenceWithGroup:(NSString * _Nullable) id_group {
    
    NSLog(@"id_group: %@", id_group);
    
    self.id_groupSelezionato = id_group;
    
    
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




@end
