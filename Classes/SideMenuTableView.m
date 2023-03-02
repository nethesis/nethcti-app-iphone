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

#import "linphone/core_utils.h"
#import "SideMenuTableView.h"
#import "Utils.h"
#import "PhoneMainView.h"
#import "StatusBarView.h"
#import "LinphoneManager.h"
#import "RecordingsListView.h"
#import "linphoneapp-Swift.h"
#import "DashboardViewController.h"

@implementation SideMenuEntry

- (id)initWithTitle:(NSString *)atitle image:(UIImage *)image tapBlock:(SideMenuEntryBlock)tapBlock {
    if ((self = [super init])) {
        img = image;
        title = atitle;
        onTapBlock = tapBlock;
    }
    return self;
}

@end


@implementation SideMenuTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Remove separators between elements: https://stackoverflow.com/a/925202/10220116.
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}


- (void)viewWillAppear:(BOOL)animated {
    
    linphone_core_stop_dtmf_stream(LC);
    
    [super viewWillAppear:animated];
    
    _sideMenuEntries = [[NSMutableArray alloc] init];
    
    // If an account is configured, I must hide the Assistant row.
    BOOL account_configured = (linphone_core_get_default_proxy_config(LC) == NULL);
    
    if(!account_configured) {
        [_sideMenuEntries addObject:
         [[SideMenuEntry alloc] initWithTitle:NSLocalizedString(@"Dashboard", nil)
                                        image:[UIImage imageNamed:@"nethcti_menu_home.png"]
                                     tapBlock:^() {
            [PhoneMainView.instance changeCurrentView:DashboardViewController.compositeViewDescription];
        }]];
    }
    
    if (account_configured) {
        [_sideMenuEntries addObject:
         [[SideMenuEntry alloc] initWithTitle:NSLocalizedString(@"Login", nil)
                                        image:[UIImage imageNamed:@"login_menu.png"]
                                     tapBlock:^() {
            [PhoneMainView.instance changeCurrentView:AssistantView.compositeViewDescription];
        }]];
    }
    
    BOOL mustLink = ([LinphoneManager.instance lpConfigIntForKey:@"must_link_account_time"] > 0);
    
    if (mustLink) {
        [_sideMenuEntries addObject:
         [[SideMenuEntry alloc] initWithTitle:NSLocalizedString(@"Link my account", nil)
                                        image:[UIImage imageNamed:@"menu_link_account.png"]
                                     tapBlock:^() {
            [PhoneMainView.instance changeCurrentView:AssistantLinkView.compositeViewDescription];
        }]];
    }
    
    [_sideMenuEntries addObject:
     [[SideMenuEntry alloc] initWithTitle:NSLocalizedString(@"Settings", nil)
                                    image:[UIImage imageNamed:@"settings.png"]
                                 tapBlock:^() {
        [PhoneMainView.instance changeCurrentView:SettingsView.compositeViewDescription];
    }]];
    
    [_sideMenuEntries addObject:
     [[SideMenuEntry alloc] initWithTitle:NSLocalizedString(@"Recordings", nil)
                                    image:[UIImage imageNamed:@"nethcti_microphone.png"]
                                 tapBlock:^() {
        [PhoneMainView.instance changeCurrentView:RecordingsListView.compositeViewDescription];
    }]];
    
    [_sideMenuEntries addObject:
     [[SideMenuEntry alloc] initWithTitle:NSLocalizedString(@"About", nil)
                                    image:[UIImage imageNamed:@"info.png"]
                                 tapBlock:^() {
        [PhoneMainView.instance changeCurrentView:AboutView.compositeViewDescription];
    }]];
    
    
    if (!account_configured) {
        // An account is configured

        [_sideMenuEntries addObject:[[SideMenuEntry alloc] initWithTitle:NSLocalizedString(@"Logout", nil)
                                                                   image:[UIImage imageNamed:@"logout.png"]
                                                                tapBlock:^() {
            [self visualizzaAlertLogout];
        }]];
    }
}



- (void)visualizzaAlertLogout {
    
    NSLog(@"visualizzaAlertLogout");
    
    UIAlertController *alertControllerLogout = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Attenzione!", nil)
                                                                                    message:NSLocalizedString(@"Eseguendo il logout verranno cancellate le credenziali, sarà quindi necessario eseguire nuovamente la procedura di login.", nil)
                                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    // BTN Continua
    [alertControllerLogout addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Continue", nil)
                                                               style:UIAlertActionStyleDestructive
                                                             handler:^(UIAlertAction *action) {
        
        // Remove remote sip proxies info.
        [LinphoneManager.instance clearProxies];
        
    }]];
    
    // BTN Annulla
    [alertControllerLogout addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action) {
        
        [alertControllerLogout dismissViewControllerAnimated:YES completion:nil];
        
    }]];
    
    // Visualizza Alert INOLTRO
    [self presentViewController:alertControllerLogout animated:YES completion:nil];
}



#pragma mark - Table View Controller
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        BOOL hasDefault = (linphone_core_get_default_proxy_config(LC) != NULL);
        // Default account is shown in the header already.
        size_t count = bctbx_list_size(linphone_core_get_proxy_config_list(LC));
        return MAX(0, (int)count - (hasDefault ? 1 : 0));
        
    } else {
        
        return [_sideMenuEntries count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    // isLcInitialized called here because this is called when going in bg after LC destroy
    if (indexPath.section == 0 && [LinphoneManager isLcInitialized]) {
        // do not display default account here, it is already in header view
        int idx = linphone_core_get_default_proxy_config(LC) ? bctbx_list_index(linphone_core_get_proxy_config_list(LC),
                                                                                linphone_core_get_default_proxy_config(LC)): HUGE_VAL;
        
        LinphoneProxyConfig *proxy = bctbx_list_nth_data(linphone_core_get_proxy_config_list(LC),
                                                         (int)indexPath.row + (idx <= indexPath.row ? 1 : 0));
        if (proxy) {
            cell.textLabel.text = [NSString stringWithUTF8String:linphone_proxy_config_get_identity(proxy)];
            cell.imageView.image = [StatusBarView imageForState:linphone_proxy_config_get_state(proxy)];
        } else {
            LOGE(@"Invalid index requested, no proxy for row %d", indexPath.row);
        }
        cell.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        cell.textLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        cell.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"color_G.png"]];
        
    }else {
        
        SideMenuEntry *entry = [_sideMenuEntries objectAtIndex:indexPath.row];
        cell.imageView.image = entry->img;
        cell.textLabel.text = entry->title;
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:19];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if (indexPath.section == 0) {
        
        [PhoneMainView.instance changeCurrentView:SettingsView.compositeViewDescription];
        
    } else {
        
        SideMenuEntry *entry = [_sideMenuEntries objectAtIndex:indexPath.row];
        
        //LOGI(@"Entry %@ has been tapped", entry->title);
        
        if (entry->onTapBlock == nil) {
            
            LOGF(@"Entry %@ has no onTapBlock!", entry->title);
            
        }else {
            
            entry->onTapBlock();
        }
    }
    
    [PhoneMainView.instance.mainViewController hideSideMenu:YES];
}

@end
