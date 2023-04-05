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

#import "PhoneMainView.h"
#import "LinphoneManager.h"
#import "LinphoneIOSVersion.h"
#import "Utils/Utils.h"

@implementation AboutView

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;
+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:StatusBarView.class
                                                                 tabBar:nil
                                                               sideMenu:SideMenuView.class
                                                             fullscreen:false
                                                         isLeftFragment:YES
                                                           fragmentWith:nil];
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

#pragma mark - ViewController Functions

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the bundle name and version.
    NSString *name = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    _nameLabel.text = name;
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *curVersion = [NSString stringWithFormat:@"version %@(%@)",[infoDict objectForKey:@"CFBundleShortVersionString"], [infoDict objectForKey:@"CFBundleVersion"]];
    _appVersionLabel.text = [NSString stringWithFormat:@"%@ iOS %@", name, curVersion];
    _libVersionLabel.text = [NSString stringWithFormat:@"%@ SDK %s", @"Linphone", LINPHONE_SDK_VERSION];
    
    // Set the license tap gesture.
    [self addTapGesture:_licenceLabel action:@selector(onLicenceTap)];
    
    // Set the policy tap gesture.
    [self addTapGesture:_policyLabel action:@selector(onPolicyTap)];
    
    // Change title label color.
    _titleLabel.textColor = LINPHONE_MAIN_COLOR;
    _addressLabel.text = NSLocalizedStringFromTable(@"addressLabel.text", @"BrandLocalizable", @"");
    _cityLabel.text = NSLocalizedStringFromTable(@"cityLabel.text", @"BrandLocalizable", @"");
    _descriptionLabel.text = NSLocalizedStringFromTable(@"descriptionLabel.text", @"BrandLocalizable", @"");
    _descriptionLabel.textColor = LINPHONE_MAIN_COLOR;
    _faxLabel.text = NSLocalizedStringFromTable(@"faxLabel.text", @"BrandLocalizable", @"");
    _telLabel.text = NSLocalizedStringFromTable(@"telLabel.text", @"BrandLocalizable", @"");
    _urlLabel.text = NSLocalizedStringFromTable(@"urlLabel.text", @"BrandLocalizable", @"");
    
    // CGRect fullScreenRect = [[UIScreen mainScreen] applicationFrame];
    // UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:_outerView.frame];
    // _midView.frame = CGRectMake(_outerView.frame.origin.x, _outerView.frame.origin.y, _outerView.frame.size.width, _outerView.frame.size.height);
    [_midView setContentSize:CGSizeMake(_innerView.frame.size.width - 100, _innerView.frame.size.height + 100)];
    
    // do any further configuration to the scroll view
    // add a view, or views, as a subview of the scroll view.
    
    // release scrollView as self.view retains it
    // [scrollView addSubview:_innerView];
    // [_outerView addSubview:scrollView];
}

- (void)addTapGesture:(UILabel*)label action:(SEL)action {
    UITapGestureRecognizer *tapGestureRecognizerPolicy = [[UITapGestureRecognizer alloc] initWithTarget:self action:action];
    tapGestureRecognizerPolicy.numberOfTapsRequired = 1;
    [label addGestureRecognizer:tapGestureRecognizerPolicy];
    label.userInteractionEnabled = YES;
}

#pragma mark - Action Functions

- (IBAction)onLinkTap:(id)sender {
    UIGestureRecognizer *gest = sender;
    NSString *url = ((UILabel *)gest.view).text;
    if (![UIApplication.sharedApplication openURL:[NSURL URLWithString:url]]) {
        LOGE(@"Failed to open %@, invalid URL", url);
    }
}

- (IBAction)onPolicyTap {
    // TODO: This link must change.
    NSString *url = NSLocalizedStringFromTable(@"terms-and-privacy-url", @"BrandLocalizable", @"");;
    if (![UIApplication.sharedApplication openURL:[NSURL URLWithString:url]]) {
        LOGE(@"Failed to open %@, invalid URL", url);
    }
}

- (IBAction)onLicenceTap {
    NSString *url = @"https://www.gnu.org/licenses/gpl-3.0.html";
    if (![UIApplication.sharedApplication openURL:[NSURL URLWithString:url]]) {
        LOGE(@"Failed to open %@, invalid URL", url);
    }
}

- (IBAction)onDialerBackClick:(id)sender {
    [PhoneMainView.instance popCurrentView];
}

@end
