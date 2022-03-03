//
//  PresenceActionViewController.m
//  NethCTI
//
//  Created by Democom S.r.l. on 14/02/22.
//

#import "PresenceActionViewController.h"
#import "PresenceActionCollectionViewCell.h"
//#import "PhoneMainView.h"
#import "Utils.h"
#import "MBProgressHUD.h"



@interface PresenceActionViewController ()

@property (strong, nonatomic) MBProgressHUD *HUD;
@property (assign) BOOL isPreferito;

@end



@implementation PresenceActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //NSLog(@"viewDidLoad - PresenceActionViewController");

    //NSLog(@"portableNethUserMe.mainextension: %@", self.portableNethUserMe.mainExtension);
    
    //NSLog(@"portablePresenceUser.mainextension: %@", self.presenceUserObjcSelezionato.mainExtension);
    //NSLog(@"portablePresenceUser.mainPresence: %@", self.presenceUserObjcSelezionato.mainPresence);

    

    // --- MBProgressHUD ---
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:self.HUD];
    // ------------------------
    
    
    UINib *nibPresenceActionCollectionViewCell = [UINib nibWithNibName:NSStringFromClass([PresenceActionCollectionViewCell class]) bundle:nil];
    [self.ibCollectionView registerNib:nibPresenceActionCollectionViewCell forCellWithReuseIdentifier:@"idPresenceActionCollectionViewCell"];
    
    
    
    [self setPreferito];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //NSLog(@"viewWillAppear - PresenceActionViewController");
    
    [self setPresenceUser];
}


- (void)viewDidAppear:(BOOL)animated {
    
    //NSLog(@"viewDidAppear - PresenceActionViewController");
    
    [self setPresenceUser];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (IBAction)ibaEseguiAzione:(UIButton *)sender {
    
    //NSLog(@"ibaEseguiAzione sender: %ld", (long)sender.tag);

    switch (sender.tag) {
            
        case 0:
            // CHIAMA
            
            NSLog(@"CHIAMA");
            
            [self azioneChiama];
            
            break;
            
        case 1:
            // CHIUDI
            
            NSLog(@"CHIUDI");

            [self azioneChiudi];

            break;
            
        case 2:
            // REGISTRA
            
            NSLog(@"REGISTRA");

            [self azioneRegistra];

            break;
            
        case 3:
            // INTROMETTITI
            
            NSLog(@"INTROMETTITI");

            [self azioneIntromettiti];
            
            break;
            
        case 4:
            // PRENOTA
            
            NSLog(@"PRENOTA");

            [self azionePrenota];
                
                
            break;
            
        case 5:
            // PICKUP
            
            NSLog(@"PICKUP");

            [self azionePickup];
            
            break;
            
        case 6:
            // SPIA
            
            NSLog(@"SPIA");

            [self azioneSpia];
            
            break;
            
    }
}




- (IBAction)ibaSetPreferito:(id)sender {
    
    //NSLog(@"ibaSetPreferito");
    
    if (self.isPreferito) {
                
        [self rimuoviPreferito];
        
    }else {
        
        [self aggiungiPreferito];
    }
}


- (IBAction)ibaChiudi:(id)sender {
    
    //NSLog(@"ibaChiudi");
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [self.presenceActionDelegate reloadPresenceFromAction];
    }];
}




