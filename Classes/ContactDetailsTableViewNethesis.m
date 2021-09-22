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

#import "ContactDetailsTableViewNethesis.h"
#import "PhoneMainView.h"
#import "UIContactDetailsCell.h"
#import "Utils.h"
#import "OrderedDictionary.h"

#define allocWith(field) [[NSMutableArray alloc] initWithObjects:_contact.field, nil]

#define addressCell(field)

#define nonAddressCell(field) [cell setNonAddress:_contact.field]; \
                              return cell;

@implementation ContactDetailsTableViewNethesis

#pragma mark - Property Functions

- (NSMutableArray *)getSectionData:(NSInteger)section {
    // NewContactSections: Add here a row for new ContactSection.
    if (section == ContactSections_Number) {
        return _contact.phones;
    } else if (section == ContactSections_Sip) {
        return _contact.sipAddresses;
    } else if (section == ContactSections_Email) {
        BOOL showEmails = [LinphoneManager.instance lpConfigBoolForKey:@"show_contacts_emails_preference"];
        if (showEmails == true) {
            return _contact.emails;
        }
    }
    // Can you refactor this Linphone code?
    else if(section == ContactSections_Company && _contact.company.length > 0)
        return allocWith(company);
    else if(section == ContactSections_HomeLocationAddress && _contact.homeLocationAddress.length > 0)
        return allocWith(homeLocationAddress);
    else if(section == ContactSections_HomeLocationCity && _contact.homeLocationCity.length > 0)
        return allocWith(homeLocationCity);
    else if(section == ContactSections_HomeLocationState && _contact.homeLocationState.length > 0)
        return allocWith(homeLocationState);
    else if(section == ContactSections_HomeLocationCountry && _contact.homeLocationCountry.length > 0)
        return allocWith(homeLocationCountry);
    else if(section == ContactSections_Homepob && _contact.homePob.length > 0)
        return allocWith(homePob);
    else if(section == ContactSections_HomePostalCode && _contact.homePostalCode.length > 0)
        return allocWith(homePostalCode);
    else if(section == ContactSections_Notes && _contact.notes.length > 0)
        return allocWith(notes);
    else if(section == ContactSections_OwnerId && _contact.ownerId.length > 0)
        return allocWith(ownerId);
    else if(section == ContactSections_Source && _contact.source.length > 0)
        return allocWith(source);
    else if(section == ContactSections_SpeeddialNum && _contact.speeddialNum.length > 0)
        return allocWith(speeddialNum);
    else if(section == ContactSections_Title && _contact.title.length > 0)
        return allocWith(title);
    else if(section == ContactSections_Type && _contact.type.length > 0)
        return allocWith(type);
    else if(section == ContactSections_Url && _contact.url.length > 0)
        return allocWith(url);
    else if(section == ContactSections_Fax && _contact.fax.length > 0)
        return allocWith(fax);
    else if(section == ContactSections_WorkLocationAddress && _contact.workLocationAddress.length > 0)
        return allocWith(workLocationAddress);
    else if(section == ContactSections_WorkLocationCity && _contact.workLocationCity.length > 0)
        return allocWith(workLocationCity);
    else if(section == ContactSections_WorkLocationState && _contact.workLocationState.length > 0)
        return allocWith(workLocationState);
    else if(section == ContactSections_WorkLocationCountry && _contact.workLocationCountry.length > 0)
        return allocWith(workLocationCountry);
    else if(section == ContactSections_Workpob && _contact.workPob.length > 0)
        return allocWith(workPob);
    else if(section == ContactSections_WorkPostalCode && _contact.workPostalCode.length > 0)
        return allocWith(workPostalCode);
    
    // To hide section return this value.
    return nil;
}

- (void)removeEmptyEntry:(UITableView *)tableview section:(NSInteger)section animated:(BOOL)animated {
	NSMutableArray *sectionDict = [self getSectionData:section];
	for (NSInteger i = sectionDict.count - 1; i >= 0; i--) {
		NSString *value = sectionDict[i];
		if (value.length == 0) {
			[self removeEntry:tableview indexPath:[NSIndexPath indexPathForRow:i inSection:section] animated:animated];
		}
	}
}

