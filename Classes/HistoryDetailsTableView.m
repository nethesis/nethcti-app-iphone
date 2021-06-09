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

#import "HistoryDetailsTableView.h"
#import "LinphoneManager.h"
#import "Utils.h"

@implementation HistoryDetailsTableView

- (void)loadDataForAddress:(const LinphoneAddress *)peer {
	if (callLogs == nil) {
		callLogs = [[NSMutableArray alloc] init];
	} else {
		[callLogs removeAllObjects];
	}

	if (peer) {
		const bctbx_list_t *logs = linphone_core_get_call_history_for_address(LC, peer);
		while (logs != NULL) {
			LinphoneCallLog *log = (LinphoneCallLog *)logs->data;
			if (linphone_address_weak_equal(linphone_call_log_get_remote_address(log), peer)) {
				[callLogs addObject:[NSValue valueWithPointer:log]];
			}
			logs = bctbx_list_next(logs);
		}
	}
	[[self tableView] reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [callLogs count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	CGRect frame = CGRectMake(0, 0, tableView.frame.size.width, 44);
	UIView *tempView = [[UIView alloc] initWithFrame:frame];
	if (@available(iOS 13, *)) {
		tempView.backgroundColor = [UIColor systemBackgroundColor];
	} else {
		tempView.backgroundColor = [UIColor whiteColor];
	}

	UILabel *tempLabel = [[UILabel alloc] initWithFrame:frame];
	tempLabel.backgroundColor = [UIColor clearColor];
	tempLabel.textColor = [UIColor getColorByName:@"MainColor"];
	tempLabel.text = NSLocalizedString(@"Calls", nil);
	tempLabel.textAlignment = NSTextAlignmentCenter;
    tempLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:24];

	tempLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[tempView addSubview:tempLabel];

	return tempView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellId = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    
    LinphoneCallLog *log = [[callLogs objectAtIndex:[indexPath row]] pointerValue];
    int duration = linphone_call_log_get_duration(log);
    time_t callTime = linphone_call_log_get_start_date(log);
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [UIColor getColorByName:@"Grey"];
    
    [cell.textLabel setText:[NSString stringWithFormat:@"%@ - %@",
                             [LinphoneUtils timeToString:callTime
                                              withFormat:LinphoneDateHistoryDetails],
                             [LinphoneUtils durationToString:duration]]];
    
    [self setCallIcon:cell.imageView byLog:log];
    
    cell.contentView.userInteractionEnabled = false;
    
    return cell;
}

/// Retreive the right icon from the call log status.
/// This method is shared with old history table view controller.
/// @param view UIImageView to change icon.
/// @param log Linphone Call Log to show.
- (void)setCallIcon:(UIImageView *)view byLog:(LinphoneCallLog *)log {
    const BOOL outgoing = linphone_call_log_get_dir(log) == LinphoneCallOutgoing;
    const BOOL missed = linphone_call_log_get_status(log) == LinphoneCallMissed;
    
    if (outgoing) {
        [view setImage:[UIImage imageNamed:@"nethcti_call_status_outgoing.png"]];
    } else if (missed) {
        [view setImage:[UIImage imageNamed:@"nethcti_call_status_missed.png"]];
    } else {
        [view setImage:[UIImage imageNamed:@"nethcti_call_status_incoming.png"]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

@end
