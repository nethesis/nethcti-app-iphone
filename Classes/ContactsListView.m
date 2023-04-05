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

#import "linphoneapp-Swift.h"
#import "PhoneMainView.h"

@implementation ContactSelection

static ContactSelectionMode sSelectionMode = ContactSelectionModeNone;
static NSString *sAddAddress = nil;
static BOOL bSipFilterEnabled = FALSE;
static NSString *sSipFilter = nil;
static BOOL addAddressFromOthers = FALSE;

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

+ (void)enableSipFilter:(BOOL)enabled {
	bSipFilterEnabled = enabled;
}

+ (BOOL)getSipFilterEnabled {
	return bSipFilterEnabled;
}

@end

@implementation ContactsListView

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
														   fragmentWith:ContactDetailsView.class];
	}
	return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
	return self.class.compositeViewDescription;
}

#pragma mark - ViewController Functions

- (void)viewDidLoad {
	NSLog(@"Debuglog viewDidLoad");
	[super viewDidLoad];
	_searchField.text = [MagicSearchSingleton.instance currentFilter];
	tableController.tableView.accessibilityIdentifier = @"Contacts table";
    [tableController.tableView setContentInset:UIEdgeInsetsMake(-44, 0, 0, 0)];
	
	if (![[PhoneMainView.instance  getPreviousViewName] isEqualToString:@"ContactDetailsView"]) {
        _searchField.text = @"";
	}
	[self changeView:ContactsAll];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
								   initWithTarget:self
								   action:@selector(dismissKeyboards)];
	
	[tap setDelegate:self];
	[self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated {
	
	NSLog(@"Debuglog viewWillAppear");
	[super viewWillAppear:animated];

	int y = _searchField.frame.origin.y + _searchField.frame.size.height;
	[tableController.tableView setFrame:CGRectMake(tableController.tableView.frame.origin.x,
												   y,
												   tableController.tableView.frame.size.width,
												   tableController.tableView.frame.size.height)];
	[tableController.emptyView setFrame:CGRectMake(tableController.emptyView.frame.origin.x,
												   y,
												   tableController.emptyView.frame.size.width,
												   tableController.emptyView.frame.size.height)];

	if (tableController.isEditing) {
		tableController.editing = NO;
	}
	[self refreshButtons];
	[_toggleSelectionButton setImage:[UIImage imageNamed:@"select_all_default.png"] forState:UIControlStateSelected];
	if ([LinphoneManager.instance lpConfigBoolForKey:@"hide_linphone_contacts" inSection:@"app"]) {
		self.linphoneButton.hidden = TRUE;
	}
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(onMagicSearchStarted:)
	 name:kLinphoneMagicSearchStarted
	 object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(onMagicSearchFinished:)
	 name:kLinphoneMagicSearchFinished
	 object:nil];
}

- (void)onMagicSearchStarted:(NSNotification *)k {
	//_loadingView.hidden = FALSE;
}
- (void)onMagicSearchFinished:(NSNotification *)k {
	//_loadingView.hidden = TRUE;
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"Debuglog viewDidAppear");
	[super viewDidAppear:animated];
	if (![FastAddressBook isAuthorized]) {
		UIAlertController *errView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Address book", nil)
																		 message:NSLocalizedString(@"You must authorize the application to have access to address book.\n"
																								   "Toggle the application in Settings > Privacy > Contacts",
																								   nil)
																  preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Continue", nil)
																style:UIAlertActionStyleDefault
															  handler:^(UIAlertAction * action) {}];
		
		[errView addAction:defaultAction];
		[self presentViewController:errView animated:YES completion:nil];
		[PhoneMainView.instance popCurrentView];
	}
	
	// show message toast when add contact from address
	if ([ContactSelection getAddAddress] != nil && addAddressFromOthers) {
		UIAlertController *infoView = [UIAlertController
									   alertControllerWithTitle:NSLocalizedString(@"Info", nil)
									   message:NSLocalizedString(@"Select a contact or create a new one.",nil)
									   preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
																style:UIAlertActionStyleDefault
															  handler:^(UIAlertAction *action){
															  }];
		
		[infoView addAction:defaultAction];
		addAddressFromOthers = FALSE;
		[PhoneMainView.instance presentViewController:infoView animated:YES completion:nil];
	}
}

- (void) viewWillDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.view = NULL;
	[self.tableController removeAllContacts];
}

#pragma mark -

- (void)changeView:(ContactsCategory)view {
	NSLog(@"Debuglog changeView");
	if (view == ContactsAll && !allButton.selected) {
		//REQUIRED TO RELOAD WITH FILTER
		[LinphoneManager.instance setContactsUpdated:TRUE];
		[ContactSelection enableSipFilter:FALSE];
		allButton.selected = TRUE;
		linphoneButton.selected = FALSE;
		[tableController setReloadMagicSearch:TRUE];
		[tableController loadDataWithFilter: _searchField.text];
	} else if (view == ContactsLinphone && !linphoneButton.selected) {
		//REQUIRED TO RELOAD WITH FILTER
		[LinphoneManager.instance setContactsUpdated:TRUE];
		[ContactSelection enableSipFilter:TRUE];
		linphoneButton.selected = TRUE;
		allButton.selected = FALSE;
		[tableController setReloadMagicSearch:TRUE];
		[tableController loadDataWithFilter: _searchField.text];
	}
	if ([LinphoneManager.instance lpConfigBoolForKey:@"hide_linphone_contacts" inSection:@"app"]) {
		allButton.selected = FALSE;
	}
}

- (void)refreshButtons {
	[addButton setHidden:FALSE];
	[self changeView:[ContactSelection getSipFilterEnabled] ? ContactsLinphone : ContactsAll];
}

#pragma mark - Action Functions

- (IBAction)onAllClick:(id)event {
	[self changeView:ContactsAll];
}

- (IBAction)onLinphoneClick:(id)event {
	[self changeView:ContactsLinphone];
}

- (IBAction)onAddContactClick:(id)event {
	ContactDetailsView *view = VIEW(ContactDetailsView);
	[PhoneMainView.instance changeCurrentView:view.compositeViewDescription];
	view.isAdding = TRUE;
	if ([ContactSelection getAddAddress] == nil) {
		[view newContact];
	} else {
		[view newContact:[ContactSelection getAddAddress]];
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
    allButton.hidden = linphoneButton.hidden = addButton.hidden = self.tableController.isEditing;
}

- (void)dismissKeyboards {
	if ([self.searchField isFirstResponder]){
		[self.searchField resignFirstResponder];
	}
}

- (IBAction)onBackPressed:(id)sender {
    if ([_searchField.text length] > 0) {
        [_searchField setText:[_searchField.text substringToIndex:[_searchField.text length] - 1]];
    }
    
    [self searchEditingChanged:(id)nil];
}

- (IBAction)searchEditingChanged:(id)sender {
    
    NSString* searchText = _searchField.text;
    
    if (![searchText isEqualToString:[MagicSearchSingleton.instance currentFilter]]) {
        if (searchText.length == 0) {
            [LinphoneManager.instance setContactsUpdated:TRUE];
        }
        [tableController loadDataWithFilter:searchText];
    }
}

#pragma mark - GestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	return NO;
}

@end
