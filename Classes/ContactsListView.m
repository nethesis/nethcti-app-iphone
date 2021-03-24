/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
 *
 * This file is part of linphone-iphone
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#import "PhoneMainView.h"

@implementation ContactSelection

static ContactSelectionMode sSelectionMode = ContactSelectionModeNone;
static NSString *sAddAddress = nil;
static NSString *sSipFilter = nil;
static BOOL sEnableEmailFilter = FALSE;
static NSString *sNameOrEmailFilter;
static BOOL addAddressFromOthers = FALSE;
static NSString* pickerFilter = @"all";

+ (void)setSelectionMode:(ContactSelectionMode)selectionMode {
    sSelectionMode = selectionMode;
}

+ (ContactSelectionMode)getSelectionMode {
    return sSelectionMode;
}

+ (void)setAddAddress:(NSString *)address {
    sAddAddress = address;
    addAddressFromOthers = true;
}

+ (NSString *)getAddAddress {
    return sAddAddress;
}

+ (void)setSipFilter:(NSString *)domain {
    sSipFilter = domain;
}

+ (NSString *)getSipFilter {
    return sSipFilter;
}

+ (void)enableEmailFilter:(BOOL)enable {
    sEnableEmailFilter = enable;
}

+ (BOOL)emailFilterEnabled {
    return sEnableEmailFilter;
}

+ (void)setNameOrEmailFilter:(NSString *)fuzzyName {
    sNameOrEmailFilter = fuzzyName;
}

+ (NSString *)getNameOrEmailFilter {
    return sNameOrEmailFilter;
}

+ (void)setPickerFilter:(NSString *)value {
    pickerFilter = value;
}

+ (NSString *)getPickerFilter {
    return pickerFilter;
}

@end

@implementation ContactsListView

{
    NSArray *_pickerData;
    int tableViewHeight;
}

@synthesize tableController;
@synthesize allButton;
@synthesize linphoneButton;
@synthesize addButton;
@synthesize topBar;

typedef enum { ContactsAll, ContactsLinphone, ContactsMAX } ContactsCategory;

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:StatusBarView.class
                                                                 tabBar:TabBarView.class
                                                               sideMenu:SideMenuView.class
                                                             fullscreen:false
                                                         isLeftFragment:YES
                                                           fragmentWith:ContactDetailsView.class]; // We have to change it for Nethesis?
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

#pragma mark - ViewController Functions

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NethPhoneBook instance] reset];
    
    tableController.tableView.accessibilityIdentifier = @"Contacts table";
    
    if([ContactSelection getSipFilter])
        [self changeView:ContactsLinphone];
    else
        [self changeView:ContactsAll];
    
    if([ContactSelection getNameOrEmailFilter])
        _searchBar.text = [ContactSelection getNameOrEmailFilter];
    
    /*if ([tableController totalNumberOfItems] == 0) {
     [self changeView:ContactsAll];
     }*/
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboards)];
    
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    
    // Picker to change. Select data view to show.
    _pickerData = @[@"company", @"all", @"person"];
    self.filterPicker.dataSource = self;
    self.filterPicker.delegate = self;
    [self.filterPicker selectRow:[_pickerData indexOfObject:pickerFilter] inComponent:0 animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // [ContactSelection setNameOrEmailFilter:@""];
    _searchBar.showsCancelButton = (_searchBar.text.length > 0);
    
    tableViewHeight = tableController.tableView.frame.size.height;
    [self resizeTableView: YES]; // allButton.selected]; Hide picker.
    
    if (tableController.isEditing) {
        tableController.editing = NO;
    }
    [self refreshButtons];
    [_toggleSelectionButton setImage:[UIImage imageNamed:@"select_all_default.png"] forState:UIControlStateSelected];
    if ([LinphoneManager.instance lpConfigBoolForKey:@"hide_linphone_contacts" inSection:@"app"]) {
        self.linphoneButton.hidden = TRUE;
        self.selectedButtonImage.hidden = TRUE;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Subscribe to Phonebook Permission Rejection Notification.
    // TODO: We can send arguments to selector?
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(onPhonebookPermissionRejection:)
                                               name:kNethesisPhonebookPermissionRejection
                                             object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(onAddressBookUpdate:)
                                               name:kLinphoneAddressBookUpdate
                                             object:nil];
    
    if (![FastAddressBook isAuthorized]) {
        UIAlertController *errView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Address book", nil) message:NSLocalizedString(@"You must authorize the application to have access to address book.\n" "Toggle the application in Settings > Privacy > Contacts", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Continue", nil)
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [errView addAction:defaultAction];
        [self presentViewController:errView animated:YES completion:nil];
        [PhoneMainView.instance popCurrentView];
    }
    
    // show message toast when add contact from address
    if ([ContactSelection getAddAddress] != nil && addAddressFromOthers) {
        UIAlertController *infoView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Info", nil) message:NSLocalizedString(@"Select a contact or create a new one.",nil) preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        }];
        
        [infoView addAction:defaultAction];
        addAddressFromOthers = FALSE;
        [PhoneMainView.instance presentViewController:infoView animated:YES completion:nil];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    self.view = NULL;
    [self.tableController removeAllContacts];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void) resizeTableView:(BOOL) check {
    CGRect tableRect = tableController.tableView.frame;
    CGRect emptyRect = tableController.emptyView.frame;
    
    // Get original height and change accordly to check value.
    if(check) {
        tableRect.origin.y = emptyRect.origin.y = _searchBar.frame.origin.y + _searchBar.frame.size.height;
        tableRect.size.height = emptyRect.size.height = tableViewHeight;
    } else {
        tableRect.origin.y = emptyRect.origin.y = _filterPicker.frame.origin.y + _filterPicker.frame.size.height;
        tableRect.size.height = emptyRect.size.height = tableViewHeight - _filterPicker.frame.size.height;
    }
    
    // Why application crash at this point? Why is in a background thread?
    dispatch_async(dispatch_get_main_queue(), ^{
        [tableController.tableView setFrame: tableRect];
        [tableController.emptyView setFrame: emptyRect];
    });
}

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString* localizedString = NSLocalizedStringFromTable(_pickerData[row], @"NethLocalizable", @"");
    return localizedString;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [ContactSelection setPickerFilter:_pickerData[row]];
    NSString *picker = pickerFilter;
    NSString *search = _searchBar.text;
    [LinphoneManager.instance.fastAddressBook resetNeth];
    [LinphoneManager.instance.fastAddressBook loadNeth:picker withTerm:search];
}

