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

#import "SideMenuView.h"
#import "LinphoneManager.h"
#import "PhoneMainView.h"
#import "linphoneapp-Swift.h"

@implementation SideMenuView

- (void)viewDidLoad {
    [super viewDidLoad];

#pragma deploymate push "ignored-api-availability"
    if (UIDevice.currentDevice.systemVersion.doubleValue >= 7) {
        // It's better to detect only pan from screen edges
        UIScreenEdgePanGestureRecognizer *pan =
            [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(onLateralSwipe:)];
        pan.edges = UIRectEdgeRight;
        [self.view addGestureRecognizer:pan];
        _swipeGestureRecognizer.enabled = NO;
    }
#pragma deploymate pop
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_sideMenuTableViewController viewWillAppear:animated];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(registrationUpdateEvent:)
                                               name:kLinphoneRegistrationUpdate
                                             object:nil];

    [self updateHeader];
    [self setUIColors];
    [_sideMenuTableViewController.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _grayBackground.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _grayBackground.hidden = YES;
    // Should be better than that with alpha animation..
}

- (void)setUIColors {
    if (@available(iOS 11.0, *)) {
        [self.view setBackgroundColor:[UIColor colorNamed: @"mainBackground"]];
        [self.headerView setBackgroundColor:[UIColor colorNamed: @"mainBackground"]];
    } else {
        [self.view setBackgroundColor:[UIColor color:@"White"]];
    }
}

- (void)updateHeader {
    LinphoneProxyConfig *default_proxy = linphone_core_get_default_proxy_config(LC);

    if (default_proxy != NULL) {
        const LinphoneAddress *addr = linphone_proxy_config_get_identity_address(default_proxy);
        [ContactDisplay setDisplayNameLabel:_nameLabel forAddress:addr];
        // NSString *address_text = addr ? [NSString stringWithUTF8String:linphone_address_as_string_uri_only(addr)] : NSLocalizedString(@"No address", nil);
        NSString *main = ApiCredentials.MainExtension;
        _addressLabel.text = main; // address_text;
        _presenceImage.image = [StatusBarView imageForState:linphone_proxy_config_get_state(default_proxy)];
    } else {
        _nameLabel.text = linphone_core_get_proxy_config_list(LC) ? NSLocalizedString(@"No default account", nil) : NSLocalizedString(@"No account", nil);
        // Nethesis: if no proxy configured, doesn't show any address info.
        _addressLabel.text = NSLocalizedString(@"No address", nil);
        _presenceImage.image = nil;
    }
}

#pragma deploymate push "ignored-api-availability"
- (void)onLateralSwipe:(UIScreenEdgePanGestureRecognizer *)pan {
    [PhoneMainView.instance.mainViewController hideSideMenu:YES];
}
#pragma deploymate pop

- (IBAction)onHeaderClick:(id)sender {
    [PhoneMainView.instance changeCurrentView:SettingsView.compositeViewDescription];
    [PhoneMainView.instance.mainViewController hideSideMenu:YES];
}

- (IBAction)onBackgroundClicked:(id)sender {
    [PhoneMainView.instance.mainViewController hideSideMenu:YES];
}

- (void)registrationUpdateEvent:(NSNotification *)notif {
    [self updateHeader];
    [_sideMenuTableViewController.tableView reloadData];
}

@end
