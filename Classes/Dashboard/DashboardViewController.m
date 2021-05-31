//
//  DashboardViewController.m
//  NethCTI
//
//  Created by Administrator on 07/04/2021.
//

#import "DashboardViewController.h"
#import "RecentCallTableViewCell.h"

@implementation DashboardViewController

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
        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

#pragma mark - ViewController Functions

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Change image colors.
    _dialerButton.imageView.image = [[UIImage imageNamed:@"call_missed.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_dialerButton.imageView setTintColor:[UIColor redColor]];
    _historyButton.imageView.image = [[UIImage imageNamed:@"call_missed.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_historyButton.imageView setTintColor:[UIColor redColor]];
    _phonebookButton.imageView.image = [[UIImage imageNamed:@"call_missed.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_phonebookButton.imageView setTintColor:[UIColor redColor]];
    _settingsButton.imageView.image = [[UIImage imageNamed:@"call_missed.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_settingsButton.imageView setTintColor:[UIColor redColor]];
    
    
    [_historyTableView loadData];

    // Fake event
    //[NSNotificationCenter.defaultCenter postNotificationName:kLinphoneCallUpdate object:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - Action Functions

/// Navigate to old Dialer page.
/// @param sender  must be the new DialerButton.
- (IBAction)onDialerClick:(id)sender {
    [PhoneMainView.instance changeCurrentView:DialerView.compositeViewDescription];
}
/// Navigate to old History page.
/// @param sender  must be the new HistoryButton.
- (IBAction)onHistoryClick:(id)sender {
    [PhoneMainView.instance changeCurrentView:HistoryListView.compositeViewDescription];
}
/// Navigate to old Phonebook page.
/// @param sender  must be the new PhonebookButton.
- (IBAction)onPhonebookClick:(id)sender {
    [PhoneMainView.instance changeCurrentView:ContactsListView.compositeViewDescription];
}
/// Navigate to old Settings page.
/// @param sender  must be the new SettingsButton.
- (IBAction)onSettingsClick:(id)sender {
    [PhoneMainView.instance changeCurrentView:SettingsView.compositeViewDescription];
}
@end