- (void)setPresenceUser {
    
    //NSLog(@"portablePresenceUser: %@", self.presenceUserObjcSelezionato);

    self.ibLabelNome.text = self.presenceUserObjcSelezionato.name;
    
    
    // --- INIZIALI NOME ---
    NSString *noteUtente = self.presenceUserObjcSelezionato.name;
    NSArray *arrayFirstLastStrings = [noteUtente componentsSeparatedByString:@" "];
    
    NSString *nome = [arrayFirstLastStrings objectAtIndex:0];
    char nomeInitialChar = [nome characterAtIndex:0];
    
    //LOGD(@"LOGD nomeInitialChar: %c", nomeInitialChar);
    
    if (arrayFirstLastStrings.count > 1) {
        
        NSString *cognome = [arrayFirstLastStrings objectAtIndex:1];
        
        char cognomeInitialChar = [cognome characterAtIndex:0];
        //LOGD(@"LOGD cognomeInitialChar: %c", cognomeInitialChar);
        
        self.ibLabelIniziali.text = [NSString stringWithFormat:@"%c%c", nomeInitialChar, cognomeInitialChar];
        
    }else {
        
        self.ibLabelIniziali.text = [NSString stringWithFormat:@"%c", nomeInitialChar];
    }
    // ----------------------
        
    
    self.ibLabelStatusPresence.text = self.presenceUserObjcSelezionato.mainPresence;
    
    self.ibLabelMainExtension.text = self.presenceUserObjcSelezionato.mainExtension;
    
    
    
    // bordo
    [self.ibImageViewBordoStatus.layer setBorderWidth: 1.0];

    
    NSString *presence = self.presenceUserObjcSelezionato.mainPresence;
    
    if ([presence isEqualToString:kKeyOnline]) {
        // ONLINE
        
        // bordo
        [self.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceOnline"] CGColor]];
        
        // status
        self.ibLabelStatusPresence.text = NSLocalizedString(@"DISPONIBILE", nil);
        self.ibViewPresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOnline"];
        
        // icona
        self.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOnline"];
        self.ibImageViewStatus.image = [UIImage imageNamed:@"icn_online"];
        
    }else if ([presence isEqualToString:kKeyBusy]) {
        // BUSY
        
        // bordo
        [self.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceBusy"] CGColor]];
        
        self.ibLabelStatusPresence.text = NSLocalizedString(@"OCCUPATO", nil);
        self.ibViewPresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceBusy"];

        self.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceBusy"];
        self.ibImageViewStatus.image = [UIImage imageNamed:@"icn_busy"];
        
        // TODO: fare la get extensions per ottenere lo status della registrazione
                
        
    }else if ([presence isEqualToString:kKeyRinging]) {
        // INCOMING
        
        // bordo
        [self.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceIncoming"] CGColor]];
        
        self.ibLabelStatusPresence.text = NSLocalizedString(@"IN ENTRATA", nil);
        self.ibViewPresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceIncoming"];

        self.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceIncoming"];
        self.ibImageViewStatus.image = [UIImage imageNamed:@"icn_incoming"];
        
    }else if ([presence isEqualToString:kKeyOffline]) {
        // OFFLINE
        
        // bordo
        [self.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceOffline"] CGColor]];
        
        self.ibLabelStatusPresence.text = NSLocalizedString(@"NON DISPONIBILE", nil);
        self.ibViewPresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOffline"];

        self.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOffline"];
        self.ibImageViewStatus.image = [UIImage imageNamed:@"icn_offline"];
        
        
    }else if ([presence isEqualToString:kKeyCellphone]) {
        // CELLPHONE
        
        // bordo
        [self.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceCellphone"] CGColor]];
        
        self.ibLabelStatusPresence.text = NSLocalizedString(@"CELLULARE", nil);
        self.ibViewPresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCellphone"];

        self.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCellphone"];
        self.ibImageViewStatus.image = [UIImage imageNamed:@"icn_cellphone"];
        
    }else if ([presence isEqualToString:kKeyVoicemail]) {
        // VOICEMAIL
        
        // bordo
        [self.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceVoicemail"] CGColor]];
        
        self.ibLabelStatusPresence.text = NSLocalizedString(@"CASELLA VOCALE", nil);
        self.ibViewPresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceVoicemail"];

        self.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceVoicemail"];
        self.ibImageViewStatus.image = [UIImage imageNamed:@"icn_voicemail"];
        
        
    }else if ([presence isEqualToString:kKeyDnd]) {
        // DND
        
        // bordo
        [self.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceDnd"] CGColor]];
        
        self.ibLabelStatusPresence.text = NSLocalizedString(@"NON DISTURBARE", nil);
        self.ibViewPresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceDnd"];

        self.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceDnd"];
        self.ibImageViewStatus.image = [UIImage imageNamed:@"icn_dnd"];
        
    }else if ([presence isEqualToString:kKeyCallforward]) {
        // CALLFORWORD
        
        // bordo
        [self.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceCallforward"] CGColor]];
        
        self.ibLabelStatusPresence.text = NSLocalizedString(@"INOLTRO", nil);
        self.ibViewPresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCallforward"];

        self.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCallforward"];
        self.ibImageViewStatus.image = [UIImage imageNamed:@"icn_callforward"];
        
    }else {
        // Default
        
        // bordo
        [self.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceOffline"] CGColor]];
        
        self.ibLabelStatusPresence.text = NSLocalizedString(@"N/D", nil);
        self.ibViewPresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOffline"];

        self.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOffline"];
        self.ibImageViewStatus.image = [UIImage imageNamed:@"icn_offline"];
    }
    
}


- (void)setPreferito {

    //NSLog(@"setPreferito username: %@", self.presenceUserObjcSelezionato.username);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //NSLog(@"defaults_keys: %@", [[defaults dictionaryRepresentation] allKeys]);
    
    if ([[[defaults dictionaryRepresentation] allKeys] containsObject:kKeyPreferiti]){
        
        //NSLog(@"key preferiti_username_nethesis found");
        
        if ([defaults arrayForKey:kKeyPreferiti] != nil) {
            
            // getting an NSArray
            NSArray *arrayUsersPreferiti = [[NSArray alloc] initWithArray:[defaults arrayForKey:kKeyPreferiti]];
            
            if (arrayUsersPreferiti.count > 0) {
                
                for (NSString *usernameCorrente in arrayUsersPreferiti) {
                                        
                    //NSLog(@"usernameCorrente: %@", usernameCorrente);
                    
                    if ([self.presenceUserObjcSelezionato.username isEqualToString:usernameCorrente]) {
                        
                        self.isPreferito = YES;
                    }
                }
                
            }else {
                
                NSLog(@"Nessun preferito salvato");
                
                self.isPreferito = NO;
            }
            
        }else {
            
            NSLog(@"Nessun preferito salvato");
            
            self.isPreferito = NO;
        }
        
    }else {
        
        NSLog(@"key preferiti_username_nethesis NOT found!");
        
        self.isPreferito = NO;
    }
    
    
    if (self.isPreferito) {
        
        [self.ibButtonPreferito setImage:[UIImage imageNamed:@"icn_preferito_selezionato"] forState:UIControlStateNormal];

    }else {
        // NO
        
        [self.ibButtonPreferito setImage:[UIImage imageNamed:@"icn_preferito"] forState:UIControlStateNormal];
    }
}



- (void)aggiungiPreferito {

    //NSLog(@"aggiungiPreferito");

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //NSLog(@"defaults_keys: %@", [[defaults dictionaryRepresentation] allKeys]);
    
    if ([[[defaults dictionaryRepresentation] allKeys] containsObject:kKeyPreferiti]) {
                    
        if ([defaults arrayForKey:kKeyPreferiti] != nil) {
            
            // getting an NSArray
            NSMutableArray *arrayUsersPreferiti = [[NSMutableArray alloc] initWithArray:[defaults arrayForKey:kKeyPreferiti]];
            
            BOOL isGiaPresente = NO;
            
            if (arrayUsersPreferiti.count > 0) {
                
                for (NSString *usernameCorrente in arrayUsersPreferiti) {
                                        
                    //NSLog(@"usernameCorrente: %@", usernameCorrente);
                    
                    if ([self.presenceUserObjcSelezionato.username isEqualToString:usernameCorrente]) {
                        
                        NSLog(@"username già presente!!!");

                        isGiaPresente = YES;
                    }
                }
            }
            
            if (NO == isGiaPresente) {
                // aggiungo username
                                    
                [arrayUsersPreferiti addObject:self.presenceUserObjcSelezionato.username];
                
                [defaults setObject:arrayUsersPreferiti forKey:kKeyPreferiti];
                [defaults synchronize];
                
                [self.ibButtonPreferito setImage:[UIImage imageNamed:@"icn_preferito_selezionato"] forState:UIControlStateNormal];

                self.isPreferito = YES;
            }
            
        }else {
            
            NSLog(@"Nessun preferito salvato: array VUOTO!");
            
            NSMutableArray *nuovoArrayPreferiti = [NSMutableArray new];
            
            [nuovoArrayPreferiti addObject:self.presenceUserObjcSelezionato.username];
            
            [defaults setObject:nuovoArrayPreferiti forKey:kKeyPreferiti];
            [defaults synchronize];
            
            
            [self.ibButtonPreferito setImage:[UIImage imageNamed:@"icn_preferito_selezionato"] forState:UIControlStateNormal];

            self.isPreferito = YES;
        }
        
    }else {
        
        NSLog(@"key preferiti_username_nethesis NOT found!");
        
        NSMutableArray *nuovoArrayPreferiti = [NSMutableArray new];
        
        [nuovoArrayPreferiti addObject:self.presenceUserObjcSelezionato.username];
        
        [defaults setObject:nuovoArrayPreferiti forKey:kKeyPreferiti];
        [defaults synchronize];
        
        
        [self.ibButtonPreferito setImage:[UIImage imageNamed:@"icn_preferito_selezionato"] forState:UIControlStateNormal];

        self.isPreferito = YES;
    }
}


- (void)rimuoviPreferito {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //NSLog(@"defaults_keys: %@", [[defaults dictionaryRepresentation] allKeys]);
    
    if ([[[defaults dictionaryRepresentation] allKeys] containsObject:kKeyPreferiti]) {
                    
        if ([defaults arrayForKey:kKeyPreferiti] != nil) {
            
            // getting an NSArray
            NSMutableArray *arrayUsersPreferiti = [[NSMutableArray alloc] initWithArray:[defaults arrayForKey:kKeyPreferiti]];
            
            //NSLog(@"arrayUsersPreferiti.count: %lu", (unsigned long)arrayUsersPreferiti.count);
            if (arrayUsersPreferiti.count > 0) {
                
                for (int i = 0; i < arrayUsersPreferiti.count; i++) {

                    NSString *usernameCorrente = [arrayUsersPreferiti objectAtIndex:i];
                    //NSLog(@"usernameCorrente: %@", usernameCorrente);
                    
                    if ([self.presenceUserObjcSelezionato.username isEqualToString:usernameCorrente]) {
                        
                        [arrayUsersPreferiti removeObjectAtIndex:i];
                        
                        //NSLog(@"arrayUsersPreferiti.count: %lu", (unsigned long)arrayUsersPreferiti.count);

                        [defaults setObject:arrayUsersPreferiti forKey:kKeyPreferiti];
                        [defaults synchronize];
                        
                        
                        self.isPreferito = NO;

                        [self.ibButtonPreferito setImage:[UIImage imageNamed:@"icn_preferito"] forState:UIControlStateNormal];
                        
                        break;
                    }
                }
                
            }else {
                
                NSLog(@"Nessun preferito salvato");
            }
            
        }else {
            
            NSLog(@"Nessun preferito salvato");
        }
        
    }else {
        
        NSLog(@"key preferiti_username_nethesis NOT found!");
    }
}



#pragma mark -
#pragma mark === UICollectionViewDataSource ===
#pragma mark -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 7;
}




- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PresenceActionCollectionViewCell *presenceActionCollectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"idPresenceActionCollectionViewCell" forIndexPath:indexPath];
    

    presenceActionCollectionViewCell.ibButtonAzione.tag = indexPath.row;

    switch (indexPath.row) {
            
        case 0:
            // CHIAMA
            
            presenceActionCollectionViewCell.ibLabelNomeAzione.text = NSLocalizedString(@"CHIAMA", nil);

            [presenceActionCollectionViewCell.ibButtonAzione setImage:[UIImage imageNamed:@"icn_chiama_on"] forState:UIControlStateNormal];
            [presenceActionCollectionViewCell.ibButtonAzione setImage:[UIImage imageNamed:@"icn_chiama_off"] forState:UIControlStateDisabled];
            
            
            if ([self.presenceUserObjcSelezionato.mainPresence isEqualToString:kKeyOnline] ||
                [self.presenceUserObjcSelezionato.mainPresence isEqualToString:kKeyCellphone] ||
                [self.presenceUserObjcSelezionato.mainPresence isEqualToString:kKeyVoicemail] ||
                [self.presenceUserObjcSelezionato.mainPresence isEqualToString:kKeyCallforward]) {
                
                presenceActionCollectionViewCell.ibButtonAzione.enabled = YES;
                presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = [UIColor colorNamed:@"ColorTextBlack"];

            }else {
                
                presenceActionCollectionViewCell.ibButtonAzione.enabled = NO;
                presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = [UIColor colorNamed: @"ColorTextDisabled"];

            }
            
            
            break;
            
        case 1:
            // CHIUDI
            
            presenceActionCollectionViewCell.ibLabelNomeAzione.text = NSLocalizedString(@"CHIUDI", nil);

            [presenceActionCollectionViewCell.ibButtonAzione setImage:[UIImage imageNamed:@"icn_chiudi_on"] forState:UIControlStateNormal];

            [presenceActionCollectionViewCell.ibButtonAzione setImage:[UIImage imageNamed:@"icn_chiudi_off"] forState:UIControlStateDisabled];
            
            //NSLog(@"portableNethUser.permissionsRecording: %@", self.portableNethUserMe.permissionsHangup ? @"Yes" : @"No");

            if (self.portableNethUserMe.permissionsHangup != false) {
                                
                if ([self.presenceUserObjcSelezionato.mainPresence isEqualToString:kKeyBusy] ||
                    [self.presenceUserObjcSelezionato.mainPresence isEqualToString:kKeyRinging]) {
                    
                    presenceActionCollectionViewCell.ibButtonAzione.enabled = YES;
                    presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = [UIColor colorNamed:@"ColorTextBlack"];

                }else {
                    
                    presenceActionCollectionViewCell.ibButtonAzione.enabled = NO;
                    presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = [UIColor colorNamed: @"ColorTextDisabled"];

                }
                
            }else {
                

                presenceActionCollectionViewCell.ibButtonAzione.enabled = NO;
                presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = [UIColor colorNamed: @"ColorTextDisabled"];

                
            }
            
            break;
            
        case 2:
            // REGISTRA
            
            presenceActionCollectionViewCell.ibLabelNomeAzione.text = NSLocalizedString(@"REGISTRA", nil);

            [presenceActionCollectionViewCell.ibButtonAzione setImage:[UIImage imageNamed:@"icn_registra_on"] forState:UIControlStateNormal];
            [presenceActionCollectionViewCell.ibButtonAzione setImage:[UIImage imageNamed:@"icn_registra_off"] forState:UIControlStateDisabled];
            
            //NSLog(@"portableNethUser.permissionsRecording: %@", self.portableNethUserMe.permissionsRecording ? @"Yes" : @"No");

            if (self.portableNethUserMe.permissionsRecording != false) {
                
                if ([self.presenceUserObjcSelezionato.mainPresence isEqualToString:kKeyBusy]) {
                    
                    presenceActionCollectionViewCell.ibButtonAzione.enabled = YES;
                    presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = [UIColor colorNamed:@"ColorTextBlack"];

                }else {
                    
                    presenceActionCollectionViewCell.ibButtonAzione.enabled = NO;
                    presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = [UIColor colorNamed: @"ColorTextDisabled"];
                }
                
            }else {
                
                presenceActionCollectionViewCell.ibButtonAzione.enabled = NO;
                presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = [UIColor colorNamed: @"ColorTextDisabled"];
            }
            
            
            break;
            
        case 3:
            // INTROMETTITI
            
            presenceActionCollectionViewCell.ibLabelNomeAzione.text = NSLocalizedString(@"INTROMETTITI", nil);

            [presenceActionCollectionViewCell.ibButtonAzione setImage:[UIImage imageNamed:@"icn_intromettiti_on"] forState:UIControlStateNormal];
            [presenceActionCollectionViewCell.ibButtonAzione setImage:[UIImage imageNamed:@"icn_intromettiti_off"] forState:UIControlStateDisabled];
            
            //NSLog(@"portableNethUser.permissionsIntrude: %@", self.portableNethUserMe.permissionsIntrude ? @"Yes" : @"No");

            if (self.portableNethUserMe.permissionsIntrude != false) {
                
                if ([self.presenceUserObjcSelezionato.mainPresence isEqualToString:kKeyBusy]) {
                    
                    presenceActionCollectionViewCell.ibButtonAzione.enabled = YES;
                    presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = [UIColor colorNamed:@"ColorTextBlack"];

                }else {
                    
                    presenceActionCollectionViewCell.ibButtonAzione.enabled = NO;
                    presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = [UIColor colorNamed: @"ColorTextDisabled"];

                }

            }else {
             
                presenceActionCollectionViewCell.ibButtonAzione.enabled = NO;
                presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = [UIColor colorNamed: @"ColorTextDisabled"];

            }
            
            
            break;
            
        case 4:
            // PRENOTA
            
            presenceActionCollectionViewCell.ibLabelNomeAzione.text = NSLocalizedString(@"PRENOTA", nil);

            [presenceActionCollectionViewCell.ibButtonAzione setImage:[UIImage imageNamed:@"icn_prenota_on"] forState:UIControlStateNormal];
            [presenceActionCollectionViewCell.ibButtonAzione setImage:[UIImage imageNamed:@"icn_prenota_off"] forState:UIControlStateDisabled];
            
            //NSLog(@"portableNethUser.recallOnBusy: %@", self.portableNethUserMe.recallOnBusy);

            if ([self.portableNethUserMe.recallOnBusy isEqualToString:kKeyRecallOnBusyEnabled]) {
                
                if ([self.presenceUserObjcSelezionato.mainPresence isEqualToString:kKeyBusy]) {
                    
                    presenceActionCollectionViewCell.ibButtonAzione.enabled = YES;
                    presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = [UIColor colorNamed:@"ColorTextBlack"];

                }else {
                    
                    presenceActionCollectionViewCell.ibButtonAzione.enabled = NO;
                    presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = [UIColor colorNamed: @"ColorTextDisabled"];

                }

            }else {
                
                presenceActionCollectionViewCell.ibButtonAzione.enabled = NO;
                presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = [UIColor colorNamed: @"ColorTextDisabled"];

            }
            
            break;
            
        case 5:
            // PICKUP
            
            presenceActionCollectionViewCell.ibLabelNomeAzione.text = NSLocalizedString(@"PICKUP", nil);

            [presenceActionCollectionViewCell.ibButtonAzione setImage:[UIImage imageNamed:@"icn_pickup_on"] forState:UIControlStateNormal];
            [presenceActionCollectionViewCell.ibButtonAzione setImage:[UIImage imageNamed:@"icn_pickup_off"] forState:UIControlStateDisabled];
            
            //NSLog(@"portableNethUser.permissionsPickup: %@", self.portableNethUserMe.permissionsPickup ? @"Yes" : @"No");

            if (self.portableNethUserMe.permissionsPickup != false) {
                
                if ([self.presenceUserObjcSelezionato.mainPresence isEqualToString:kKeyRinging]) {
                    
                    presenceActionCollectionViewCell.ibButtonAzione.enabled = YES;
                    presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = [UIColor colorNamed:@"ColorTextBlack"];

                }else {
                    
                    presenceActionCollectionViewCell.ibButtonAzione.enabled = NO;
                    presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = [UIColor colorNamed: @"ColorTextDisabled"];

                }

            }else {
                
                presenceActionCollectionViewCell.ibButtonAzione.enabled = NO;
                presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = [UIColor colorNamed: @"ColorTextDisabled"];

            }
            
            
            break;
            
        case 6:
            // SPIA
            
            presenceActionCollectionViewCell.ibLabelNomeAzione.text = NSLocalizedString(@"SPIA", nil);

            [presenceActionCollectionViewCell.ibButtonAzione setImage:[UIImage imageNamed:@"icn_spia_on"] forState:UIControlStateNormal];
            [presenceActionCollectionViewCell.ibButtonAzione setImage:[UIImage imageNamed:@"icn_spia_off"] forState:UIControlStateDisabled];
            
            //NSLog(@"portableNethUser.permissionsSpy: %@", self.portableNethUserMe.permissionsSpy ? @"Yes" : @"No");

            if (self.portableNethUserMe.permissionsSpy != false) {
                
                if ([self.presenceUserObjcSelezionato.mainPresence isEqualToString:kKeyBusy]) {
                    
                    presenceActionCollectionViewCell.ibButtonAzione.enabled = YES;
                    presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = [UIColor colorNamed:@"ColorTextBlack"];

                }else {
                    
                    presenceActionCollectionViewCell.ibButtonAzione.enabled = NO;
                    presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = [UIColor colorNamed: @"ColorTextDisabled"];

                }

            }else {
             
                presenceActionCollectionViewCell.ibButtonAzione.enabled = NO;
                presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = [UIColor colorNamed: @"ColorTextDisabled"];

            }
            
            break;
            
     
    }

    
    
    return presenceActionCollectionViewCell;
}



#pragma mark -
#pragma mark === UICollectionView delegate ===
#pragma mark -
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    

}


/*
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize sizeCollectionView = CGSizeZero;
    
    if (0 == self.statoCella) {
        
        sizeCollectionView = CGSizeMake(self.view.frame.size.width - self.paddingCellaGrande, self.heigthCella);

        self.statoCella = 1;
        
    }else if (1 == self.statoCella) {
        
        sizeCollectionView = CGSizeMake((self.view.frame.size.width / 2) - self.paddingCellaPiccola, self.heigthCella);
        
        self.statoCella = 2;
        
    }else if (2 == self.statoCella) {
        
        sizeCollectionView = CGSizeMake((self.view.frame.size.width / 2) - self.paddingCellaPiccola, self.heigthCella);
        
        self.statoCella = 0;
    }
    
    return sizeCollectionView;
}
*/


- (void)azionePrenota {
    
    //NSLog(@"azionePrenota");
        
    [self.HUD showAnimated:YES];
    
    NethCTIAPI *api = [NethCTIAPI sharedInstance];
    
    [api postRecallOnBusyWithCaller:self.portableNethUserMe.mainExtension
                             called:self.presenceUserObjcSelezionato.mainExtension
                     successHandler:^(NSString * _Nullable successMessage) {
        
        //NSLog(@"successMessage: %@", successMessage);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Nascondo la ViewCaricamento
            [self.HUD hideAnimated:YES];
            
            //[self dismissViewControllerAnimated:YES completion:nil];
            [self dismissViewControllerAnimated:YES completion:^{
                
                [self.presenceActionDelegate reloadPresenceFromAction];
            }];
        });
        
    }
                       errorHandler:^(NSInteger errorCode, NSString * _Nullable errorString) {
        
        NSLog(@"errorCode: %ld - errorString: %@", (long)errorCode, errorString);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Nascondo la ViewCaricamento
            [self.HUD hideAnimated:YES];
            
            [self showAlertError:errorCode withError:errorString];
        });
        
    }];
}



- (void)azioneSpia {
    
    //NSLog(@"azioneSpia");
    
    [self.HUD showAnimated:YES];
    
    NethCTIAPI *api = [NethCTIAPI sharedInstance];
    
    [api getExtensionsWithArrayExtensionsId:self.presenceUserObjcSelezionato.arrayExtensionsId
                             successHandler:^(ConversationObjc * _Nullable conversationObject) {
        
        //NSLog(@"conversationObject: %@", conversationObject.conversationId);
        //NSLog(@"conversationObject: %@", conversationObject.owner);
        
        [api postStartSpyWithConversationsId:conversationObject.conversationId
                           conversationOwner:conversationObject.owner
                                 extensionId:self.portableNethUserMe.mobileID
                              successHandler:^(NSString * _Nullable successMessage) {
            
            //NSLog(@"successMessage: %@", successMessage);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Nascondo la ViewCaricamento
                [self.HUD hideAnimated:YES];
                
                //[self dismissViewControllerAnimated:YES completion:nil];
                [self dismissViewControllerAnimated:YES completion:^{
                    
                    [self.presenceActionDelegate reloadPresenceFromAction];
                }];
            });
            
        }
                                errorHandler:^(NSInteger errorCode, NSString * _Nullable errorString) {
            
            NSLog(@"errorCode: %ld - errorString: %@", (long)errorCode, errorString);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Nascondo la ViewCaricamento
                [self.HUD hideAnimated:YES];
                
                [self showAlertError:errorCode withError:errorString];
                
            });
            
        }];
        
        
    } errorHandler:^(NSInteger code, NSString * _Nullable messageDefault) {
        
        NSLog(@"getUserMe API_ERROR code: %ld, string: %@", (long)code, messageDefault);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Nascondo la ViewCaricamento
            [self.HUD hideAnimated:YES];
            
            [self showAlertError:code withError:messageDefault];
        });
        
    }];

    
}