-(NSString*) getSelectedPickerItem {
    int component = 0;
    NSInteger row = [_filterPicker selectedRowInComponent:component];
    return _pickerData[row];
}

#pragma mark -

- (void)changeView:(ContactsCategory)view {
    CGRect frame = _selectedButtonImage.frame;
    // REQUIRED TO RELOAD WITH FILTER.
    [LinphoneManager.instance setContactsUpdated:TRUE];
    if (view == ContactsAll && !allButton.selected) {
        // REQUIRED TO RELOAD WITH FILTER.
        // [LinphoneManager.instance setContactsUpdated:TRUE];
        frame.origin.x = allButton.frame.origin.x;
        [ContactSelection setSipFilter:nil];
        [ContactSelection enableEmailFilter:FALSE];
        allButton.selected = TRUE;
        linphoneButton.selected = FALSE;
        [tableController loadData];
    } else if (view == ContactsLinphone && !linphoneButton.selected) {
        /*
         * Wedo: ContactsLinphone mean to show only contacts downloaded from remote phonebook.
         * Those contacts have contact.nethesis at YES instead of NO.
         */
        NSString *searchText = [ContactSelection getNameOrEmailFilter];
        [LinphoneManager.instance.fastAddressBook resetNeth];
        if(![LinphoneManager.instance.fastAddressBook loadNeth:[self getSelectedPickerItem] withTerm:searchText]) {
            return;
        };
        frame.origin.x = linphoneButton.frame.origin.x;
        [ContactSelection setSipFilter:LinphoneManager.instance.contactFilter];
        [ContactSelection enableEmailFilter:FALSE];
        linphoneButton.selected = TRUE;
        allButton.selected = FALSE;
        // [tableController loadData];
    }
    bool sipFilter = [ContactSelection getSipFilter];
    [addButton setHidden:sipFilter];
    [tableController.deleteButton setHidden:sipFilter];
    [tableController.editButton setHidden:sipFilter];
    _selectedButtonImage.frame = frame;
    if ([LinphoneManager.instance lpConfigBoolForKey:@"hide_linphone_contacts" inSection:@"app"]) {
        allButton.selected = FALSE;
    }
}

- (void)onPhonebookPermissionRejection:(NSNotification *)notif {
    if ([notif.userInfo count] == 0){
        return;
    }
    
    long code = [[notif.userInfo valueForKey:@"code"] integerValue];
    NSString *message = @"";
    // Add more error codes with future remote permissions.
    switch (code) {
        case 2:
            message = NSLocalizedStringFromTable(@"Network connection unavailable", @"NethLocalizable", nil);
            break;
            
        case 401:
            message = NSLocalizedStringFromTable(@"Session expired. To see contacts you need to logout and login again.", @"NethLocalizable", nil);
            break;
            
        default:{
            NSString *errorMessage = [notif.userInfo valueForKey:@"message"];
            message = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Unknown authentication error. Contact your system administrator with a %ld error code and %@ message.", @"NethLocalizable", nil), code, errorMessage];
            break;
    }
    }
    
    UIAlertController *errView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Address book", nil)
                                                                     message:message
                                                              preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Continue", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [errView addAction:defaultAction];
    
    // Always run this UI action on main thread.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:errView animated:YES completion:^(void) {
            // Is this action always right?
            switch (code) {
                case 401:
                    [self changeView:ContactsAll];
                    break;
                    
                default:
                    break;
            }
        }];
    });
}