- (void)removeEntry:(UITableView *)tableview indexPath:(NSIndexPath *)path animated:(BOOL)animated {
	bool rmed = YES;
	if (path.section == ContactSections_Number) {
		rmed = [_contact removePhoneNumberAtIndex:path.row];
	} else if (path.section == ContactSections_Sip) {
		rmed = [_contact removeSipAddressAtIndex:path.row];
	} else if (path.section == ContactSections_Email) {
		rmed = [_contact removeEmailAtIndex:path.row];
    } else {
		rmed = NO;
	}

	if (rmed) {
		[tableview deleteRowsAtIndexPaths:@[ path ]
						 withRowAnimation:animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone];
	} else {
		LOGW(@"Cannot remove entry at path %@, skipping", path);
	}
}

- (void)addEntry:(UITableView *)tableview section:(NSInteger)section animated:(BOOL)animated value:(NSString *)value {
    bool added = FALSE;
    if (section == ContactSections_Number) {
        if ([_contact.phones count] == [_contact.person.phoneNumbers count])
            added = [_contact addPhoneNumber:value];
    } else if (section == ContactSections_Sip) {
        if ([_contact.sipAddresses count] == [self countSipAddressFromCNContact:_contact.person]) //[_contact.person.instantMessageAddresses count])
            added = [_contact addSipAddress:value];
    } else if (section == ContactSections_Email) {
        if ([_contact.emails count] ==
            [_contact.person.emailAddresses count])
            added = [_contact addEmail:value];
    }
    if (added) {
        NSUInteger count = [self getSectionData:section].count;
        [tableview
         insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:count - 1
                                                      inSection:section] ]
         withRowAnimation:animated ? UITableViewRowAnimationFade
         : UITableViewRowAnimationNone];
    } else {
        LOGW(@"Cannot add entry '%@' in section %d, skipping", value,
             section);
    }
}

-(NSInteger)countSipAddressFromCNContact:(CNContact*) mCNContact{
	NSInteger count = 0;
	if (mCNContact.instantMessageAddresses != NULL) {
		for (CNLabeledValue<CNInstantMessageAddress *> *sipAddr in mCNContact.instantMessageAddresses) {
			if ([FastAddressBook isSipAddress:sipAddr])
				count++;
		}
	}
	return count;
}

- (void)setContact:(Contact *)acontact {
    // if (acontact == _contact)
    //	return;
    _contact = acontact;
    [self loadData];
}

- (void)addPhoneField:(NSString *)number {
	ContactSections i = 0;
	while (i != ContactSections_MAX && i != ContactSections_Number)
		++i;
	[self addEntry:[self tableView] section:i animated:FALSE value:number];
}

- (void)addSipField:(NSString *)address {
	ContactSections i = 0;
	while (i != ContactSections_MAX && i != ContactSections_Sip)
		++i;
	[self addEntry:[self tableView] section:i animated:FALSE value:address];
}

- (void)addEmailField:(NSString *)address {
	ContactSections i = 0;
	while (i != ContactSections_MAX && i != ContactSections_Email)
		++i;
	[self addEntry:[self tableView] section:i animated:FALSE value:address];
}

- (BOOL)isValid {
	BOOL hasName = (_contact.firstName.length + _contact.lastName.length > 0);
        BOOL hasAddr =
            (_contact.phones.count + _contact.sipAddresses.count) > 0;
        return hasName && hasAddr;
}

#pragma mark - UITableViewDataSource Functions

