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

@synthesize presenceSelezionata;



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



#pragma mark -
#pragma mark === Table view delegate ===
#pragma mark -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *presenceSelezionata = (NSString *)[self.arrayPresence objectAtIndex:indexPath.row];
    LOGD(@"LOGD presenceSelezionata: %@", presenceSelezionata);
    
    if ([presenceSelezionata isEqualToString:kKeyCallforward]) {
        
        // INOLTRO
        
        [self impostaPresenceInoltro];
        
    }else {
        
        NethCTIAPI *api = [NethCTIAPI sharedInstance];
        
        [api postSetPresenceWithStatus:presenceSelezionata
                                number:@""
                        successHandler:^(NSString * _Nullable success) {
            
            NSLog(@"success: %@", success);
            
            
        }
                          errorHandler:^(NSInteger errorCode, NSString * _Nullable errorString) {
            
            NSLog(@"errorCode: %d - errorString: %@", errorCode, errorString);
            
        }];
        
    }
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
        
    
    NSString *presenceCurrent = (NSString *)[self.arrayPresence objectAtIndex:indexPath.row];
    LOGD(@"LOGD presenceCurrent: %@", presenceCurrent);
    
    [self setPresenceCell:(PresenceSelectListTableViewCell *)cell withPresence:presenceCurrent];
    
}




- (void)setPresenceCell:(PresenceSelectListTableViewCell *)presenceSelectListTableViewCell withPresence:(NSString *)presence {
    
    //LOGD(@"LOGD setPresenceCell: %@ - presence: %@", presenceSelectListTableViewCell, presence);
        
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
    
    
    // SELEZIONATO
    if ([self.presenceSelezionata isEqualToString:presence]) {
        
        presenceSelectListTableViewCell.ibLabelNome.textColor = [UIColor colorNamed: @"mainColor"];
        
        presenceSelectListTableViewCell.ibImageViewSelezionato.image = [UIImage imageNamed:@"icn_check_blu"];

    }else {
        
        presenceSelectListTableViewCell.ibLabelNome.textColor = [UIColor colorNamed: @"textColor"];

        presenceSelectListTableViewCell.ibImageViewSelezionato.image = [UIImage imageNamed:@""];
    }
    
    
}


- (void)impostaPresenceInoltro {

    NSLog(@"impostaPresenceInoltro");

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
        
        NSLog(@"numeroTextField: %@", numeroTextField.text);
        
        if ([numeroTextField.text isEqual:@""]) {
            
            UIAlertController *alertControllerAvviso = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Attenzione", nil)
                                                                                           message:NSLocalizedString(@"Devi inserire il numero telefonico da utilizzare per inoltrare la chiamata", nil)
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            // Annulla
            [alertControllerAvviso addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction *action) {
                
                // chiudi
                [alertControllerAvviso dismissViewControllerAnimated:YES completion:nil];

            }]];
            
            // chiudo il precedente
            [alertControllerInoltro dismissViewControllerAnimated:YES completion:nil];

            [self presentViewController:alertControllerAvviso animated:YES completion:nil];
            
        }else {
            
            // POST...
            
            NethCTIAPI *api = [NethCTIAPI sharedInstance];
            
            [api postSetPresenceWithStatus:@"callforward"
                                    number:numeroTextField.text
                            successHandler:^(NSString * _Nullable success) {
                
                NSLog(@"success: %@", success);
                
                
            }
                              errorHandler:^(NSInteger errorCode, NSString * _Nullable errorString) {
                
                NSLog(@"errorCode: %d - errorString: %@", errorCode, errorString);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //NSLog(@"API_ERROR: %@, code: %li", string, (long)code);
                    
                    // Nascondo la ViewCaricamento
                    [self.HUD hideAnimated:YES];
                    
                    
                    
                     // Get me error handling.
                     LOGE(@"errorString: %@", errorString);
                     
                     [self performSelectorOnMainThread:@selector(showErrorController:)
                                            withObject:errorString
                                         waitUntilDone:YES];
                     
                });
                
            }];
            
            
        }
        
    }]];
    
    // Annulla
    [alertControllerInoltro addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Annulla", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
        
        // chiudi
        [alertControllerInoltro dismissViewControllerAnimated:YES completion:nil];

        
    }]];
    
    
    
    [self presentViewController:alertControllerInoltro animated:YES completion:nil];
    
}


@end
