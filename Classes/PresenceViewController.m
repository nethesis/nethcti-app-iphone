

#import "PresenceViewController.h"
#import "PhoneMainView.h"



@implementation PresenceViewController

@synthesize tableController;
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
    
    //tableController.tableView.accessibilityIdentifier = @"Recordings table";
    //tableController.tableView.tableFooterView = [[UIView alloc] init];
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
        
    [self.tableController.tableView setSeparatorColor:[UIColor colorNamed: @"tableSeparator"]];
}


#pragma mark - IBAction Functions

- (IBAction)onBackPressed:(id)sender {
    
    [PhoneMainView.instance popCurrentView];
}

@end