- (void)loadData {
	[self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return ContactSections_MAX;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // NewContactSections: Add here a row for new ContactSection.
    if (section == ContactSections_FirstName ||
        section == ContactSections_LastName ||
        (section == ContactSections_Company && _contact.company.length)) {
        // Those fields are only editable.
        return (self.tableView.isEditing) ? 1 : 0;
    } else if (section == ContactSections_Sip) {
        return _contact.sipAddresses.count;
    } else if (section == ContactSections_Number) {
        return _contact.phones.count;
    } else if (section == ContactSections_Email) {
        BOOL showEmails = [LinphoneManager.instance
                           lpConfigBoolForKey:@"show_contacts_emails_preference"];
        return showEmails ? _contact.emails.count : 0;
    } else if((section == ContactSections_HomeLocationAddress && _contact.homeLocationAddress.length > 0) ||
              (section == ContactSections_HomeLocationCity && _contact.homeLocationCity.length > 0) ||
              (section == ContactSections_HomeLocationState && _contact.homeLocationState.length > 0) ||
              (section == ContactSections_HomeLocationCountry && _contact.homeLocationCountry.length > 0) ||
              (section == ContactSections_Homepob && _contact.homePob.length > 0) ||
              (section == ContactSections_HomePostalCode && _contact.homePostalCode.length > 0) ||
              (section == ContactSections_Notes &&_contact.notes.length > 0) ||
              (section == ContactSections_SpeeddialNum &&_contact.speeddialNum.length > 0) ||
              (section == ContactSections_Title && _contact.title.length > 0) ||
              (section == ContactSections_Type && _contact.type.length > 0) ||
              (section == ContactSections_Url && _contact.url.length > 0) ||
              (section == ContactSections_Fax && _contact.fax.length > 0) ||
              (section == ContactSections_WorkLocationAddress && _contact.workLocationAddress.length > 0) ||
              (section == ContactSections_WorkLocationCity && _contact.workLocationCity.length > 0) ||
              (section == ContactSections_WorkLocationState && _contact.workLocationState.length > 0) ||
              (section == ContactSections_WorkLocationCountry && _contact.workLocationCountry.length > 0) ||
              (section == ContactSections_Workpob && _contact.workPob.length > 0) ||
              (section == ContactSections_WorkPostalCode && _contact.workPostalCode.length > 0)) {
        return 1;
    } else if((section == ContactSections_OwnerId && _contact.ownerId.length > 0) ||
              (section == ContactSections_Source && _contact.source.length > 0)) {
        // Those fields are not editable.
        return self.tableView.isEditing ? 0 : 1;
    }
    
    return 0; // The section doesn't show any row.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellId = @"UIContactDetailsCell";
    UIContactDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (cell == nil) {
        cell = [[UIContactDetailsCell alloc] initWithIdentifier:kCellId];
        cell.waitView = _waitView;
        [cell.editTextfield setDelegate:self];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.userInteractionEnabled = false;
    
    cell.indexPath = indexPath;
    [cell hideDeleteButton:NO];
    [cell.editTextfield setKeyboardType:UIKeyboardTypeDefault];
    NSString *value = @"";
    NSInteger section = indexPath.section;
    // NewContactSections: Add here a row for new ContactSection.
    if (section == ContactSections_FirstName) {
        value = _contact.firstName;
        [cell hideDeleteButton:YES];
    } else if (section == ContactSections_LastName) {
        value = _contact.lastName;
        [cell hideDeleteButton:YES];
    } else if (section == ContactSections_Number) {
        value = _contact.phones[indexPath.row];
        [cell.editTextfield setKeyboardType:UIKeyboardTypePhonePad];
    } else if (section == ContactSections_Sip) {
        value = _contact.sipAddresses[indexPath.row];
        LinphoneAddress *addr = NULL;
        if ([LinphoneManager.instance
             lpConfigBoolForKey:@"contact_display_username_only"] &&
            (addr = linphone_core_interpret_url(LC, [value UTF8String]))) {
            value =
            [NSString stringWithCString:linphone_address_get_username(addr)
                               encoding:[NSString defaultCStringEncoding]];
            linphone_address_destroy(addr);
        }
        [cell.editTextfield setKeyboardType:UIKeyboardTypeASCIICapable];
    } else if (section == ContactSections_Email) {
        value = _contact.emails[indexPath.row];
        [cell.editTextfield setKeyboardType:UIKeyboardTypeEmailAddress];
    } else if(section == ContactSections_Company) {
        nonAddressCell(company);
    } else if(section == ContactSections_HomeLocationAddress) {
        nonAddressCell(homeLocationAddress);
    } else if(section == ContactSections_HomeLocationCity) {
        nonAddressCell(homeLocationCity);
    } else if(section == ContactSections_HomeLocationState) {
        nonAddressCell(homeLocationState);
    } else if(section == ContactSections_HomeLocationCountry) {
        nonAddressCell(homeLocationCountry);
    } else if(section == ContactSections_Homepob) {
        nonAddressCell(homePob);
    } else if(section == ContactSections_HomePostalCode) {
        nonAddressCell(homePostalCode);
    } else if(section == ContactSections_Notes) {
        nonAddressCell(notes);
    } else if(section == ContactSections_OwnerId) {
        nonAddressCell(ownerId);
    } else if(section == ContactSections_Source) {
        nonAddressCell(source);
    } else if(section == ContactSections_SpeeddialNum) {
        nonAddressCell(speeddialNum);
    } else if(section == ContactSections_Title) {
        nonAddressCell(title);
    } else if(section == ContactSections_Type) {
        nonAddressCell(type);
    } else if(section == ContactSections_Fax) {
        nonAddressCell(fax);
    } else if(section == ContactSections_Url) {
        nonAddressCell(url);
    } else if(section == ContactSections_WorkLocationAddress) {
        nonAddressCell(workLocationAddress);
    } else if(section == ContactSections_WorkLocationCity) {
        nonAddressCell(workLocationCity);
    } else if(section == ContactSections_WorkLocationState) {
        nonAddressCell(workLocationState);
    } else if(section == ContactSections_WorkLocationCountry) {
        nonAddressCell(workLocationCountry);
    } else if(section == ContactSections_Workpob) {
        nonAddressCell(workPob);
    } else if(section == ContactSections_WorkPostalCode) {
        nonAddressCell(workPostalCode);
    }
    
    if ([value hasPrefix:@" "])
        value = [value substringFromIndex:1];
    [cell setAddress:value];
    return cell;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    [LinphoneUtils findAndResignFirstResponder:[self tableView]];
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        [tableView beginUpdates];
        [self addEntry:tableView
               section:[indexPath section]
              animated:TRUE
                 value:@" "];
        [tableView endUpdates];
    } else if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        [self removeEntry:tableView indexPath:indexPath animated:TRUE];
        [tableView endUpdates];
    }
}

