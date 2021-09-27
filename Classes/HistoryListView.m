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

#import "HistoryListView.h"
#import "PhoneMainView.h"
#import "LinphoneUI/UIHistoryCell.h"

@implementation HistoryListView

typedef enum _HistoryView { History_All, History_Missed, History_MAX } HistoryView;

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
	if (compositeDescription == nil) {
		compositeDescription = [[UICompositeViewDescription alloc] init:self.class
															  statusBar:StatusBarView.class
																 tabBar:TabBarView.class
															   sideMenu:SideMenuView.class
															 fullscreen:false
														 isLeftFragment:YES
														   fragmentWith:HistoryDetailsView.class];
	}
	return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
	return self.class.compositeViewDescription;
}

#pragma mark - ViewController Functions

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if ([_tableController isEditing]) {
		[_tableController setEditing:FALSE animated:FALSE];
	}
	[self changeView:History_All];
	[self onEditionChangeClick:nil];

	// Reset missed call
	linphone_core_reset_missed_calls_count(LC);
	// Fake event
	[NSNotificationCenter.defaultCenter postNotificationName:kLinphoneCallUpdate object:self];
    
    // Set btn images.
	[_toggleSelectionButton setImage:[UIImage imageNamed:@"nethcti_multiselect_selected.png"] forState:UIControlStateSelected];
    UIImage *allLogs = [[UIImage imageNamed:@"nethcti_grey_phone.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *loseLogs = [[UIImage imageNamed:@"nethcti_missed_calls.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_allButton setImage:allLogs forState:UIControlStateNormal];
    [_missedButton setImage:loseLogs forState:UIControlStateNormal];
    
    [self setUIColors];
}

- (void) setUIColors {
    UIColor *grey;
    UIColor *separator;
    if (@available(iOS 11.0, *)) {
        grey = [UIColor colorNamed: @"iconTint"];
        separator = [UIColor colorNamed: @"tableSeparator"];
    } else {
        grey = [UIColor getColorByName:@"Grey"];
        separator = [UIColor getColorByName:@"LightGrey"];
    }
    [_tableController.tableView setSeparatorColor:separator];
}

- (void) viewWillDisappear:(BOOL)animated {
	self.view = NULL;
}

#pragma mark -

- (void)changeView:(HistoryView)view {
	if (view == History_All) {
		_allButton.selected = TRUE;
		[_tableController setMissedFilter:FALSE];
		_missedButton.selected = FALSE;
        [_allButton.imageView setTintColor:[UIColor getColorByName:@"MainColor"]];
        [_missedButton.imageView setTintColor:[UIColor getColorByName:@"Grey"]];
	} else {
		_missedButton.selected = TRUE;
		[_tableController setMissedFilter:TRUE];
		_allButton.selected = FALSE;
        [_allButton.imageView setTintColor:[UIColor getColorByName:@"Grey"]];
        [_missedButton.imageView setTintColor:[UIColor getColorByName:@"MainColor"]];
	}
}

#pragma m ~ark - Action Functions

- (IBAction)onAllClick:(id)event {
	[self changeView:History_All];
}

- (IBAction)onMissedClick:(id)event {
	[self changeView:History_Missed];
}

- (IBAction)onDeleteClick:(id)event {
	NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Do you want to delete the selected calls from  call logs?", nil)];
	[UIConfirmationDialog ShowWithMessage:msg
		cancelMessage:nil
		confirmMessage:nil
		onCancelClick:^() {
		  [self onEditionChangeClick:nil];
		}
		onConfirmationClick:^() {
		  [_tableController removeSelectionUsing:nil];
		  [_tableController loadData];
		  [self onEditionChangeClick:nil];
		}];
}

- (IBAction)onEditionChangeClick:(id)sender {
	_allButton.hidden = _missedButton.hidden = self.tableController.isEditing;
    _selectedButtonImage.hidden = true;
}

@end
