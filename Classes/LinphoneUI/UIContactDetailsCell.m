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

#import "UIContactDetailsCell.h"
#import "FastAddressBook.h"
#import "Contact.h"
#import "PhoneMainView.h"

@implementation UIContactDetailsCell

#pragma mark - Lifecycle Functions

- (id)initWithIdentifier:(NSString *)identifier {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]) != nil) {
		NSArray *arrayOfViews =
			[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];

		// resize cell to match .nib size. It is needed when resized the cell to
		// correctly adapt its height too
		UIView *sub = ((UIView *)[arrayOfViews objectAtIndex:0]);
		[self setFrame:CGRectMake(0, 0, sub.frame.size.width, sub.frame.size.height)];
		[self addSubview:sub];
	}
	return self;
}

#pragma mark - UITableViewCell Functions

- (void)setAddress:(NSString *)address {
    _addressLabel.text = _editTextfield.text = address;
    char *normAddr = (char *)_addressLabel.text.UTF8String;
    LinphoneProxyConfig *cfg = linphone_core_get_default_proxy_config(LC);
    const BOOL isPhone = linphone_proxy_config_is_phone_number(cfg, _addressLabel.text.UTF8String);
    if(_addressLabel.text && cfg && isPhone)
        normAddr = linphone_proxy_config_normalize_phone_number(cfg, _addressLabel.text.UTF8String);
    
    LinphoneAddress *addr = linphone_core_interpret_url(LC, normAddr);
    _chatButton.enabled = _callButton.enabled = (addr != NULL);
    _callButton.hidden = (addr == NULL);
    
    _chatButton.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"Chat with %@", nil), _addressLabel.text];
    _callButton.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"Call %@", nil), _addressLabel.text];
    // Test presence
    Contact *contact = addr ? [FastAddressBook getContactWithAddress:(addr)] : NULL;
    
    _linphoneImage.hidden = TRUE;
    if (contact) {
        const LinphonePresenceModel *model = contact.friend ? linphone_friend_get_presence_model_for_uri_or_tel(contact.friend, _addressLabel.text.UTF8String) : NULL;
        
        // Hide here contact info.
        self.linphoneImage.hidden = [LinphoneManager.instance lpConfigBoolForKey:@"hide_linphone_contacts" inSection:@"app"] ||
        !((model && linphone_presence_model_get_basic_status(model) == LinphonePresenceBasicStatusOpen) ||
          (cfg && !isPhone && [FastAddressBook isSipURIValid:_addressLabel.text]));
        Contact * selectedContact;
        if([ContactSelection getSipFilter]) {
            // Hard Nethesis.
            ContactDetailsViewNethesis *contactDetailsView = VIEW(ContactDetailsViewNethesis);
            selectedContact = contactDetailsView.contact;
        } else {
            // Easy Linphone.
            ContactDetailsView *contactDetailsView = VIEW(ContactDetailsView);
            selectedContact = contactDetailsView.contact;
        }
        self.inviteButton.hidden = !ENABLE_SMS_INVITE || [[selectedContact sipAddresses] count] > 0 || !self.linphoneImage.hidden;
        [self shouldHideEncryptedChatView:cfg && linphone_proxy_config_get_conference_factory_uri(cfg) && model && linphone_presence_model_has_capability(model, LinphoneFriendCapabilityLimeX3dh)];
    }
    
    if (addr) {
        linphone_address_unref(addr);
    }
    _isAddress = YES;
}

/// Prepare cell view to be shown if the value is not an address which can be called.
/// @param value a simple string which doesn't contains an address.
- (void)setNonAddress:(NSString *)value {
    _addressLabel.text = value;
    _inviteButton.hidden = _linphoneImage.hidden = _callButton.hidden = YES;
    _isAddress = NO;
}

- (void)resizeCell {
    CGRect frame = self.frame;
    frame.size.height = _isAddress ? 88 : 44;
    self.frame = _defaultView.frame = frame;
}

- (void)shouldHideEncryptedChatView:(BOOL)hasLime {
    _encryptedChatView.hidden = true;
    /*
    _encryptedChatView.hidden = !hasLime;
    CGRect newFrame = _optionsView.frame;
    if (!hasLime) {
        newFrame.origin.x = _addressLabel.frame.origin.x + _callButton.frame.size.width * 2/3;
        
    } else {
        newFrame.origin.x = _addressLabel.frame.origin.x;
    }
    _optionsView.frame = newFrame;
     */
}