#pragma mark - UITableViewDelegate Functions

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	BOOL showEmails = [LinphoneManager.instance lpConfigBoolForKey:@"show_contacts_emails_preference"];
	if (editing) {
		// add phone/SIP/email entries so that the user can add new data
		for (int section = 0; section < [self numberOfSectionsInTableView:[self tableView]]; ++section) {
			if (section == ContactSections_Number || section == ContactSections_Sip ||
				(showEmails && section == ContactSections_Email)) {
				[self addEntry:self.tableView section:section animated:animated value:@""];
			}
		}
		_editButton.enabled = [self isValid];
	} else {
		[LinphoneUtils findAndResignFirstResponder:[self tableView]];
		// remove empty phone numbers
		for (int section = 0; section < [self numberOfSectionsInTableView:[self tableView]]; ++section) {
			// remove phony entries that were not filled by the user
			if (section == ContactSections_Number || section == ContactSections_Sip ||
				(showEmails && section == ContactSections_Email)) {

				[self removeEmptyEntry:self.tableView section:section animated:NO];
			}
		}
		_editButton.enabled = YES;
	}
	// order is imported here: empty rows must be deleted before table change editing mode
	[super setEditing:editing animated:animated];

	[self loadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *text = nil;
    BOOL canAddEntry = self.tableView.isEditing;
    NSString *addEntryName = nil;
    BOOL sectionHasRows = [self getSectionData:section].count > 0;
    // NewContactSections: Add here a row for new ContactSection.
    if (section == ContactSections_FirstName && self.tableView.isEditing) {
        text = NSLocalizedString(@"First name", nil);
        canAddEntry = NO;
    } else if (section == ContactSections_LastName && self.tableView.isEditing) {
        text = NSLocalizedString(@"Last name", nil);
        canAddEntry = NO;
    } else if(section == ContactSections_Company && self.tableView.isEditing) {
        text = NSLocalizedStringFromTable(@"Company", @"NethLocalizable", @"");
        canAddEntry = NO;
    } else if (sectionHasRows || self.tableView.isEditing) {
        // Show those editable fields section titles.
        if (section == ContactSections_Number) {
            text = NSLocalizedString(@"Phone numbers", nil);
            addEntryName = NSLocalizedString(@"Add new phone number", nil);
        } else if (section == ContactSections_Sip) {
            text = NSLocalizedStringFromTable(@"Extension", @"NethLocalizable", @"");
            addEntryName = NSLocalizedString(@"Add new SIP address", nil);
        } else if (section == ContactSections_Email &&
                   [LinphoneManager.instance lpConfigBoolForKey:@"show_contacts_emails_preference"]) {
            text = NSLocalizedString(@"Email addresses", nil);
            addEntryName = NSLocalizedString(@"Add new email", nil);
        } else if(section == ContactSections_HomeLocationAddress) {
            text = NSLocalizedStringFromTable(@"Home address", @"NethLocalizable", @"");
            canAddEntry = NO;
        } else if(section == ContactSections_HomeLocationCity) {
            text = NSLocalizedStringFromTable(@"Home city", @"NethLocalizable", @"");
            canAddEntry = NO;
        } else if(section == ContactSections_HomeLocationState) {
            text = NSLocalizedStringFromTable(@"Home state", @"NethLocalizable", @"");
            canAddEntry = NO;
        } else if(section == ContactSections_HomeLocationCountry) {
            text = NSLocalizedStringFromTable(@"Home country", @"NethLocalizable", @"");
            canAddEntry = NO;
        } else if(section == ContactSections_Homepob) {
            text = NSLocalizedStringFromTable(@"Home pob", @"NethLocalizable", @"");
            canAddEntry = NO;
        } else if(section == ContactSections_HomePostalCode) {
            text = NSLocalizedStringFromTable(@"Home Postal Code", @"NethLocalizable", @"");
            canAddEntry = NO;
        } else if(section == ContactSections_Notes) {
            text = NSLocalizedStringFromTable(@"Notes", @"NethLocalizable", @"");
            canAddEntry = NO;
        } else if(section == ContactSections_OwnerId && !self.tableView.isEditing) { // Owner id isn't editable.
            text = NSLocalizedStringFromTable(@"Created by", @"NethLocalizable", @"");
            canAddEntry = NO;
        } else if(section == ContactSections_Source && !self.tableView.isEditing) { // Source isn't editable.
            text = NSLocalizedStringFromTable(@"Source", @"NethLocalizable", @"");
            canAddEntry = NO;
        } else if(section == ContactSections_SpeeddialNum) {
            text = NSLocalizedStringFromTable(@"SpeeddialNum", @"NethLocalizable", @"");
            canAddEntry = NO;
        } else if(section == ContactSections_Title) {
            text = NSLocalizedStringFromTable(@"Title", @"NethLocalizable", @"");
            canAddEntry = NO;
        } else if(section == ContactSections_Type) {
            text = NSLocalizedStringFromTable(@"Type", @"NethLocalizable", @"");
            canAddEntry = NO;
        } else if(section == ContactSections_Url) {
            text = NSLocalizedStringFromTable(@"Url", @"NethLocalizable", @"");
            canAddEntry = NO;
        } else if(section == ContactSections_Fax) {
            text = NSLocalizedStringFromTable(@"Fax", @"NethLocalizable", @"");
            canAddEntry = NO;
        } else if(section == ContactSections_WorkLocationAddress) {
            text = NSLocalizedStringFromTable(@"Work address", @"NethLocalizable", @"");
            canAddEntry = NO;
        } else if(section == ContactSections_WorkLocationCity) {
            text = NSLocalizedStringFromTable(@"Work city", @"NethLocalizable", @"");
            canAddEntry = NO;
        } else if(section == ContactSections_WorkLocationState) {
            text = NSLocalizedStringFromTable(@"Work state", @"NethLocalizable", @"");
            canAddEntry = NO;
        } else if(section == ContactSections_WorkLocationCountry) {
            text = NSLocalizedStringFromTable(@"Work country", @"NethLocalizable", @"");
            canAddEntry = NO;
        } else if(section == ContactSections_Workpob) {
            text = NSLocalizedStringFromTable(@"Work pob", @"NethLocalizable", @"");
            canAddEntry = NO;
        } else if(section == ContactSections_WorkPostalCode) {
            text = NSLocalizedStringFromTable(@"Work Postal Code", @"NethLocalizable", @"");
            canAddEntry = NO;
        }
    }
    
    if (!text) {
        return nil;
    }
    
    CGRect frame = CGRectMake(0, 0, tableView.frame.size.width, 40);
    UIView *tempView = [[UIView alloc] initWithFrame:frame];
    if (@available(iOS 13, *)) {
        tempView.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        tempView.backgroundColor = [UIColor whiteColor];
    }
    
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 1)];
    border.backgroundColor = tableView.separatorColor;
    [tempView addSubview:border];
    
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, tableView.frame.size.width, 35)];
    tempLabel.backgroundColor = [UIColor clearColor];
    tempLabel.textColor = [UIColor getColorByName:@"MainColor"];
    tempLabel.text = text;
    tempLabel.textAlignment = NSTextAlignmentCenter;
    tempLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:15];
    tempLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [tempView addSubview:tempLabel];
    
    if (canAddEntry) {
        frame.origin.x = (tableView.frame.size.width - 30 /*image size*/) / 2 - 5 /*right offset*/;
        UIIconButton *tempAddButton = [[UIIconButton alloc] initWithFrame:frame];
        [tempAddButton setImage:[UIImage imageNamed:@"add_field_default.png"] forState:UIControlStateNormal];
        [tempAddButton setImage:[UIImage imageNamed:@"add_field_over.png"] forState:UIControlStateHighlighted];
        [tempAddButton setImage:[UIImage imageNamed:@"add_field_over.png"] forState:UIControlStateSelected];
        [tempAddButton addTarget:self action:@selector(onAddClick:) forControlEvents:UIControlEventTouchUpInside];
        tempAddButton.tag = section;
        tempAddButton.accessibilityLabel = addEntryName;
        tempAddButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [tempView addSubview:tempAddButton];
    }
    
    return tempView;
}