- (void)azioneIntromettiti {
    
    //NSLog(@"azioneIntromettiti");
    
    [self.HUD showAnimated:YES];
    
    NethCTIAPI *api = [NethCTIAPI sharedInstance];
    
    [api getExtensionsWithArrayExtensionsId:self.presenceUserObjcSelezionato.arrayExtensionsId
                             successHandler:^(ConversationObjc * _Nullable conversationObject) {
        
        //NSLog(@"conversationObject: %@", conversationObject.conversationId);
        //NSLog(@"conversationObject: %@", conversationObject.owner);
        
        [api postIntrudeWithConversationsId:conversationObject.conversationId
                          conversationOwner:conversationObject.owner
                                extensionId:self.portableNethUserMe.mobileID
                             successHandler:^(NSString * _Nullable successMessage) {
            
            //NSLog(@"successMessage: %@", successMessage);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Nascondo la ViewCaricamento
                [self.HUD hideAnimated:YES];
                
                //[self dismissViewControllerAnimated:YES completion:nil];
                [self dismissViewControllerAnimated:YES completion:^{
                    
                    [self.presenceActionDelegate reloadPresenceFromAction];
                }];
            });
            
        }
                               errorHandler:^(NSInteger errorCode, NSString * _Nullable errorString) {
            
            NSLog(@"errorCode: %ld - errorString: %@", (long)errorCode, errorString);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Nascondo la ViewCaricamento
                [self.HUD hideAnimated:YES];
                
                [self showAlertError:errorCode withError:errorString];
                
            });
            
        }];
        
        
    } errorHandler:^(NSInteger code, NSString * _Nullable messageDefault) {
        
        NSLog(@"getUserMe API_ERROR code: %ld, string: %@", (long)code, messageDefault);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Nascondo la ViewCaricamento
            [self.HUD hideAnimated:YES];
            
            [self showAlertError:code withError:messageDefault];
        });
        
    }];
    
}


