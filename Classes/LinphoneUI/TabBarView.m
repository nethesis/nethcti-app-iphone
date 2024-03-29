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

#import "TabBarView.h"
#import "PhoneMainView.h"
#import "linphoneapp-Swift.h"

@implementation TabBarView {
    UIColor *grey;
    UIColor *mainColor;
}

#pragma mark - ViewController Functions

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[NSNotificationCenter.defaultCenter addObserver:self
										   selector:@selector(changeViewEvent:)
											   name:kLinphoneMainViewChange
											 object:nil];
	[NSNotificationCenter.defaultCenter addObserver:self
										   selector:@selector(callUpdate:)
											   name:kLinphoneCallUpdate
											 object:nil];
	[NSNotificationCenter.defaultCenter addObserver:self
										   selector:@selector(messageReceived:)
											   name:kLinphoneMessageReceived
											 object:nil];
	[self update:FALSE];
    [self setupUI];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self update:FALSE];
}

#pragma mark - Event Functions

- (void)callUpdate:(NSNotification *)notif {
	// LinphoneCall *call = [[notif.userInfo objectForKey: @"call"] pointerValue];
	// LinphoneCallState state = [[notif.userInfo objectForKey: @"state"] intValue];
	[self updateMissedCall:linphone_core_get_missed_calls_count(LC) appear:TRUE];
}

- (void)changeViewEvent:(NSNotification *)notif {
	UICompositeViewDescription *view = [notif.userInfo objectForKey:@"view"];
	if (view != nil) {
		[self updateSelectedButton:view];
	}
}

- (void)messageReceived:(NSNotification *)notif {
	[self updateUnreadMessage:TRUE];
}

#pragma mark - UI Update

