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
    
    NethCTIAPI *api = [NethCTIAPI sharedInstance];
        
    // Download info utente
    [api getUserMeWithSuccessHandler:^(PortableNethUser * _Nullable portableNethUser) {
        
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
            
            self.ibButtonSelezionePresence.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOnline"];
            
            [self.ibButtonSelezionePresence setImage:[UIImage imageNamed:@"icn_online"] forState:UIControlStateNormal];
        });
        
        
        

        
        // Download GRUPPI
        [api getGroupsWithSuccessHandler:^(NSArray *arrayGroups) {
            
            //LOGD(@"arrayGroups.count: %d", arrayGroups.count);

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
            
            LOGD(@"groupVisibileSelezionato.users: %@", groupVisibileSelezionato.users);
            // --------------------------------------
            
            
            NSMutableArray *arrayUsersVisibili = [NSMutableArray new];
            
            // Download utenti
            [api getUserAllWithSuccessHandler:^(NSArray * _Nonnull arrayUsers) {
                
                //LOGD(@"arrayUsers.firstObject: %@", arrayUsers.firstObject);
                
                //PortablePresenceUser *firstPortablePresenceUser = arrayUsers.firstObject;
                //LOGD(@"firstPortablePresenceUser.presence: %@", firstPortablePresenceUser.presence);

                //LOGD(@"firstPortablePresenceUser.mainExtension: %@", firstPortablePresenceUser.mainExtension);

                LOGD(@"arrayUsers.count: %d", arrayUsers.count);
                
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

                
                

                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    

                    PortablePresenceUser *firstPortablePresenceUser = (PortablePresenceUser *)arrayUsersVisibili.firstObject;
                    LOGD(@"firstPortablePresenceUser: %@", firstPortablePresenceUser);
                    
                    self.arrayUsers = arrayUsersVisibili;
                    
                    [self loadData];

                });
                
                
                

            } errorHandler:^(NSInteger code, NSString * _Nullable string) {
                
                // Get me error handling.
                LOGE(@"API_ERROR: %@", string);
                
                [self performSelectorOnMainThread:@selector(showErrorController:)
                                       withObject:string
                                    waitUntilDone:YES];
            }];
            
            
            
        } errorHandler:^(NSInteger code, NSString * _Nullable string) {
            
            // Get me error handling.
            LOGE(@"API_ERROR: %@", string);
            
            [self performSelectorOnMainThread:@selector(showErrorController:)
                                   withObject:string
                                waitUntilDone:YES];
        }];
        
        
    } errorHandler:^(NSInteger code, NSString * _Nullable string) {
        
        // Get me error handling.
        LOGE(@"API_ERROR: %@", string);
        
        [self performSelectorOnMainThread:@selector(showErrorController:)
                               withObject:string
                            waitUntilDone:YES];
    }];
    
    

    
    
    

    
    
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
    
}


/*
- (void)viewWillDisappear:(BOOL)animated {
    
    self.view = NULL;
    
    [self.tableController removeAllRecordings];
}
*/


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

}

- (IBAction)ibaSelezionePresence:(id)sender {
    
    LOGD(@"ibaSelezionePresence");

}

- (IBAction)onBackPressed:(id)sender {
    
    LOGD(@"onBackPressed");

    [PhoneMainView.instance popCurrentView];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
#warning Incomplete implementation, return the number of sections
    
    //LOGD(@"LOGD arrayUsers.count: %d", self.arrayUsers.count);

    if (self.arrayUsers.count > 0) {
        
        return 1;
        
    }else {
        
        return 0;
    }
     
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
#warning Incomplete implementation, return the number of rows
    
    //LOGD(@"LOGD arrayUsers.count: %d", self.arrayUsers.count);

    return self.arrayUsers.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"

    LOGD(@"LOGD cellForRowAtIndexPath indexPath.row: %d", indexPath.row);

    static NSString *CellIdentifier = @"idPresenceTableViewCell";
    
    PresenceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PresenceTableViewCell class]) owner:self options:nil];
        
        cell = (PresenceTableViewCell *)self.ibPresenceTableViewCell;
        
        self.ibPresenceTableViewCell = nil;
    }
    
    PortablePresenceUser *portablePresenceUser = (PortablePresenceUser *)[self.arrayUsers objectAtIndex:indexPath.row];
    //LOGD(@"LOGD portablePresenceUser: %@", portablePresenceUser.name);

    
    [cell.ibImageViewSfontoStatus.layer setBorderColor: [[UIColor colorNamed: @"ColorStatusPresenceOnline"] CGColor]];
    [cell.ibImageViewSfontoStatus.layer setBorderWidth: 1.0];
    
    
    cell.ibLabelIniziali.layer.masksToBounds = YES;
    cell.ibLabelIniziali.layer.cornerRadius = 22.0;


    
    
    NSString *noteUtente = portablePresenceUser.name;
    NSArray *arrayFirstLastStrings = [noteUtente componentsSeparatedByString:@" "];
    
    NSString *nome = [arrayFirstLastStrings objectAtIndex:0];
    char nomeInitialChar = [nome characterAtIndex:0];

    //LOGD(@"LOGD nomeInitialChar: %c", nomeInitialChar);

    if (arrayFirstLastStrings.count > 1) {

        NSString *cognome = [arrayFirstLastStrings objectAtIndex:1];

        char cognomeInitialChar = [cognome characterAtIndex:0];
        //LOGD(@"LOGD cognomeInitialChar: %c", cognomeInitialChar);

        cell.ibLabelIniziali.text = [NSString stringWithFormat:@"%c%c", nomeInitialChar, cognomeInitialChar];

    }else {
        
        cell.ibLabelIniziali.text = [NSString stringWithFormat:@"%c", nomeInitialChar];
    }
    
    
    cell.ibLabelName.text = noteUtente;
    
    
    cell.ibViewSfondoLabelStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOnline"];
    cell.ibViewSfondoLabelStatus.layer.masksToBounds = YES;
    cell.ibViewSfondoLabelStatus.layer.cornerRadius = 4.0;
    
    cell.ibLabelStatus.text = [[NSString stringWithFormat:@"%@", portablePresenceUser.presence] uppercaseString];
    
    
    cell.ibImageViewStatus.backgroundColor = [UIColor colorNamed: @"ColorStatusPresenceOnline"];
    cell.ibImageViewStatus.image = [UIImage imageNamed:@"icn_online"];
    
    return cell;
}

 
@end