- (void)azioneChiama {
    
    //NSLog(@"azioneChiama");

    //NSLog(@"portablePresenceUser.mainextension: %@", self.portablePresenceUser.mainExtension);

    LinphoneAddress *linphoneAddress = [LinphoneUtils normalizeSipOrPhoneAddress:self.presenceUserObjcSelezionato.mainExtension];

    [LinphoneManager.instance call:linphoneAddress];
    
    if (linphoneAddress) {
        
        linphone_address_unref(linphoneAddress);
        
        //[self dismissViewControllerAnimated:YES completion:nil];
        [self dismissViewControllerAnimated:YES completion:^{
            
            [self.presenceActionDelegate reloadPresenceFromAction];
        }];
        
    }else {
        
        NSLog(@"linphoneAddress false!");

    }
}



- (void)azioneRegistra {
    
    //NSLog(@"azioneRegistra");
    
    //NSLog(@"portablePresenceUser.arrayExtensionsId: %@", self.portablePresenceUser.arrayExtensionsId);
    
    [self.HUD showAnimated:YES];
    
    NethCTIAPI *api = [NethCTIAPI sharedInstance];
    
    [api getExtensionsWithArrayExtensionsId:self.presenceUserObjcSelezionato.arrayExtensionsId
                             successHandler:^(ConversationObjc * _Nullable conversationObject) {
        
        //NSLog(@"conversationObject: %@", conversationObject.conversationId);
        //NSLog(@"conversationObject: %@", conversationObject.owner);
        
        [api postAdRecordingWithConversationsId:conversationObject.conversationId
                          conversationOwner:conversationObject.owner
                             successHandler:^(NSString * _Nullable successMessage) {
            
            //NSLog(@"successMessage: %@", successMessage);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Nascondo la ViewCaricamento
                [self.HUD hideAnimated:YES];
                
                //[self dismissViewControllerAnimated:YES completion:nil];
                [self dismissViewControllerAnimated:YES completion:^{
                    
                    [self.presenceActionDelegate reloadPresenceFromAction];
                }];
            });
            
        }
                               errorHandler:^(NSInteger errorCode, NSString * _Nullable errorString) {
            
            NSLog(@"errorCode: %ld - errorString: %@", (long)errorCode, errorString);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Nascondo la ViewCaricamento
                [self.HUD hideAnimated:YES];
                
                [self showAlertError:errorCode withError:errorString];
                
            });
            
        }];
        
        
    } errorHandler:^(NSInteger code, NSString * _Nullable messageDefault) {
        
        NSLog(@"getUserMe API_ERROR code: %ld, string: %@", (long)code, messageDefault);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Nascondo la ViewCaricamento
            [self.HUD hideAnimated:YES];
            
            [self showAlertError:code withError:messageDefault];
        });
        
    }];
    
}


