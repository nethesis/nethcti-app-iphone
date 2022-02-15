//
//  PresenceActionViewController.m
//  NethCTI
//
//  Created by Marco on 14/02/22.
//

#import "PresenceActionViewController.h"


#define kKeyOnline @"online"
#define kKeyBusy @"busy"
#define kKeyRinging @"ringing"
#define kKeyOffline @"offline"
#define kKeyCellphone @"cellphone"
#define kKeyVoicemail @"voicemail"
#define kKeyDnd @"dnd"
#define kKeyCallforward @"callforward"



@interface PresenceActionViewController ()

@end


@implementation PresenceActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
        

    [self setPresenceUser];
    
    
    NSLog(@"portableNethUser.mainextension: %@", self.portableNethUserMe.mainExtension);
    
    NSLog(@"portableNethUser.recallOnBusy: %@", self.portableNethUserMe.recallOnBusy);
    
    NSLog(@"portableNethUser.permissionsSpy: %@", self.portableNethUserMe.permissionsSpy ? @"Yes" : @"No");
    
    NSLog(@"portableNethUser.permissionsIntrude: %@", self.portableNethUserMe.permissionsIntrude ? @"Yes" : @"No");
    
    NSLog(@"portableNethUser.permissionsRecording: %@", self.portableNethUserMe.permissionsRecording ? @"Yes" : @"No");
    
    NSLog(@"portableNethUser.permissionsPickup: %@", self.portableNethUserMe.permissionsPickup ? @"Yes" : @"No");
    
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (IBAction)ibaSetPreferito:(id)sender {
    
    
    
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


@end