- (void)onAddClick:(id)sender {
	NSInteger section = ((UIButton *)sender).tag;
	UITableView *tableView = VIEW(ContactDetailsViewNethesis).tableController.tableView;
	NSInteger count = [self.tableView numberOfRowsInSection:section];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count inSection:section];
	[tableView.dataSource tableView:tableView
				 commitEditingStyle:UITableViewCellEditingStyleInsert
				  forRowAtIndexPath:indexPath];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
		   editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView.isEditing) {
        return 44;
    }
    UIContactDetailsCell *cell = (UIContactDetailsCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString * myString = cell.addressLabel.text;
    NSArray *list = [myString componentsSeparatedByString:@"\n"];
    /*
     [WEDO] TODO: Change here the height of the note cell.
     NSLog(@"No of lines : %lu", (unsigned long)[list count]);
     */
    return [list count] > 1 ? 88 : 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 1e-5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0 ||
		(!self.tableView.isEditing && (section == ContactSections_FirstName || section == ContactSections_LastName || section == ContactSections_Company))) {
		return 1e-5;
	}
    
    UIView *header = [self tableView:tableView viewForHeaderInSection:section];
    CGFloat height = header.frame.size.height;
	return height;
}

#pragma mark - UITextFieldDelegate Functions

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldUpdated:(UITextField *)textField {
    UIView *view = [textField superview];
    while (view != nil && ![view isKindOfClass:[UIContactDetailsCell class]])
        view = [view superview];
    if (view != nil) {
        UIContactDetailsCell *cell = (UIContactDetailsCell *)view;
        // we cannot use indexPathForCell method here because if the cell is not visible anymore,
        // it will return nil..
        NSIndexPath *path = [self.tableView indexPathForCell:cell]; // [self.tableView indexPathForCell:cell];
        ContactSections sect = (ContactSections)[path section];
        NSString *value = [textField text];
        
        // NewContactSections: Add here a row for new ContactSection.
        switch (sect) {
            case ContactSections_FirstName:
                _contact.firstName = value;
                break;
            case ContactSections_LastName:
                _contact.lastName = value;
                break;
            case ContactSections_Sip:
                [_contact setSipAddress:value atIndex:path.row];
                value = _contact.sipAddresses[path.row]; // in case of reformatting
                break;
            case ContactSections_Email:
                [_contact setEmail:value atIndex:path.row];
                value = _contact.emails[path.row]; // in case of reformatting
                break;
            case ContactSections_Number:
                [_contact setPhoneNumber:value atIndex:path.row];
                value = _contact.phones[path.row]; // in case of reformatting
                break;
            case ContactSections_Company:
                _contact.company = value;
                break;
            case ContactSections_HomeLocationAddress:
                _contact.homeLocationAddress = value;
                break;
            case ContactSections_HomeLocationCity:
                _contact.homeLocationCity = value;
                break;
            case ContactSections_HomeLocationState:
                _contact.homeLocationState = value;
                break;
            case ContactSections_HomeLocationCountry:
                _contact.homeLocationCountry = value;
                break;
            case ContactSections_Homepob:
                _contact.homePob = value;
                break;
            case ContactSections_HomePostalCode:
                _contact.homePostalCode = value;
                break;
            case ContactSections_Notes:
                _contact.notes = value;
                break;
            case ContactSections_OwnerId:
                _contact.ownerId = value;
                break;
            case ContactSections_Source:
                _contact.source = value;
                break;
            case ContactSections_SpeeddialNum:
                _contact.speeddialNum = value;
                break;
            case ContactSections_Title:
                _contact.title = value;
                break;
            case ContactSections_Type:
                _contact.type = value;
                break;
            case ContactSections_Fax:
                _contact.fax = value;
                break;
            case ContactSections_Url:
                _contact.url = value;
                break;
            case ContactSections_WorkLocationAddress:
                _contact.workLocationAddress = value;
                break;
            case ContactSections_WorkLocationCity:
                _contact.workLocationCity = value;
                break;
            case ContactSections_WorkLocationState:
                _contact.workLocationState = value;
                break;
            case ContactSections_WorkLocationCountry:
                _contact.workLocationCountry = value;
                break;
            case ContactSections_Workpob:
                _contact.workPob = value;
                break;
            case ContactSections_WorkPostalCode:
                _contact.workPostalCode = value;
                break;
            case ContactSections_MAX:
            case ContactSections_None:
                break;
        }
        cell.editTextfield.text = value;
        _editButton.enabled = [self isValid];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[self textFieldUpdated:textField];
        // TODO reload current contact
}

- (BOOL)textField:(UITextField *)textField
	shouldChangeCharactersInRange:(NSRange)range
				replacementString:(NSString *)string {
#if 0
	// every time we modify contact entry, we must check if we can enable "edit" button
	UIView *view = [textField superview];
	while (view != nil && ![view isKindOfClass:[UIContactDetailsCell class]])
		view = [view superview];

	UIContactDetailsCell *cell = (UIContactDetailsCell *)view;
	// we cannot use indexPathForCell method here because if the cell is not visible anymore,
	// it will return nil..
	NSIndexPath *path = cell.indexPath;

	_editButton.enabled = NO;
	for (ContactSections s = ContactSections_Sip; !_editButton.enabled && s <= ContactSections_Number; s++) {
		for (int i = 0; !_editButton.enabled && i < [self tableView:self.tableView numberOfRowsInSection:s]; i++) {
			NSIndexPath *cellpath = [NSIndexPath indexPathForRow:i inSection:s];
			if ([cellpath isEqual:path]) {
				_editButton.enabled = (textField.text.length > 0);
			} else {
				UIContactDetailsCell *cell =
					(UIContactDetailsCell *)[self tableView:self.tableView cellForRowAtIndexPath:cellpath];
				_editButton.enabled = (cell.editTextfield.text.length > 0);
			}
		}
	}
#else
	[self textFieldUpdated:textField];
#endif
	return YES;
}

@end
