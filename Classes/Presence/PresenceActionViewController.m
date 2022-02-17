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



@interface PresenceActionViewController ()

@end


@implementation PresenceActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
        

    [self setPresenceUser];
    
    
    NSLog(@"portableNethUserMe.mainextension: %@", self.portableNethUserMe.mainExtension);
        
    NSLog(@"portablePresenceUser.mainextension: %@", self.portablePresenceUser.mainExtension);

    
    
    
    UINib *nibPresenceActionCollectionViewCell = [UINib nibWithNibName:NSStringFromClass([PresenceActionCollectionViewCell class]) bundle:nil];
    [self.ibCollectionView registerNib:nibPresenceActionCollectionViewCell forCellWithReuseIdentifier:@"idPresenceActionCollectionViewCell"];
    
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
    
    NSLog(@"ibaEseguiAzione sender: %ld", (long)sender.tag);

    switch (sender.tag) {
            
        case 0:
            // CHIAMA
            
            NSLog(@"CHIAMA");

            NSLog(@"portablePresenceUser.mainextension: %@", self.portablePresenceUser.mainExtension);

            LinphoneAddress *linphoneAddress = [LinphoneUtils normalizeSipOrPhoneAddress:self.portablePresenceUser.mainExtension];

            [LinphoneManager.instance call:linphoneAddress];
            
            if (linphoneAddress) {
                
                linphone_address_unref(linphoneAddress);
                
                [self dismissViewControllerAnimated:YES completion:nil];

            }else {
                
                NSLog(@"linphoneAddress false!");

            }
            
            break;
            
        case 1:
            // CHIUDI
            
            NSLog(@"CHIUDI");

            
            break;
            
        case 2:
            // REGISTRA
            
            NSLog(@"REGISTRA");

            
            break;
            
        case 3:
            // INTROMETTITI
            
            NSLog(@"INTROMETTITI");

            
            
            break;
            
        case 4:
            // PRENOTA
            
            NSLog(@"PRENOTA");

           
            
            break;
            
        case 5:
            // PICKUP
            
            NSLog(@"PICKUP");

            
            
            break;
            
        case 6:
            // SPIA
            
            NSLog(@"SPIA");

            
            break;
            
     
    }
}




- (IBAction)ibaSetPreferito:(id)sender {
    
    NSLog(@"ibaSetPreferito");

    
}


- (IBAction)ibaChiudi:(id)sender {
    
    NSLog(@"ibaChiudi");

    [self dismissViewControllerAnimated:YES completion:nil];
}




