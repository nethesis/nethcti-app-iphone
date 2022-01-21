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
    /*
    [api postLogin:username password:pwd domain:domain successHandler:^(NSString * _Nullable digest) {
        
        [api getMeWithSuccessHandler:^(PortableNethUser* meUser) {
            
            [self performLogin:meUser domain:domain];
            
        } errorHandler:^(NSInteger code, NSString * _Nullable string) {
            
            // Get me error handling.
            LOGE(@"API_ERROR: %@", string);
            [self performSelectorOnMainThread:@selector(showErrorController:)
                                   withObject:string
                                waitUntilDone:YES];
            
        }];
        
    } errorHandler:^(NSInteger code, NSString * _Nullable string) {
        
        // Post login error handling.
        [self performSelectorOnMainThread:@selector(showErrorController:)
                               withObject:string
                            waitUntilDone:YES];
    }];
    */
    
    [api getAllUsersWithSuccessHandler:^(PortableNethUser * _Nullable user) {
        
        
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