- (void)shouldHideLinphoneImageOfAddress {
	if (!_addressLabel.text) {
		return;
	}

	char *normAddr = (char *)_addressLabel.text.UTF8String;
	LinphoneProxyConfig *cfg = linphone_core_get_default_proxy_config(LC);
	if (cfg && linphone_proxy_config_is_phone_number(cfg,
											  _addressLabel.text.UTF8String)) {
		normAddr = linphone_proxy_config_normalize_phone_number(cfg,
																_addressLabel.text.UTF8String);
	}
	LinphoneAddress *addr = linphone_core_interpret_url(LC, normAddr);

	// Test presence
	Contact *contact = [FastAddressBook getContactWithAddress:(addr)];

	if (contact) {
		self.linphoneImage.hidden =[LinphoneManager.instance lpConfigBoolForKey:@"hide_linphone_contacts" inSection:@"app"] || ! ((contact.friend && linphone_presence_model_get_basic_status(linphone_friend_get_presence_model_for_uri_or_tel(contact.friend, _addressLabel.text.UTF8String)) == LinphonePresenceBasicStatusOpen) || (cfg && !linphone_proxy_config_is_phone_number(cfg, _addressLabel.text.UTF8String) && [FastAddressBook isSipURIValid:_addressLabel.text]));
	}
	
	if (addr) {
		linphone_address_unref(addr);
	}
}

- (void)hideDeleteButton:(BOOL)hidden {
	if (_deleteButton.hidden == hidden)
		return;

	CGRect newFrame = _editTextfield.frame;
	newFrame.size.width = _editView.frame.size.width - newFrame.origin.x;
	if (hidden) {
		newFrame.size.width -= newFrame.origin.x; /* center view in super view */
	} else {
		newFrame.size.width -= _deleteButton.frame.size.width;
	}
	_editTextfield.frame = newFrame;
	_deleteButton.hidden = hidden;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];

	_defaultView.hidden = editing;
	_editView.hidden = !editing;
}

- (void)setEditing:(BOOL)editing {
	[self setEditing:editing animated:FALSE];
}

- (IBAction)onCallClick:(id)event {
	LinphoneAddress *addr = [LinphoneUtils normalizeSipOrPhoneAddress:_addressLabel.text];
	[LinphoneManager.instance call:addr];
	if (addr)
		linphone_address_unref(addr);
}

- (IBAction)onChatClick:(id)event {
	LinphoneAddress *addr = [LinphoneUtils normalizeSipOrPhoneAddress:_addressLabel.text];
	[LinphoneManager.instance lpConfigSetBool:TRUE forKey:@"create_chat"];
	[PhoneMainView.instance getOrCreateOneToOneChatRoom:addr waitView:_waitView isEncrypted:FALSE];
	linphone_address_unref(addr);
}

- (IBAction)onEncrptedChatClick:(id)sender {
    LinphoneAddress *addr = [LinphoneUtils normalizeSipOrPhoneAddress:_addressLabel.text];
	[LinphoneManager.instance lpConfigSetBool:TRUE forKey:@"create_chat"];
    [PhoneMainView.instance getOrCreateOneToOneChatRoom:addr waitView:_waitView isEncrypted:TRUE];
    linphone_address_unref(addr);
}

- (IBAction)onDeleteClick:(id)sender {
	UITableView *tableView = [ContactSelection getSipFilter] ?
    VIEW(ContactDetailsView).tableController.tableView :
    VIEW(ContactDetailsViewNethesis).tableController.tableView;
	NSIndexPath *indexPath = [tableView indexPathForCell:self];
	[tableView.dataSource tableView:tableView
				 commitEditingStyle:UITableViewCellEditingStyleDelete
				  forRowAtIndexPath:indexPath];
}

#pragma mark - SMS invite

- (IBAction)onSMSInviteClick:(id)sender {
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText]) {
        // controller.body = NSLocalizedString(@"Hello! Join me on Linphone! You can download it for free at: https://www.linphone.org/download",nil);
        // Use the new NethCTI string from the new NethLocalizable file.
        controller.body = NSLocalizedStringFromTable(@"Hello! Join me on NethCTI 3! You can download it for free at: link", @"BrandLocalizable", @"");
        controller.recipients = [NSArray arrayWithObjects:[self.addressLabel text], nil];
        
        controller.messageComposeDelegate = PhoneMainView.instance;
        [PhoneMainView.instance presentViewController:controller animated:YES completion:nil];
    }
}

@end
