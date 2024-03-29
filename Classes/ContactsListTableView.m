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

#import "ContactsListTableView.h"
#import "UIContactCell.h"
#import "LinphoneManager.h"
#import "PhoneMainView.h"
#import "Utils.h"
#import "linphoneApp-Swift.h"

@implementation ContactsListTableView
NSArray *sortedAddresses;
int rowHeight = 70;

#pragma mark - Lifecycle Functions

- (void)initContactsTableViewController {
    addressBookMap = [[OrderedDictionary alloc] init];
    sortedAddresses = [[NSArray alloc] init];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(onAddressBookUpdate:)
                                               name:kLinphoneAddressBookUpdate
                                             object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAddressBookUpdate:)
                                                 name:CNContactStoreDidChangeNotification
                                               object:nil];
}

- (void)onAddressBookUpdate:(NSNotification *)k {
    if ((!_ongoing && (PhoneMainView.instance.currentView == ContactsListView.compositeViewDescription)) ||
        (IPAD &&
         (PhoneMainView.instance.currentView == ContactDetailsView.compositeViewDescription ||
          PhoneMainView.instance.currentView == ContactDetailsViewNethesis.compositeViewDescription))) {
        [self loadData];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (IPAD && ![self selectFirstRow])
        [self setNilContact];
}

- (id)init {
    self = [super init];
    if (self) {
        [self initContactsTableViewController];
    }
    _ongoing = FALSE;
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        [self initContactsTableViewController];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeAllContacts];
}

- (void)removeAllContacts {
    for (NSInteger j = 0; j < [self.tableView numberOfSections]; ++j) {
        for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:j]; ++i) {
            [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]] setContact:nil];
        }
    }
}

#pragma mark -

static int ms_strcmpfuz(const char *fuzzy_word, const char *sentence) {
    if (!fuzzy_word || !sentence) {
        return fuzzy_word == sentence;
    }
    const char *c = fuzzy_word;
    const char *within_sentence = sentence;
    for (; c != NULL && *c != '\0' && within_sentence != NULL; ++c) {
        within_sentence = strchr(within_sentence, *c);
        // Could not find c character in sentence. Abort.
        if (within_sentence == NULL) {
            break;
        }
        // since strchr returns the index of the matched char, move forward
        within_sentence++;
    }

    // If the whole fuzzy was found, returns 0. Otherwise returns number of characters left.
    return (int)(within_sentence != NULL ? 0 : fuzzy_word + strlen(fuzzy_word) - c);
}

