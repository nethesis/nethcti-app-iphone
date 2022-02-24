//
//  PresenceSelectListGroupViewController.m
//  NethCTI
//
//  Created by Democom S.r.l. on 02/02/22.
//

#import "PresenceSelectListGroupViewController.h"
#import "MBProgressHUD.h"



@interface PresenceSelectListGroupViewController ()

@property (strong, nonatomic) MBProgressHUD *HUD;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end


@implementation PresenceSelectListGroupViewController

@synthesize id_groupSelezionato;
@synthesize arrayGroups;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSLog(@"viewDidLoad()");

    //NSLog(@"arrayGroups: %@", self.arrayGroups);
    //NSLog(@"id_groupSelezionato: %@", self.id_groupSelezionato);
    
    
    // --- MBProgressHUD ---
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:self.HUD];
    // ------------------------
    
    
    // --- UIRefreshControl ---
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    //self.refreshControl.tintColor = colorDivider;
    
    [self.refreshControl addTarget:self action:@selector(downloadGruppiAbilitati) forControlEvents:UIControlEventValueChanged];
    
    [self.ibTableViewGruppi addSubview:self.refreshControl];
    // ------------------------
    
    
    // --- Download ---
    [self.HUD showAnimated:YES];
    
    [self downloadGruppiAbilitati];
    // ----------------
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
    
    NSLog(@"ibaChiudi");
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)downloadGruppiAbilitati {
    
    NSLog(@"downloadGruppiAbilitati");
    
    NethCTIAPI *api = [NethCTIAPI sharedInstance];
    
    // Download INFO UTENTE
    [api getUserMeWithSuccessHandler:^(PortableNethUser *portableNethUser) {
        
        //NSLog(@"portableNethUser.arrayPermissionsIdGroups: %@", portableNethUser.arrayPermissionsIdGroups);
        
        // Download GRUPPI
        [api getGroupsWithSuccessHandler:^(NSArray *arrayGroups) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Nascondo la ViewCaricamento
                [self.HUD hideAnimated:YES];
                
                [self.refreshControl endRefreshing];
                
                
                self.arrayGroups = [NSMutableArray new];
                                
                for (NSString *idGroupEnableCorrente in portableNethUser.arrayPermissionsIdGroups) {
                    
                    //NSLog(@"idGroupEnableCorrente: %@", idGroupEnableCorrente);
                    
                    for (GroupObjc *groupCorrente in arrayGroups) {
                        
                        if ([idGroupEnableCorrente isEqualToString:groupCorrente.id_group]) {
                            
                            //NSLog(@"AGGIUNTO id_group: %@", groupCorrente.id_group);
                            
                            [self.arrayGroups addObject:groupCorrente];
                        }
                    }
                }
                
                //NSLog(@"arrayGroups: %@", arrayGroups);

                
                // --- ordinamento dal più piccolo al più grande sulla chiave name ---
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
                NSArray *arrayGroupsSorted = [self.arrayGroups sortedArrayUsingDescriptors:@[sortDescriptor]];
                self.arrayGroups = [[NSMutableArray alloc]initWithArray:arrayGroupsSorted];
                // -------------------------------------------------------------------
                
                
                [self.ibTableViewGruppi reloadData];
                
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
    
}




#pragma mark -
#pragma mark === Table view data source ===
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //NSLog(@"arrayGroups.count: %lu", (unsigned long)self.arrayGroups.count);
    
    if (self.arrayGroups.count > 0) {
        
        self.ibLabelNessunDato.hidden = YES;
        
        return 1;
        
    }else {
        
        self.ibLabelNessunDato.hidden = NO;
        
        return 0;
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //NSLog(@"arrayGroups.count: %lu", (unsigned long)self.arrayGroups.count);
    
    return self.arrayGroups.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"cellForRowAtIndexPath indexPath.row: %ld", (long)indexPath.row);
    
    static NSString *CellIdentifier = @"idPresenceSelectListGroupTableViewCell";
    
    PresenceSelectListGroupTableViewCell *presenceSelectListGroupTableViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!presenceSelectListGroupTableViewCell) {
        
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PresenceSelectListGroupTableViewCell class]) owner:self options:nil];
        
        presenceSelectListGroupTableViewCell = (PresenceSelectListGroupTableViewCell *)self.ibPresenceSelectListGroupTableViewCell;
        
        self.ibPresenceSelectListGroupTableViewCell = nil;
    }
    
    
    GroupObjc *groupSelezionato = (GroupObjc *)[self.arrayGroups objectAtIndex:indexPath.row];
    
    //NSLog(@"groupSelezionato.name: %@", groupSelezionato.name);
    presenceSelectListGroupTableViewCell.ibLabelNome.text = groupSelezionato.name;
    
    
    // SELEZIONATO
    //NSLog(@"groupSelezionato.id_group: %@", groupSelezionato.id_group);
    NSLog(@"id_groupSelezionato: %@", id_groupSelezionato);

    if ([self.id_groupSelezionato isEqualToString:groupSelezionato.id_group]) {
        
        presenceSelectListGroupTableViewCell.ibLabelNome.textColor = [UIColor colorNamed: @"mainColor"];
        
        presenceSelectListGroupTableViewCell.ibImageViewGruppoSelezionato.image = [UIImage imageNamed:@"icn_check_blu"];
        
    }else {
        
        presenceSelectListGroupTableViewCell.ibLabelNome.textColor = [UIColor colorNamed: @"textColor"];
        
        presenceSelectListGroupTableViewCell.ibImageViewGruppoSelezionato.image = nil;
    }
    
    
    return presenceSelectListGroupTableViewCell;
}



#pragma mark -
#pragma mark === Table view delegate ===
#pragma mark -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //NSLog(@"didSelectRowAtIndexPath: %ld", (long)indexPath.row);

    GroupObjc *groupSelezionato = (GroupObjc *)[self.arrayGroups objectAtIndex:indexPath.row];
    
    self.id_groupSelezionato = groupSelezionato.id_group;
    //NSLog(@"id_groupSelezionato: %@", id_groupSelezionato);

    
    [self.ibTableViewGruppi reloadData];

    [self.presenceSelectListGroupDelegate reloadPresenceWithGroup:self.id_groupSelezionato];
    
    [self dismissViewControllerAnimated:YES completion:nil];

}


/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    

    
}
*/


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
