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

#import <UIKit/UIKit.h>

#import "UICompositeView.h"
#import "ContactsListTableView.h"
#import "UIInterfaceStyleButton.h"

typedef enum _ContactSelectionMode { ContactSelectionModeNone, ContactSelectionModeEdit } ContactSelectionMode;

@interface ContactSelection : NSObject <UISearchBarDelegate> {
}

+ (void)setSelectionMode:(ContactSelectionMode)selectionMode;
+ (ContactSelectionMode)getSelectionMode;
+ (void)setAddAddress:(NSString *)address;
+ (NSString *)getAddAddress;
/*!
 * Filters contacts by SIP domain.
 * @param domain SIP domain to filter. Use @"*" or nil to disable it.
 */
+ (void)setSipFilter:(NSString *)domain;

/*!
 * Weither contacts are filtered by SIP domain or not.
 * @return the filter used, or nil if none.
 */
+ (NSString *)getSipFilter;

/*!
 * Weither always keep contacts with an email address or not.
 * @param enable TRUE if you want to always keep contacts with an email.
 */
+ (void)enableEmailFilter:(BOOL)enable;

/*!
 * Weither always keep contacts with an email address or not.
 * @return TRUE if this behaviour is enabled.
 */
+ (BOOL)emailFilterEnabled;

/*!
 * Filters contacts by name and/or email fuzzy matching pattern.
 * @param fuzzyName fuzzy word to match. Use nil to disable it.
 */
+ (void)setNameOrEmailFilter:(NSString *)fuzzyName;

/*!
 * Weither contacts are filtered by name and/or email.
 * @return the filter used, or nil if none.
 */
+ (NSString *)getNameOrEmailFilter;

/*!
 * Filters contacts by name and/or email fuzzy matching pattern.
 * @param fuzzyName fuzzy word to match. Use nil to disable it.
 */
+ (void)setPickerFilter:(NSString *)value;

/*!
 * Weither contacts are filtered by name and/or email.
 * @return the filter used, or nil if none.
 */
+ (NSString *)getPickerFilter;

@end

@interface ContactsListView : UIViewController <UICompositeViewDelegate, UIGestureRecognizerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property(strong, nonatomic) IBOutlet ContactsListTableView *tableController;
@property(strong, nonatomic) IBOutlet UIView *topBar;
@property(nonatomic, strong) IBOutlet UIButton *allButton;
@property(nonatomic, strong) IBOutlet UIButton *linphoneButton; // sipButton in .xib file
@property(nonatomic, strong) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIInterfaceStyleButton *backSpaceButton;

@property (weak, nonatomic) IBOutlet UIInterfaceStyleButton *toggleSelectionButton;
@property (weak, nonatomic) IBOutlet UIPickerView *filterPicker;
@property (weak, nonatomic) IBOutlet UIView *searchBaseline;

- (IBAction)onAllClick:(id)event;
- (IBAction)onLinphoneClick:(id)event;
- (IBAction)onAddContactClick:(id)event;
- (IBAction)onDeleteClick:(id)sender;
- (IBAction)onEditionChangeClick:(id)sender;

- (IBAction)searchEditingChanged:(id)sender;
- (IBAction)onBackPressed:(id)sender;


@end