- (NSString *)displayNameForContact:(Contact *)person {
    NSString *name = person.displayName;
    if (name != nil && [name length] > 0 && ![name isEqualToString:NSLocalizedString(@"Unknown", nil)]) {
        // Add the contact only if it fuzzy match filter too (if any)
        if ([ContactSelection getNameOrEmailFilter] == nil ||
            (ms_strcmpfuz([[[ContactSelection getNameOrEmailFilter] lowercaseString] UTF8String],
                          [[name lowercaseString] UTF8String]) == 0)) {

            // Sort contacts by first letter. We need to translate the name to ASCII first, because of UTF-8
            // issues. For instance expected order would be:  Alberta(A tilde) before ASylvano.
            NSData *name2ASCIIdata = [name dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            NSString *name2ASCII = [[NSString alloc] initWithData:name2ASCIIdata encoding:NSASCIIStringEncoding];
            return name2ASCII;
        }
    }
    return nil;
}

/// Load data from addressBookMap and show them filtered.
/// Don't refuse this with the fetchRemoteContactsmethod, that populate the addressBookMap.
- (void)loadData {
    LOGI(@"====>>>> Load contact list - Start");
    _ongoing = TRUE;
    NSString* previous = [PhoneMainView.instance getPreviousViewName];
    addressBookMap = [LinphoneManager.instance getLinphoneManagerAddressBookMap];
    OrderedDictionary *myMap = [[OrderedDictionary alloc] initWithDictionary:addressBookMap copyItems:YES];
    BOOL updated = [LinphoneManager.instance getContactsUpdated];
    
    if (([previous isEqualToString:@"ContactsDetailsView"] && updated) || updated || [myMap count] == 0) {
        // Here contacts are updated.
        [LinphoneManager.instance setContactsUpdated:FALSE];
        
        @synchronized(myMap) {
            NSDictionary *allContacts = [[NSMutableDictionary alloc] initWithDictionary:LinphoneManager.instance.fastAddressBook.addressBookMap];
            // Those are only sip addresses sorted by first and last name.
            sortedAddresses = [ContactSelection getSipFilter] && ![[ContactSelection getNameOrEmailFilter] isEqual: @""] ? [LinphoneManager.instance.fastAddressBook.addressBookMap allKeys] :
            [[LinphoneManager.instance.fastAddressBook.addressBookMap allKeys] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                Contact* first =  [allContacts objectForKey:a];
                Contact* second =  [allContacts objectForKey:b];
                NSString * firstName = [[self displayNameForContact:first] lowercaseString];
                NSString * secondName = [[self displayNameForContact:second] lowercaseString];
                NSComparisonResult result = [firstName compare:secondName];
                if(result != NSOrderedSame)
                    return result;
                return [[first.lastName lowercaseString] compare:[second.lastName lowercaseString]];
            }];
            
            LOGI(@"====>>>> Load contact list - Start 2 !!");
            // Set all contacts from ContactCell to nil
            dispatch_async(dispatch_get_main_queue(), ^{
                
                for (NSInteger j = 0; j < [self.tableView numberOfSections]; ++j) {
                    
                    for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:j]; ++i) {
                        [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]] setContact:nil];
                    }
                }
            });
            LOGI(@"====>>>> Load contact list - Start 3 !!");
            
            // Reset Address book
            [myMap removeAllObjects];
            
            for (NSString *addr in sortedAddresses) {
                Contact *contact = nil;
                
                @synchronized(LinphoneManager.instance.fastAddressBook.addressBookMap) {
                    contact = [LinphoneManager.instance.fastAddressBook.addressBookMap objectForKey:addr];
                }
                
                BOOL add = true;
                // Do not add the contact directly if we set some filter
                if ([ContactSelection getSipFilter] || [ContactSelection emailFilterEnabled]) {
                    add = false;
                }
                
                if ([FastAddressBook contactHasValidSipDomain:contact]) {
                    
                    add = true;
                    
                }else if (contact.friend && linphone_presence_model_get_basic_status(linphone_friend_get_presence_model(contact.friend)) == LinphonePresenceBasicStatusOpen) {
                    
                    add = true;
                }
                
                if (!add && [ContactSelection emailFilterEnabled]) {
                    // Add this contact if it has an email
                    add = (contact.emails.count > 0);
                }
                
                // Wedo Nethesis Filter. Show in SipView only Nethesis contacts. Can be renamed to NethesisView.
                add = [self testNethesis:contact];
                
                NSMutableString *name = [[NSMutableString alloc] initWithString:@""];
                // if(![ContactSelection getSipFilter] && !contact.nethesis) {
                name = [self displayNameForContact:contact] ? [[NSMutableString alloc] initWithString: [self displayNameForContact:contact]] : nil;
                // } else if(contact.company && contact.company.length > 0) {
                // name = [[NSMutableString alloc] initWithString: contact.company];
                // } else {
                // Same as first.
                // name = [self displayNameForContact:contact] ? [[NSMutableString alloc] initWithString: [self displayNameForContact:contact]] : nil;
                // }
                
                NSString * nameFilter = [ContactSelection getNameOrEmailFilter];
                
                if([ContactSelection getSipFilter] && nameFilter && ![nameFilter isEqual: @""] && add) {
                    
                    NSMutableArray *subAr = [myMap objectForKey:@"A"];
                    if (subAr == nil) {
                        subAr = [[NSMutableArray alloc] init];
                        [myMap insertObject:subAr forKey:@"A" selector:@selector(caseInsensitiveCompare:)];
                    }
                    
                    NSUInteger idx = [subAr indexOfObject:contact
                                            inSortedRange:(NSRange){0, subAr.count}
                                                  options:NSBinarySearchingInsertionIndex
                                          usingComparator:^NSComparisonResult( Contact *_Nonnull obj1, Contact *_Nonnull obj2) {
                        
                        NSComparisonResult result = [[obj1.company lowercaseString] compare:[obj2.company lowercaseString]];
                        if(result != NSOrderedSame)
                            return result;
                        NSString * first = [[self displayNameForContact:obj1] lowercaseString];
                        NSString * second = [[self displayNameForContact:obj2] lowercaseString];
                        return [first compare:second];
                    }];
                    
                    if (![subAr containsObject:contact]) {
                        [subAr insertObject:contact atIndex:idx];
                    }
                    
                } else if (add && name != nil) {
                    NSString *firstChar = [[name substringToIndex:1] uppercaseString];
                    // Put in correct subAr
                    if ([firstChar characterAtIndex:0] < 'A' || [firstChar characterAtIndex:0] > 'Z') {
                        firstChar = @"#";
                    }
                    NSMutableArray *subAr = [myMap objectForKey:firstChar];
                    if (subAr == nil) {
                        subAr = [[NSMutableArray alloc] init];
                        [myMap insertObject:subAr forKey:firstChar selector:@selector(caseInsensitiveCompare:)];
                    }
                    NSUInteger idx = [subAr indexOfObject:contact
                                            inSortedRange:(NSRange){0, subAr.count}
                                                  options:NSBinarySearchingInsertionIndex
                                          usingComparator:^NSComparisonResult( Contact *_Nonnull obj1, Contact *_Nonnull obj2) {
                        NSString * first = [[self displayNameForContact:obj1] lowercaseString];
                        NSString * second = [[self displayNameForContact:obj2] lowercaseString];
                        return [first compare:second];
                    }];
                    
                    if (![subAr containsObject:contact]) {
                        [subAr insertObject:contact atIndex:idx];
                    }
                }
            }
        }
        LOGI(@"====>>>> Load contact list - Start 4 !!");
        [LinphoneManager.instance setLinphoneManagerAddressBookMap:myMap];
        addressBookMap = [[OrderedDictionary alloc] initWithDictionary:myMap copyItems:YES];;
    }
    LOGI(@"====>>>> Load contact list - End");
    [super loadData];
    _ongoing = FALSE;
    // since we refresh the tableview, we must perform this on main thread
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (IPAD && !(self.itemsNumber > 0))
            [self setNilContact];
    });
}

