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

#import "SideMenuTableView.h"
#import "PhoneMainView.h"

@interface SideMenuView : UIViewController

@property(strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeGestureRecognizer;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property(weak, nonatomic) IBOutlet UILabel *nameLabel;
@property(weak, nonatomic) IBOutlet UILabel *addressLabel;
@property(weak, nonatomic) IBOutlet UIImageView *presenceImage;
@property(strong, nonatomic) IBOutlet SideMenuTableView *sideMenuTableViewController;
@property(weak, nonatomic) IBOutlet UIView *grayBackground;
- (IBAction)onLateralSwipe:(id)sender;
- (IBAction)onHeaderClick:(id)sender;
- (IBAction)onBackgroundClicked:(id)sender;

@end