/// Set view buttons consistently to the sip filter mode selected.
- (void)refreshButtons {
    bool sipFilter = [ContactSelection getSipFilter];
    [addButton setHidden:sipFilter];
    [tableController.deleteButton setHidden:sipFilter];
    [tableController.editButton setHidden:sipFilter];
    [self changeView:sipFilter ? ContactsLinphone : ContactsAll];
}

#pragma mark - Action Functions

- (IBAction)onAllClick:(id)event {
    [self changeView:ContactsAll];
    [self resizeTableView:YES];
}

- (IBAction)onLinphoneClick:(id)event {
    [self changeView:ContactsLinphone];
    [self resizeTableView:YES];
}

- (IBAction)onAddContactClick:(id)event {
    if([ContactSelection getSipFilter]) {
        ContactDetailsViewNethesis *view = VIEW(ContactDetailsViewNethesis);
        [PhoneMainView.instance changeCurrentView:view.compositeViewDescription];
        view.isAdding = TRUE;
        if ([ContactSelection getAddAddress] == nil) {
            [view newContact];
        } else {
            [view newContact:[ContactSelection getAddAddress]];
        }
    } else {
        ContactDetailsView *view = VIEW(ContactDetailsView);
        [PhoneMainView.instance changeCurrentView:view.compositeViewDescription];
        view.isAdding = TRUE;
        if ([ContactSelection getAddAddress] == nil) {
            [view newContact];
        } else {
            [view newContact:[ContactSelection getAddAddress]];
        }
    }
}

- (IBAction)onDeleteClick:(id)sender {
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Do you want to delete selected contacts?\nThey will also be deleted from your phone's address book.", nil)];
    [LinphoneManager.instance setContactsUpdated:TRUE];
    [UIConfirmationDialog ShowWithMessage:msg
                            cancelMessage:nil
                           confirmMessage:nil
                            onCancelClick:^() {
        [self onEditionChangeClick:nil];
    }
                      onConfirmationClick:^() {
        [tableController removeSelectionUsing:nil];
        [tableController loadData];
        [self onEditionChangeClick:nil];
    }];
}

- (IBAction)onEditionChangeClick:(id)sender {
    allButton.hidden = linphoneButton.hidden = _selectedButtonImage.hidden = addButton.hidden = self.tableController.isEditing;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [self searchBar:searchBar textDidChange:@""];
    [LinphoneManager.instance setContactsUpdated:TRUE];
    [tableController loadData];
    [searchBar resignFirstResponder];
}

- (void)dismissKeyboards {
    if ([self.searchBar isFirstResponder]){
        [self.searchBar resignFirstResponder];
    }
}

#pragma mark - searchBar delegate

- (void)onAddressBookUpdate:(NSNotification *)k {
    // Allow again user interactions on search bar.
    dispatch_async(dispatch_get_main_queue(), ^{
        _searchBar.userInteractionEnabled = YES;
    });
}

- (void)performSearch {
    NSString * text = [ContactSelection getNameOrEmailFilter];
    [LinphoneManager.instance.fastAddressBook resetNeth];
    [LinphoneManager.instance setContactsUpdated:TRUE];
    if([LinphoneManager.instance.fastAddressBook loadNeth:[ContactSelection getPickerFilter] withTerm:text]) {
        // Deny any other input until search is finished.
        dispatch_async(dispatch_get_main_queue(), ^{
            _searchBar.userInteractionEnabled = NO;
        });
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [ContactSelection setNameOrEmailFilter:searchText];
    
    // WEDO: Perform the search api call after 0.5 seconds after finished input text.
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performSearch) object:nil];
    [self performSelector:@selector(performSearch) withObject:nil afterDelay:0.5];
    return;
    
    // display searchtext in UPPERCASE
    // searchBar.text = [searchText uppercaseString];
    
    if (searchText.length == 0) { // No filter, no search data.
        [LinphoneManager.instance setContactsUpdated:TRUE];
        [tableController loadData];
    } else {
        // Before loading searched data, we have to search them!
        [LinphoneManager.instance.fastAddressBook loadNeth:[ContactSelection getPickerFilter] withTerm:searchText];
        [tableController loadSearchedData];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:FALSE animated:TRUE];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:TRUE animated:TRUE];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - GestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return NO;
}

@end