- (void)loadSearchedData {
    LOGI(@"Load search contact list");
    
    @synchronized(addressBookMap) {
        //Set all contacts from ContactCell to nil
        for (NSInteger j = 0; j < [self.tableView numberOfSections]; ++j) {
            
            for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:j]; ++i) {
                
                [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]] setContact:nil];
            }
        }
        // Reset Address book
        [addressBookMap removeAllObjects];
        NSMutableArray *subAr = [NSMutableArray new];
        NSMutableArray *subArBegin = [NSMutableArray new];
        NSMutableArray *subArContain = [NSMutableArray new];
        [addressBookMap insertObject:subAr forKey:@"" selector:@selector(caseInsensitiveCompare:)];
        
        for (NSString *addr in sortedAddresses) {
            
            @synchronized(LinphoneManager.instance.fastAddressBook.addressBookMap) {
                
                Contact *contact = [LinphoneManager.instance.fastAddressBook.addressBookMap objectForKey:addr];
                
                BOOL add = true;
                // Do not add the contact directly if we set some filter
                if ([ContactSelection getSipFilter] || [ContactSelection emailFilterEnabled]) {
                    add = false;
                }
                
                if ([FastAddressBook contactHasValidSipDomain:contact]) {
                    add = true;
                }
                if (contact.friend && linphone_presence_model_get_basic_status(linphone_friend_get_presence_model(contact.friend)) == LinphonePresenceBasicStatusOpen) {
                    add = true;
                }
                
                if (!add && [ContactSelection emailFilterEnabled]) {
                    // Add this contact if it has an email
                    add = (contact.emails.count > 0);
                }
                NSInteger idx_begin = -1;
                NSInteger idx_sort = -1;
                NSMutableString *name = [self displayNameForContact:contact]
                    ? [[NSMutableString alloc] initWithString: [self displayNameForContact:contact]]
                    : nil;
                
                // Wedo Nethesis Filter. Show in SipView only Nethesis contacts. Can be renamed to NethesisView.
                add = [self testNethesis:contact];
                
                if (add && name != nil) {
                    NSString *filter = [ContactSelection getNameOrEmailFilter];
                    NSRange range = [[contact displayName] rangeOfString:filter options:NSCaseInsensitiveSearch];
                    if (range.location == 0) {
                        if (![subArBegin containsObject:contact]) {
                            idx_begin = idx_begin + 1;
                            [subArBegin insertObject:contact atIndex:idx_begin];
                        }
                    } else if ([[contact displayName]
                                rangeOfString:filter
                                options:NSCaseInsensitiveSearch]
                               .location != NSNotFound) {
                        if (![subArContain containsObject:contact]) {
                            idx_sort = idx_sort + 1;
                            [subArContain insertObject:contact atIndex:idx_sort];
                        }
                    }
                }
            }
        }
        
        [subArBegin sortUsingComparator:^NSComparisonResult(Contact *_Nonnull obj1, Contact *_Nonnull obj2) {
            return [[self displayNameForContact:obj1] compare:[self displayNameForContact:obj2] options:NSCaseInsensitiveSearch];
        }];
        
        [subArContain sortUsingComparator:^NSComparisonResult(Contact *_Nonnull obj1, Contact *_Nonnull obj2) {
            return [[self displayNameForContact:obj1] compare:[self displayNameForContact:obj2] options:NSCaseInsensitiveSearch];
        }];
        
        [subAr addObjectsFromArray:subArBegin];
        [subAr addObjectsFromArray:subArContain];
        [super loadData];
        
        // since we refresh the tableview, we must perform this on main
        // thread
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (IPAD && !(self.itemsNumber > 0))
                [self setNilContact];
        });
    }
}

