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
    NSString* ar[] = { @"14", @"985", @"13" };
    NSString *kCellId = NSStringFromClass(RecentCallTableViewCell.class);
    RecentCallTableViewCell *cell = (RecentCallTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kCellId];
    if(!cell) {
        cell = [[RecentCallTableViewCell alloc] initWithIdentifier:kCellId];
    }
    
    NSString* elem = ar[indexPath.row];
    [cell setRecentCall:elem];
    
    /*
    NSString *kCellId = NSStringFromClass([RecentCallTableViewCell class]);
    RecentCallTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (cell == nil) {
        cell = [[RecentCallTableViewCell alloc] initWithIdentifier:kCellId];
    }
    
    [cell setRecentCall:@"ciao"];
    CGRect frame = cell.frame;
    frame.size.width = tableView.frame.size.width;
    frame.size.height = 45;
    [cell setSize:&frame];
    [cell layoutIfNeeded];
    */
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}


@end
