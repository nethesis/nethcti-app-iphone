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

#import "UIMutedMicroButton.h"

@implementation UIMutedMicroButton

INIT_WITH_COMMON_CF {
    UIImage *dImage = [[UIImage imageNamed:@"nethcti_microphone.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setImage:dImage forState:UIControlStateNormal];
    UIImage *sImage = [[UIImage imageNamed:@"nethcti_microphone_disabled.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setImage:sImage forState:UIControlStateSelected];
    
    // Change UI Colors according to button state.
    [self setTintColor:[UIColor getColorByName:@"Grey"]];
    
    return self;
}

- (void)onOn {
	linphone_core_enable_mic(LC, false);
    
    // Change UI Colors according to button state.
    [self setTintColor:[UIColor getColorByName:@"Grey"]];
}

- (void)onOff {
	linphone_core_enable_mic(LC, true);
    
    // Change UI Colors according to button state.
    [self setTintColor:[UIColor getColorByName:@"Grey"]];
}

- (bool)onUpdate {
	return (linphone_core_get_current_call(LC) || linphone_core_is_in_conference(LC)) && !linphone_core_mic_enabled(LC);
}

@end