- (BOOL)testNethesis:(Contact *)contact {
    return ([ContactSelection getSipFilter] && contact.nethesis) || (![ContactSelection getSipFilter] && !contact.nethesis);
}

- (void)setNilContact {
    if([ContactSelection getSipFilter]) {
        ContactDetailsViewNethesis *view = VIEW(ContactDetailsViewNethesis);
        [view setContact:nil];
    } else {
        ContactDetailsView *view = VIEW(ContactDetailsView);
        [view setContact:nil];
    }
}

#pragma mark - UITableViewDataSource Functions

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if([ContactSelection getSipFilter]) return nil;
    return [addressBookMap allKeys];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [addressBookMap count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [(OrderedDictionary *)[addressBookMap objectForKey:[addressBookMap keyAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // If no need to download contacts, don't do it!
    if ([ContactSelection getSipFilter]) {
        
        NSInteger rowIndex = [self tableView:tableView countRow:indexPath];
        
        if ([NethPhoneBook.instance hasMore:rowIndex] && rowIndex + 50 > self.itemsNumber) {
            
            NSString *searchText = [ContactSelection getNameOrEmailFilter];
            
            [LinphoneManager.instance.fastAddressBook loadNeth:[ContactSelection getPickerFilter]
                                                      withTerm:searchText];
        }
    }
    
    NSString *kCellId = NSStringFromClass(UIContactCell.class);
    UIContactCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (cell == nil) {
        cell = [[UIContactCell alloc] initWithIdentifier:kCellId];
        [cell setFrame: CGRectMake(0, 0, tableView.frame.size.width, rowHeight)];
    }
    
    // if(addressBookMap.count > [indexPath section]) { // HackerMAN!
        NSMutableArray *subAr = [addressBookMap objectForKey:[addressBookMap keyAtIndex:[indexPath section]]];
        // if (subAr.count > indexPath.row) {
            Contact *contact = subAr[indexPath.row];
            
            // Cached avatar
            // UIImage *image = [FastAddressBook imageForContact:contact];
            // [cell.avatarImage setImage:image bordered:NO withRoundedRadius:YES];
            [cell setContact:contact];
            [super accessoryForCell:cell atPath:indexPath];
            cell.contentView.userInteractionEnabled = false;
        // }
    // }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return rowHeight;
}

/// Utility method: count a table view row absolute index.
/// @param tableView where count rows.
/// @param indexPath pointer to current row.
- (NSInteger)tableView:(UITableView *)tableView countRow:(NSIndexPath *)indexPath {
    NSInteger rowCount = 0;
    for (NSInteger i = 0 ; i < indexPath.section; i ++) { // Add previous sections rows.
        rowCount += [tableView numberOfRowsInSection:i];
    }
    return rowCount + indexPath.row; // Add current section row.
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    // Hide header when in sip filter mode.
    return [ContactSelection getSipFilter] ? 0 : tableView.sectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    CGRect frame = CGRectMake(0, 0, tableView.frame.size.width, tableView.sectionHeaderHeight);
    UIView *tempView = [[UIView alloc] initWithFrame:frame];
    if (@available(iOS 13, *)) {
        tempView.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        tempView.backgroundColor = [UIColor whiteColor];
    }

    UILabel *tempLabel = [[UILabel alloc] initWithFrame:frame];
    tempLabel.backgroundColor = [UIColor clearColor];
    tempLabel.textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"color_A.png"]];
    tempLabel.text = [addressBookMap keyAtIndex:section];
    tempLabel.textAlignment = NSTextAlignmentCenter;
    tempLabel.font = [UIFont boldSystemFontOfSize:17];
    tempLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [tempView addSubview:tempLabel];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(20.0f, tempView.frame.size.height, tempView.frame.size.width  - 40.0f, 1.0f);
    bottomBorder.backgroundColor = [UIColor getColorByName:@"Grey"].CGColor;
    
    [tempView.layer addSublayer:bottomBorder];

    return tempView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    // If is editing, select the checkbox instead open contact detail.
    if ([self isEditing])
        return;
    
    NSMutableArray *subAr = [addressBookMap objectForKey:[addressBookMap keyAtIndex:[indexPath section]]];
    Contact *contact = subAr[indexPath.row];
    
    // Go to right ContactDetailsView(Nethesis)
    if ([ContactSelection getSipFilter] && contact.nethesis) {
        
        ContactDetailsViewNethesis *view = VIEW(ContactDetailsViewNethesis);
        [PhoneMainView.instance changeCurrentView:view.compositeViewDescription];
        
        if (([ContactSelection getSelectionMode] != ContactSelectionModeEdit) || !([ContactSelection getAddAddress])) {
            
            [view setContact:contact];
            
        }else {
            
            if (IPAD) {
                [view resetContact];
                view.isAdding = FALSE;
            }
            [view editContact:contact address:[ContactSelection getAddAddress]];
        }
        
    }else {
        
        ContactDetailsView *view = VIEW(ContactDetailsView);
        [PhoneMainView.instance changeCurrentView:view.compositeViewDescription];
        
        if (([ContactSelection getSelectionMode] != ContactSelectionModeEdit) || !([ContactSelection getAddAddress])) {
            
            [view setContact:contact];
            
        }else {
            
            if (IPAD) {
                [view resetContact];
                view.isAdding = FALSE;
            }
            [view editContact:contact address:[ContactSelection getAddAddress]];
        }
    }
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [NSNotificationCenter.defaultCenter removeObserver:self];
        
        NSString *msg = NSLocalizedString(@"Do you want to delete selected contact?\nIt will also be deleted from your phone's address book.", nil);
        [UIConfirmationDialog ShowWithMessage:msg
                                cancelMessage:nil
                               confirmMessage:nil
                                onCancelClick:nil
                          onConfirmationClick:^() {
            [tableView beginUpdates];
            
            NSString *firstChar = [addressBookMap keyAtIndex:[indexPath section]];
            // Get the right mutable copy of the array.
            NSMutableArray *subAr = [[addressBookMap objectForKey:firstChar] mutableCopy];
            Contact *contact = subAr[indexPath.row];
            [subAr removeObjectAtIndex:indexPath.row];
            
            // Set the right new copy of array.
            dispatch_async(dispatch_get_main_queue(), ^{
                [addressBookMap setValue:subAr forKey:firstChar];
            });
            
            if (subAr.count == 0) {
                [addressBookMap removeObjectForKey:firstChar];
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]
                         withRowAnimation:UITableViewRowAnimationFade];
            }
            UIContactCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell setContact:NULL];
            [[LinphoneManager.instance fastAddressBook] deleteContact:contact];
            dispatch_async(dispatch_get_main_queue(), ^{
                [tableView deleteRowsAtIndexPaths:@[indexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
                [tableView endUpdates];
            });
            
            [NSNotificationCenter.defaultCenter    addObserver:self
                                                   selector:@selector(onAddressBookUpdate:)
                                                       name:kLinphoneAddressBookUpdate
                                                     object:nil];
            [self loadData];
        }];
    }
}

- (void)removeSelectionUsing:(void (^)(NSIndexPath *))remover {
    [super removeSelectionUsing:^(NSIndexPath *indexPath) {
        [NSNotificationCenter.defaultCenter removeObserver:self];
        
        NSString *firstChar = [addressBookMap keyAtIndex:[indexPath section]];
        NSMutableArray *subAr = [[addressBookMap objectForKey:firstChar] mutableCopy];
        Contact *contact = subAr[indexPath.row];
        [subAr removeObjectAtIndex:indexPath.row];
        
        // Set the right new copy of array.
        [addressBookMap setValue:subAr forKey:firstChar];
        
        if (subAr.count == 0) {
            [addressBookMap removeObjectForKey:firstChar];
        }
        UIContactCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell setContact:NULL];
        [[LinphoneManager.instance fastAddressBook] deleteContact:contact];
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(onAddressBookUpdate:)
                                                   name:kLinphoneAddressBookUpdate
                                                 object:nil];
    }];
}

@end