- (void)azionePickup {
    
    //NSLog(@"azionePickup");
    
    [self.HUD showAnimated:YES];
    
    NethCTIAPI *api = [NethCTIAPI sharedInstance];
    
    // chiudo prima perchè la post non mi risponde fino a quando l'utente non prende la chiamata in entrata dal server
    [self dismissViewControllerAnimated:YES completion:nil];

    [api postPickupWithMainExtensionId:self.presenceUserObjcSelezionato.mainExtension
                           extensionId:self.portableNethUserMe.mobileID
                        successHandler:^(NSString * _Nullable successMessage) {
        
        //NSLog(@"successMessage: %@", successMessage);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Nascondo la ViewCaricamento
            [self.HUD hideAnimated:YES];
        });
        
    }
                          errorHandler:^(NSInteger errorCode, NSString * _Nullable errorString) {
        
        NSLog(@"errorCode: %ld - errorString: %@", (long)errorCode, errorString);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Nascondo la ViewCaricamento
            [self.HUD hideAnimated:YES];
            
            [self showAlertError:errorCode withError:errorString];
            
        });
        
    }];
    
    
}




- (void)azioneChiudi {
    
    //NSLog(@"azioneChiudi");
        
    [self.HUD showAnimated:YES];
    
    NethCTIAPI *api = [NethCTIAPI sharedInstance];
    
    [api getExtensionsWithArrayExtensionsId:self.presenceUserObjcSelezionato.arrayExtensionsId
                             successHandler:^(ConversationObjc * _Nullable conversationObject) {
        
        //NSLog(@"conversationObject: %@", conversationObject.conversationId);
        //NSLog(@"conversationObject: %@", conversationObject.owner);
        
        [api postChiudiWithConversationsId:conversationObject.conversationId
                         conversationOwner:conversationObject.owner
                            successHandler:^(NSString * _Nullable successMessage) {
            
            //NSLog(@"successMessage: %@", successMessage);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Nascondo la ViewCaricamento
                [self.HUD hideAnimated:YES];
                
                [self dismissViewControllerAnimated:YES completion:^{
                    
                    [self.presenceActionDelegate reloadPresenceFromAction];
                }];
            });
            
        }
                              errorHandler:^(NSInteger errorCode, NSString * _Nullable errorString) {
            
            NSLog(@"errorCode: %ld - errorString: %@", (long)errorCode, errorString);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Nascondo la ViewCaricamento
                [self.HUD hideAnimated:YES];
                
                [self showAlertError:errorCode withError:errorString];
                
            });
            
        }];
        
        
    } errorHandler:^(NSInteger code, NSString * _Nullable messageDefault) {
        
        NSLog(@"getUserMe API_ERROR code: %ld, string: %@", (long)code, messageDefault);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Nascondo la ViewCaricamento
            [self.HUD hideAnimated:YES];
            
            [self showAlertError:code withError:messageDefault];
        });
        
    }];
    
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
