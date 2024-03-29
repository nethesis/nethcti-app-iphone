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

#import "UICompositeView.h"
#import "TPMultiLayoutViewController.h"
#include "linphone/linphonecore.h"
#import "UIRoundedImageView.h"
//#import "../NethModels/TransferCallManager.h"
#import "UISpeakerButton.h"
#import "UIToggleButton.h"
#import "UIMutedMicroButton.h"
#import "UIBluetoothButton.h"

@interface CallOutgoingView : TPMultiLayoutViewController <UICompositeViewDelegate> {
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property(weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property(weak, nonatomic) IBOutlet UILabel *nameLabel;
@property(weak, nonatomic) IBOutlet UISpeakerButton *speakerButton;
@property(weak, nonatomic) IBOutlet UILabel *addressLabel;
@property(weak, nonatomic) IBOutlet UIToggleButton *routesButton;
@property(weak, nonatomic) IBOutlet UIView *routesView;
@property(weak, nonatomic) IBOutlet UIBluetoothButton *routesBluetoothButton;
@property(weak, nonatomic) IBOutlet UIButton *routesEarpieceButton;
@property(weak, nonatomic) IBOutlet UISpeakerButton *routesSpeakerButton;
@property(weak, nonatomic) IBOutlet UIMutedMicroButton *microButton;
@property (weak, nonatomic) IBOutlet UILabel *nameInitialsLabel;

- (IBAction)onDeclineClick:(id)sender;

@end
