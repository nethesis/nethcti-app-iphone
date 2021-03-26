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

#import "UIContactDetailsNonAddressCell.h"
#import "FastAddressBook.h"
#import "Contact.h"
#import "PhoneMainView.h"

@implementation UIContactDetailsNonAddressCell

/// Prepare cell view to be shown if the value is not an address which can be called.
/// @param value a simple string which doesn't contains an address.
- (void)setAddress:(NSString *)value {
    [self hideDeleteButton:YES];
    
    self.addressLabel.text = value;
    self.inviteButton.hidden = self.linphoneImage.hidden = self.callButton.hidden = YES;
    self.isAddress = NO;
}

@end
