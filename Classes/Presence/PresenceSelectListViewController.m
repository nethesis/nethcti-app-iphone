//
//  PresenceSelectListViewController.m
//  NethCTI
//
//  Created by Marco on 02/02/22.
//

#import "PresenceSelectListViewController.h"
#import "MBProgressHUD.h"
#import "PresenceSelectListTableViewCell.h"


#define kKeyOnline @"online"
#define kKeyBusy @"busy"
#define kKeyRinging @"ringing"
#define kKeyOffline @"offline"
#define kKeyCellphone @"cellphone"
#define kKeyVoicemail @"voicemail"
#define kKeyDnd @"dnd"
#define kKeyCallforward @"callforward"


@interface PresenceSelectListViewController ()

@property (strong, nonatomic) MBProgressHUD *HUD;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property(strong, nonatomic) NSMutableArray *arrayPresence;

@end



@implementation PresenceSelectListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:self.HUD];
    
    [self.HUD showAnimated:YES];
    
    
    // --- UIRefreshControl ---
    // Initialize Refresh Control
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    //self.refreshControl.tintColor = colorDivider;
    
    // Configure Refresh Control
    [self.refreshControl addTarget:self action:@selector(downloadPresenceList) forControlEvents:UIControlEventValueChanged];
    
    // Configure View Controller
    [self.ibTableViewSelezionePresence addSubview:self.refreshControl];
    // ------------------------
    
    
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
    
    [self dismissViewControllerAnimated:YES completion:nil];

}


#pragma mark -
#pragma mark === downloadPresence ===
#pragma mark -

- (void)downloadPresenceList {
    
    LOGD(@"downloadListPresence");

    NethCTIAPI *api = [NethCTIAPI sharedInstance];

    // Download GRUPPI
    [api getPresenceListWithSuccessHandler:^(NSArray *arrayPresence) {
        


        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Nascondo la ViewCaricamento
            [self.HUD hideAnimated:YES];
            
            [self.refreshControl endRefreshing];
            
            self.arrayPresence = [[NSMutableArray alloc] initWithArray:arrayPresence];
            LOGD(@"arrayPresence: %@", arrayPresence);
            
            
            [self.ibTableViewSelezionePresence reloadData];
            
        });
        
        
        
    } errorHandler:^(NSInteger code, NSString * _Nullable string) {
        
        
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
        
        
    }];
    
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //LOGD(@"LOGD arrayUsers.count: %d", self.arrayUsers.count);
    
    if (self.arrayPresence.count > 0) {
        
        self.ibLabelNessunDato.hidden = YES;

        return 1;
        
    }else {
        
        self.ibLabelNessunDato.hidden = NO;
        
        return 0;
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //LOGD(@"LOGD arrayUsers.count: %d", self.arrayUsers.count);
    
    return self.arrayPresence.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"
    
    LOGD(@"LOGD cellForRowAtIndexPath indexPath.row: %d", indexPath.row);
    
    static NSString *CellIdentifier = @"idPresenceSelectListTableViewCell";
    
    PresenceSelectListTableViewCell *presenceSelectListTableViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!presenceSelectListTableViewCell) {
        
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PresenceSelectListTableViewCell class]) owner:self options:nil];
        
        presenceSelectListTableViewCell = (PresenceSelectListTableViewCell *)self.ibPresenceSelectListTableViewCell;
        
        self.ibPresenceSelectListTableViewCell = nil;
    }
    
    NSString *presenceCurrent = (NSString *)[self.arrayPresence objectAtIndex:indexPath.row];
    //LOGD(@"LOGD presenceCurrent: %@", presenceCurrent);
    
    
    [self setPresenceCell:presenceSelectListTableViewCell withPresence:presenceCurrent];
    
    
    
    return presenceSelectListTableViewCell;
}




- (void)setPresenceCell:(PresenceSelectListTableViewCell *)presenceSelectListTableViewCell withPresence: (NSString *)presence {
    
    LOGD(@"LOGD setPresenceCell: %@ - presence: %@", presenceSelectListTableViewCell, presence);
        
    if ([presence isEqualToString:kKeyOnline]) {
        // ONLINE
        
        presenceSelectListTableViewCell.ibLabelNome.text = @"Disponibile";
        
        presenceSelectListTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOnline"];
        presenceSelectListTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_online"];
        
        
    }else if ([presence isEqualToString:kKeyCellphone]) {
        // CELLPHONE
                        
        presenceSelectListTableViewCell.ibLabelNome.text = @"Cellulare";
        
        presenceSelectListTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCellphone"];
        presenceSelectListTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_cellphone"];
        
        
    }else if ([presence isEqualToString:kKeyVoicemail]) {
        // VOICEMAIL
        
        presenceSelectListTableViewCell.ibLabelNome.text = @"Casella Vocale";
        
        presenceSelectListTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceVoicemail"];
        presenceSelectListTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_voicemail"];
        
        
    }else if ([presence isEqualToString:kKeyDnd]) {
        // DND
        
        presenceSelectListTableViewCell.ibLabelNome.text = @"Non distrubare";
        
        presenceSelectListTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceDnd"];
        presenceSelectListTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_dnd"];
        
    }else if ([presence isEqualToString:kKeyCallforward]) {
        // DND
        
        presenceSelectListTableViewCell.ibLabelNome.text = @"Inoltro";
        
        presenceSelectListTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceCallforward"];
        presenceSelectListTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_callforward"];
        
    }else {
        // Disabilitato
        
        presenceSelectListTableViewCell.ibLabelNome.text = @"Disabilitato";
        
        presenceSelectListTableViewCell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOffline"];
        presenceSelectListTableViewCell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_offline"];
        
    }
    
    
}





@end