-(void)setupUI {
    grey = [UIColor getColorByName: @"Grey"];
    mainColor = [UIColor getColorByName: @"MainColor"];
    
    UIImage *historyImage = [[UIImage imageNamed:@"history.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *dialerImage = [[UIImage imageNamed:@"dialpad.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *contactsImage = [[UIImage imageNamed:@"users.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [self.historyButton setImage:historyImage forState:UIControlStateNormal];
    [self.dialerButton setImage:dialerImage forState:UIControlStateNormal];
    [self.contactsButton setImage:contactsImage forState:UIControlStateNormal];

    [self.historyButton.imageView setTintColor:mainColor];
    [self.dialerButton.imageView setTintColor:grey];
    [self.contactsButton.imageView setTintColor:grey];
    
    _historyNotificationLabel.textColor = grey;
}

- (void)update:(BOOL)appear {
	[self updateSelectedButton:[PhoneMainView.instance currentView]];
	[self updateMissedCall:linphone_core_get_missed_calls_count(LC) appear:appear];
	[self updateUnreadMessage:appear];
}

- (void)updateUnreadMessage:(BOOL)appear {
	int unreadMessage = [LinphoneManager unreadMessageCount];
	if (unreadMessage > 0) {
		_chatNotificationLabel.text = [NSString stringWithFormat:@"%i", unreadMessage];
		[_chatNotificationView startAnimating:appear];
	} else {
		[_chatNotificationView stopAnimating:appear];
	}
}

- (void)updateMissedCall:(int)missedCall appear:(BOOL)appear {
	if (missedCall > 0) {
		_historyNotificationLabel.text = [NSString stringWithFormat:@"%i", missedCall];
		[_historyNotificationView startAnimating:appear];
	} else {
		[_historyNotificationView stopAnimating:appear];
	}
}

- (void)updateSelectedButton:(UICompositeViewDescription *)view {
    // Actually this control is white to hide him. Can we remove it?
    
    if ([view equal:HistoryListView.compositeViewDescription] ||
        [view equal:HistoryDetailsView.compositeViewDescription]) {
        
        _historyButton.selected = true;
        [self.historyButton.imageView setTintColor:mainColor];
        
    }else {
        
        _historyButton.selected = false;
        [self.historyButton.imageView setTintColor:grey];
    }
    
    if ([view equal:ContactsListView.compositeViewDescription] ||
        [view equal:ContactDetailsView.compositeViewDescription] ||
        [view equal:ContactDetailsViewNethesis.compositeViewDescription]) {
        
        _contactsButton.selected = true;
        [self.contactsButton.imageView setTintColor:mainColor];
        
    }else {
        
        _contactsButton.selected = false;
        [self.contactsButton.imageView setTintColor:grey];
    }

    if ([view equal:DialerView.compositeViewDescription]) {
        
        _dialerButton.selected = true;
        [self.dialerButton.imageView setTintColor:mainColor];
        
    }else {
        
        _dialerButton.selected = false;
        [self.dialerButton.imageView setTintColor:grey];
    }
    
    _chatButton.selected = [view equal:ChatsListView.compositeViewDescription] ||
        [view equal:ChatConversationCreateView.compositeViewDescription] ||
        [view equal:ChatConversationInfoView.compositeViewDescription] ||
        [view equal:ChatConversationImdnView.compositeViewDescription] ||
        [view equal:ChatConversationView.compositeViewDescription];
    
    /*
    CGRect selectedNewFrame = _selectedButtonImage.frame;
    if ([self viewIsCurrentlyPortrait]) {
        selectedNewFrame.origin.x =
            (_historyButton.selected
                 ? _historyButton.frame.origin.x
                 : (_contactsButton.selected
                        ? _contactsButton.frame.origin.x
                        : (_dialerButton.selected
                               ? _dialerButton.frame.origin.x
                               : (_chatButton.selected
                                      ? _chatButton.frame.origin.x
                                      : -selectedNewFrame.size.width //hide it if none is selected))));
    } else {
        selectedNewFrame.origin.y =
            (_historyButton.selected
                 ? _historyButton.frame.origin.y
                 : (_contactsButton.selected
                        ? _contactsButton.frame.origin.y
                        : (_dialerButton.selected
                               ? _dialerButton.frame.origin.y
                               : (_chatButton.selected
                                      ? _chatButton.frame.origin.y
                                      : -selectedNewFrame.size.height //hide it if none is selected))));
    }
    
    CGFloat delay = ANIMATED ? 0.3 : 0;
    [UIView animateWithDuration:delay
                     animations:^{
        _selectedButtonImage.frame = selectedNewFrame;
    }];
     */
}

#pragma mark - Action Functions

- (IBAction)onHistoryClick:(id)event {
	linphone_core_reset_missed_calls_count(LC);
    [self update:FALSE];
    [PhoneMainView.instance updateApplicationBadgeNumber];
    [PhoneMainView.instance changeCurrentView:HistoryListView.compositeViewDescription];
    [self.historyButton.imageView setTintColor:mainColor];
    [self.dialerButton.imageView setTintColor:grey];
    [self.contactsButton.imageView setTintColor:grey];
}

- (IBAction)onContactsClick:(id)event {
    [ContactSelection setAddAddress:nil];
    [ContactSelection enableEmailFilter:FALSE];
    [ContactSelection setNameOrEmailFilter:nil];
    [PhoneMainView.instance changeCurrentView:ContactsListView.compositeViewDescription];
    [self.historyButton.imageView setTintColor:grey];
    [self.dialerButton.imageView setTintColor:grey];
    [self.contactsButton.imageView setTintColor:mainColor];
}

- (IBAction)onDialerClick:(id)event {
    [PhoneMainView.instance changeCurrentView:DialerView.compositeViewDescription];
    [self.historyButton.imageView setTintColor:grey];
    [self.dialerButton.imageView setTintColor:mainColor];
    [self.contactsButton.imageView setTintColor:grey];
}

- (IBAction)onSettingsClick:(id)event {
	[PhoneMainView.instance changeCurrentView:SettingsView.compositeViewDescription];
}

- (IBAction)onChatClick:(id)event {
	[PhoneMainView.instance changeCurrentView:ChatsListView.compositeViewDescription];
}

@end
