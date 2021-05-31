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

#import <AudioToolbox/AudioToolbox.h>
#import "UISpeakerButton.h"

#include "linphone/linphonecore.h"

@implementation UISpeakerButton

INIT_WITH_COMMON_CF {
	[NSNotificationCenter.defaultCenter addObserver:self
										   selector:@selector(audioRouteChangeListenerCallback:)
											   name:AVAudioSessionRouteChangeNotification
											 object:nil];
    
    UIImage *dImage = [[UIImage imageNamed:@"nethcti_volume.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setImage:dImage forState:(UIControlStateNormal | UIControlStateSelected)];
	return self;
}

- (void)dealloc {
	[NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - UIToggleButtonDelegate Functions

- (void)audioRouteChangeListenerCallback:(NSNotification *)notif {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self update];
    });
}

- (void)onOn {
	[CallManager.instance enableSpeakerWithEnable:TRUE];
    
    // Change UI Colors according to button state.
    [self.imageView setTintColor:[UIColor getColorByName:@"MainColor"]];
    
    UIImage *dImage = [UIImage imageNamed:@"nethcti_blue_circle.png"];
    [self setBackgroundImage:dImage forState:UIControlStateNormal];
}

- (void)onOff {
	[CallManager.instance enableSpeakerWithEnable:FALSE];
    
    // Change UI Colors according to button state.
    [self.imageView setTintColor:[UIColor getColorByName:@"Grey"]];
    
    UIImage *dImage = [UIImage imageNamed:@"nethcti_grey_circle.png"];
    [self setBackgroundImage:dImage forState:UIControlStateNormal];
}

- (bool)onUpdate {
	self.enabled = [CallManager.instance allowSpeaker];
	return CallManager.instance.speakerEnabled;
}

@end
