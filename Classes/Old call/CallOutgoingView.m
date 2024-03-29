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

#import "CallOutgoingView.h"
#import "PhoneMainView.h"
#import "CallSideMenuView.h"
#import "linphoneapp-Swift.h"

@implementation CallOutgoingView

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
	if (compositeDescription == nil) {
		compositeDescription = [[UICompositeViewDescription alloc] init:self.class
															  statusBar:StatusBarView.class
																 tabBar:nil
															   sideMenu:CallSideMenuView.class
															 fullscreen:false
														 isLeftFragment:NO
														   fragmentWith:nil];

		compositeDescription.darkBackground = true;
	}
	return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
	return self.class.compositeViewDescription;
}

- (void)viewDidLoad {
	_routesEarpieceButton.enabled = !IPAD;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[NSNotificationCenter.defaultCenter addObserver:self
										   selector:@selector(bluetoothAvailabilityUpdateEvent:)
											   name:kLinphoneBluetoothAvailabilityUpdate
											 object:nil];
    
    [self setUIColors];

	LinphoneCall *call = linphone_core_get_current_call(LC);
	if (!call) {
		return;
	}

	const LinphoneAddress *addr = linphone_call_get_remote_address(call);
	[ContactDisplay setDisplayNameLabel:_nameLabel forAddress:addr withAddressLabel:_addressLabel];
	char *uri = linphone_address_as_string_uri_only(addr);
	ms_free(uri);
	
    //[_avatarImage setImage:[FastAddressBook imageForAddress:addr] bordered:NO withRoundedRadius:YES];
    [ContactDisplay setDisplayInitialsLabel:_nameInitialsLabel forAddress:addr];
    
	[self hideSpeaker:LinphoneManager.instance.bluetoothAvailable];

	[_speakerButton update];
	[_microButton update];
	[_routesButton update];
}

- (void)setUIColors {
    UIColor *midgrey = [UIColor getColorByName:@"MidGrey"];
    _nameInitialsLabel.textColor = [UIColor getColorByName:@"Grey"];
    _titleLabel.textColor = midgrey;
    _nameLabel.textColor = midgrey;
    _addressLabel.textColor = LINPHONE_MAIN_COLOR;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	// if there is no call (for whatever reason), we must wait viewDidAppear method
	// before popping current view, because UICompositeView cannot handle view change
	// directly in viewWillAppear (this would lead to crash in deallocated memory - easily
	// reproductible on iPad mini).
	if (!linphone_core_get_current_call(LC)) {
		[PhoneMainView.instance popCurrentView];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[NSNotificationCenter.defaultCenter removeObserver:self];
}

- (IBAction)onRoutesBluetoothClick:(id)sender {
	[self hideRoutes:TRUE animated:TRUE];
	[CallManager.instance enableSpeakerWithEnable:FALSE];
	[LinphoneManager.instance setBluetoothEnabled:TRUE];
}

- (IBAction)onRoutesEarpieceClick:(id)sender {
	[self hideRoutes:TRUE animated:TRUE];
	[CallManager.instance enableSpeakerWithEnable:FALSE];
	[LinphoneManager.instance setBluetoothEnabled:FALSE];
}

- (IBAction)onRoutesSpeakerClick:(id)sender {
	[self hideRoutes:TRUE animated:TRUE];
	[LinphoneManager.instance setBluetoothEnabled:FALSE];
	[CallManager.instance enableSpeakerWithEnable:TRUE];
}

- (IBAction)onRoutesClick:(id)sender {
	if ([_routesView isHidden]) {
		[self hideRoutes:FALSE animated:ANIMATED];
	} else {
		[self hideRoutes:TRUE animated:ANIMATED];
	}
}

- (IBAction)onDeclineClick:(id)sender {
	LinphoneCall *call = linphone_core_get_current_call(LC);
	if (call) {
        TransferCallManager.instance.isCallTransfer = NO;
        TransferCallManager.instance.mTransferCallOrigin = nil;
        TransferCallManager.instance.mTransferCallDestination = nil;
		[CallManager.instance terminateCallWithCall:call];
	}
}

- (void)hideRoutes:(BOOL)hidden animated:(BOOL)animated {
	if (hidden) {
		[_routesButton setOff];
	} else {
		[_routesButton setOn];
	}

	_routesBluetoothButton.selected = CallManager.instance.bluetoothEnabled;
	_routesSpeakerButton.selected = CallManager.instance.speakerEnabled;
	_routesEarpieceButton.selected = !_routesBluetoothButton.selected && !_routesSpeakerButton.selected;

	if (hidden != _routesView.hidden) {
		[_routesView setHidden:hidden];
	}
}

- (void)hideSpeaker:(BOOL)hidden {
	_speakerButton.hidden = hidden;
	_routesButton.hidden = !hidden;
}

#pragma mark - Event Functions

- (void)bluetoothAvailabilityUpdateEvent:(NSNotification *)notif {
	bool available = [[notif.userInfo objectForKey:@"available"] intValue];
	dispatch_async(dispatch_get_main_queue(), ^{
		[self hideSpeaker:available];
	});
}

@end