- (void)setPresenceUser {
    
    NSLog(@"portablePresenceUser: %@", self.portablePresenceUser);

    self.ibLabelNome.text = self.portablePresenceUser.name;
    
    
    // --- INIZIALI NOME ---
    NSString *noteUtente = self.portablePresenceUser.name;
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
        
    
    self.ibLabelStatusPresence.text = self.portablePresenceUser.mainPresence;
    
    self.ibLabelMainExtension.text = self.portablePresenceUser.mainExtension;
    
    
    
    // bordo
    [self.ibImageViewBordoStatus.layer setBorderWidth: 1.0];

    
    NSString *presence = self.portablePresenceUser.mainPresence;
    
    if ([presence isEqualToString:kKeyOnline]) {
        // ONLINE
        
        // bordo
        [self.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceOnline"] CGColor]];
        
        // status
        self.ibLabelStatusPresence.text = @"DISPONIBILE";
        self.ibViewPresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOnline"];
        
        // icona
        self.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOnline"];
        self.ibImageViewStatus.image = [UIImage imageNamed:@"icn_online"];
        
    }else if ([presence isEqualToString:kKeyBusy]) {
        // BUSY
        
        // bordo
        [self.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceBusy"] CGColor]];
        
        self.ibLabelStatusPresence.text = @"BUSY";
        self.ibViewPresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceBusy"];

        self.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceBusy"];
        self.ibImageViewStatus.image = [UIImage imageNamed:@"icn_busy"];
        
    }else if ([presence isEqualToString:kKeyRinging]) {
        // INCOMING
        
        // bordo
        [self.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceIncoming"] CGColor]];
        
        self.ibLabelStatusPresence.text = @"INCOMING";
        self.ibViewPresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceIncoming"];

        self.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceIncoming"];
        self.ibImageViewStatus.image = [UIImage imageNamed:@"icn_incoming"];
        
    }else if ([presence isEqualToString:kKeyOffline]) {
        // OFFLINE
        
        // bordo
        [self.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceOffline"] CGColor]];
        
        self.ibLabelStatusPresence.text = @"OFFLINE";
        self.ibViewPresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOffline"];

        self.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOffline"];
        self.ibImageViewStatus.image = [UIImage imageNamed:@"icn_offline"];
        
        
    }else if ([presence isEqualToString:kKeyCellphone]) {
        // CELLPHONE
        
        // bordo
        [self.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceCellphone"] CGColor]];
        
        self.ibLabelStatusPresence.text = @"CELLULARE";
        self.ibViewPresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCellphone"];

        self.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCellphone"];
        self.ibImageViewStatus.image = [UIImage imageNamed:@"icn_cellphone"];
        
    }else if ([presence isEqualToString:kKeyVoicemail]) {
        // VOICEMAIL
        
        // bordo
        [self.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceVoicemail"] CGColor]];
        
        self.ibLabelStatusPresence.text = @"CASELLA VOCALE";
        self.ibViewPresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceVoicemail"];

        self.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceVoicemail"];
        self.ibImageViewStatus.image = [UIImage imageNamed:@"icn_voicemail"];
        
        
    }else if ([presence isEqualToString:kKeyDnd]) {
        // DND
        
        // bordo
        [self.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceDnd"] CGColor]];
        
        self.ibLabelStatusPresence.text = @"NON DISTURBARE";
        self.ibViewPresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceDnd"];

        self.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceDnd"];
        self.ibImageViewStatus.image = [UIImage imageNamed:@"icn_dnd"];
        
    }else if ([presence isEqualToString:kKeyCallforward]) {
        // CALLFORWORD
        
        // bordo
        [self.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceCallforward"] CGColor]];
        
        self.ibLabelStatusPresence.text = @"INOLTRO";
        self.ibViewPresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCallforward"];

        self.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCallforward"];
        self.ibImageViewStatus.image = [UIImage imageNamed:@"icn_callforward"];
        
    }else {
        // Default
        
        // bordo
        [self.ibImageViewBordoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceOffline"] CGColor]];
        
        self.ibLabelStatusPresence.text = @"N/D";
        self.ibViewPresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOffline"];

        self.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOffline"];
        self.ibImageViewStatus.image = [UIImage imageNamed:@"icn_offline"];
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
            
            
            if ([self.portablePresenceUser.mainPresence isEqualToString:kKeyOnline] ||
                [self.portablePresenceUser.mainPresence isEqualToString:kKeyCellphone] ||
                [self.portablePresenceUser.mainPresence isEqualToString:kKeyVoicemail] ||
                [self.portablePresenceUser.mainPresence isEqualToString:kKeyCallforward]) {
                
                presenceActionCollectionViewCell.ibButtonAzione.enabled = YES;
                presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = UIColor.blackColor;

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
            
            NSLog(@"portableNethUser.permissionsRecording: %@", self.portableNethUserMe.permissionsHangup ? @"Yes" : @"No");

            if (self.portableNethUserMe.permissionsHangup != false) {
                                
                if ([self.portablePresenceUser.mainPresence isEqualToString:kKeyBusy] ||
                    [self.portablePresenceUser.mainPresence isEqualToString:kKeyRinging]) {
                    
                    presenceActionCollectionViewCell.ibButtonAzione.enabled = YES;
                    presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = UIColor.blackColor;

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
            
            NSLog(@"portableNethUser.permissionsRecording: %@", self.portableNethUserMe.permissionsRecording ? @"Yes" : @"No");

            if (self.portableNethUserMe.permissionsRecording != false) {
                
                if ([self.portablePresenceUser.mainPresence isEqualToString:kKeyBusy]) {
                    
                    presenceActionCollectionViewCell.ibButtonAzione.enabled = YES;
                    presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = UIColor.blackColor;

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
            
            NSLog(@"portableNethUser.permissionsIntrude: %@", self.portableNethUserMe.permissionsIntrude ? @"Yes" : @"No");

            if (self.portableNethUserMe.permissionsIntrude != false) {
                
                if ([self.portablePresenceUser.mainPresence isEqualToString:kKeyBusy]) {
                    
                    presenceActionCollectionViewCell.ibButtonAzione.enabled = YES;
                    presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = UIColor.blackColor;

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
            
            NSLog(@"portableNethUser.recallOnBusy: %@", self.portableNethUserMe.recallOnBusy);

            if ([self.portableNethUserMe.recallOnBusy isEqualToString:kKeyRecallOnBusyEnabled]) {
                
                if ([self.portablePresenceUser.mainPresence isEqualToString:kKeyBusy]) {
                    
                    presenceActionCollectionViewCell.ibButtonAzione.enabled = YES;
                    presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = UIColor.blackColor;

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
            
            NSLog(@"portableNethUser.permissionsPickup: %@", self.portableNethUserMe.permissionsPickup ? @"Yes" : @"No");

            if (self.portableNethUserMe.permissionsPickup != false) {
                
                if ([self.portablePresenceUser.mainPresence isEqualToString:kKeyRinging]) {
                    
                    presenceActionCollectionViewCell.ibButtonAzione.enabled = YES;
                    presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = UIColor.blackColor;

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
            
            NSLog(@"portableNethUser.permissionsSpy: %@", self.portableNethUserMe.permissionsSpy ? @"Yes" : @"No");

            if (self.portableNethUserMe.permissionsSpy != false) {
                
                if ([self.portablePresenceUser.mainPresence isEqualToString:kKeyBusy]) {
                    
                    presenceActionCollectionViewCell.ibButtonAzione.enabled = YES;
                    presenceActionCollectionViewCell.ibLabelNomeAzione.textColor = UIColor.blackColor;

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


@end
