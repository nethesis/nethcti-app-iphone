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
    
    self.ibLabelStatusPresence.text = self.portablePresenceUser.mainPresence;
    
    self.ibLabelMainExtension.text = self.portablePresenceUser.mainExtension;
    
    
    //LOGD(@"LOGD setPresenceCell: %@ - presence: %@", presenceSelectListTableViewCell, presence);
    
    NSString *presence = self.portablePresenceUser.mainPresence;
    
    if ([presence isEqualToString:kKeyOnline]) {
        // ONLINE
        
        self.ibLabelStatusPresence.text = @"Disponibile";
        
        self.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOnline"];
        self.ibImageViewStatus.image = [UIImage imageNamed:@"icn_online"];
        
        
    }else if ([presence isEqualToString:kKeyCellphone]) {
        // CELLPHONE
        
        self.ibLabelStatusPresence.text = @"Cellulare";
        
        self.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCellphone"];
        self.ibImageViewStatus.image = [UIImage imageNamed:@"icn_cellphone"];
        
        
    }else if ([presence isEqualToString:kKeyVoicemail]) {
        // VOICEMAIL
        
        self.ibLabelStatusPresence.text = @"Casella Vocale";
        
        self.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceVoicemail"];
        self.ibImageViewStatus.image = [UIImage imageNamed:@"icn_voicemail"];
        
        
    }else if ([presence isEqualToString:kKeyDnd]) {
        // DND
        
        self.ibLabelStatusPresence.text = @"Non distrubare";
        
        self.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceDnd"];
        self.ibImageViewStatus.image = [UIImage imageNamed:@"icn_dnd"];
        
    }else if ([presence isEqualToString:kKeyCallforward]) {
        // DND
        
        self.ibLabelStatusPresence.text = @"Inoltro";
        
        self.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCallforward"];
        self.ibImageViewStatus.image = [UIImage imageNamed:@"icn_callforward"];
        
    }else {
        // Disabilitato
        
        self.ibLabelStatusPresence.text = @"Disabilitato";
        
        self.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOffline"];
        self.ibImageViewStatus.image = [UIImage imageNamed:@"icn_offline"];
        
    }
    
    
}


@end
