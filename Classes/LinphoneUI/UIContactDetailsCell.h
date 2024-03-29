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
#import <MessageUI/MessageUI.h>

#import "UIIconButton.h"

@interface UIContactDetailsCell : UITableViewCell

// this is broken design... but we need this to know which cell was modified
// last... must be totally revamped
@property(strong) NSIndexPath *indexPath;
@property (atomic) BOOL isAddress;

@property(weak, nonatomic) IBOutlet UIView *defaultView;
@property(weak, nonatomic) IBOutlet UILabel *addressLabel;
@property(weak, nonatomic) IBOutlet UITextField *editTextfield;
@property(weak, nonatomic) IBOutlet UIView *editView;
@property(weak, nonatomic) IBOutlet UIIconButton *deleteButton;
@property(weak, nonatomic) IBOutlet UIIconButton *callButton;
@property(weak, nonatomic) IBOutlet UIIconButton *chatButton;
@property (weak, nonatomic) IBOutlet UIIconButton *encryptedChatButton;
@property (weak, nonatomic) IBOutlet UIImageView *linphoneImage;
@property (weak, nonatomic) UIView *waitView;
@property (strong, nonatomic) IBOutlet UIButton *inviteButton;
@property (weak, nonatomic) IBOutlet UIView *encryptedChatView;
@property (weak, nonatomic) IBOutlet UIView *optionsView;

- (id)initWithIdentifier:(NSString *)identifier;
- (void)setAddress:(NSString *)address;
- (void)setNonAddress:(NSString *)value;
- (void)hideDeleteButton:(BOOL)hidden;
- (void)shouldHideLinphoneImageOfAddress;

- (IBAction)onCallClick:(id)sender;
- (IBAction)onChatClick:(id)sender;
- (IBAction)onEncrptedChatClick:(id)sender;
- (IBAction)onDeleteClick:(id)sender;
- (IBAction)onSMSInviteClick:(id)sender;
@end
