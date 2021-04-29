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
    // Do any additional setup after loading the view from its nib.
    
    // Set history table view.
    self.historyTableView.delegate = self;
    self.historyTableView.dataSource = self;
    self.historyTableView.allowsSelection = false;
    
    [_historyTableView registerClass:[RecentCallTableViewCell class] forCellReuseIdentifier:NSStringFromClass([RecentCallTableViewCell class])];

    //[self.historyTableView registerNib:([UINib nibWithNibName:@"RecentCallTableViewCell" bundle:nil]) forCellReuseIdentifier:@"RecentCallTableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    /*
    // Set notification observers.
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(callUpdateEvent:)
                                               name:kLinphoneCallUpdate
                                             object:nil];

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(coreUpdateEvent:)
                                               name:kLinphoneCoreUpdate
                                             object:nil];
    */
    // Change image colors.
    _dialerButton.imageView.image = [[UIImage imageNamed:@"call_missed.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_dialerButton.imageView setTintColor:[UIColor redColor]];
    _historyButton.imageView.image = [[UIImage imageNamed:@"call_missed.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_historyButton.imageView setTintColor:[UIColor redColor]];
    _phonebookButton.imageView.image = [[UIImage imageNamed:@"call_missed.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_phonebookButton.imageView setTintColor:[UIColor redColor]];
    _settingsButton.imageView.image = [[UIImage imageNamed:@"call_missed.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_settingsButton.imageView setTintColor:[UIColor redColor]];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    RecentCallTableViewCell *cell = (RecentCallTableViewCell *)[_historyTableView dequeueReusableCellWithIdentifier:NSStringFromClass([RecentCallTableViewCell class]) forIndexPath:indexPath];
    
    [cell.nameLabel setText:@"U"];
    [cell.nameInitialLabel setText:@"Utente prova"];
    [cell.numberLabel setText:@"sip: 213@123.123.12.12"];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

@end
