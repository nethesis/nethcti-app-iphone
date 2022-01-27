//
//  PresenceTableViewController.m
//  NethCTI
//
//  Created by Democom S.r.l. on 18/01/22.
//

#import "PresenceViewController.h"
#import "PhoneMainView.h"



@implementation PresenceViewController

@synthesize presenceTableViewController;
@synthesize topBar;


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
        
        printf("portableNethUser.mainextension: %@", portableNethUser.arrayPermissionsIdGroups);

        LOGD(@"portableNethUser.recallOnBusy: %@", portableNethUser.arrayPermissionsIdGroups);
        
        
        // Download gruppi
        [api getGroupsWithSuccessHandler:^(NSArray *arrayGroups) {
            
            LOGD(@"arrayGroups.count: %d", arrayGroups.count);

            PortableGroup *portableGroup = arrayGroups.firstObject;
            LOGD(@"currentGroup: %@", portableGroup.id_group);

            
            for (NSString *idGroupEnable in portableNethUser.arrayPermissionsIdGroups) {
                
                LOGD(@"idGroupEnable: %@", idGroupEnable);

                
                
                for (PortableGroup *currentGroup in arrayGroups) {
                    
                    printf("currentGroup.id_group: %@", currentGroup.id_group);
                    LOGD(@"currentGroup.id_group: %@", currentGroup.id_group);
                    
                    if (idGroupEnable == currentGroup.id_group) {

                        // aggiungi gruppo..
                    }
                    
                }
                
            }
            
            
            
            
            // Download utenti
            [api getUserAllWithSuccessHandler:^(NSArray * _Nonnull arrayUsers) {
                
                //printf("arrayUsers: %@", arrayUsers);
                LOGD(@"arrayUsers.firstObject: %@", arrayUsers.firstObject);

                
                PortablePresenceUser *firstPortablePresenceUser = arrayUsers.firstObject;
                LOGD(@"firstPortablePresenceUser.presence: %@", firstPortablePresenceUser.presence);

                LOGD(@"firstPortablePresenceUser.mainExtension: %@", firstPortablePresenceUser.mainExtension);

                LOGD(@"arrayUsers.count: %d", arrayUsers.count);
                
                

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
        
    [self.presenceTableViewController.tableView setSeparatorColor:[UIColor colorNamed: @"accentColor"/*@"tableSeparator"*/]];
}


#pragma mark - IBAction Functions

- (IBAction)ibaVisualizzaPreferiti:(id)sender {
}

- (IBAction)ibaVisualizzaGruppi:(id)sender {
}

- (IBAction)ibaSelezionePresence:(id)sender {
}

- (IBAction)onBackPressed:(id)sender {
    
    [PhoneMainView.instance popCurrentView];
}

@end
