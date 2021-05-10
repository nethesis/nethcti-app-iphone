//
//  DashboardViewController.h
//  NethCTI
//
//  Created by Administrator on 07/04/2021.
//

#import <UIKit/UIKit.h>

#import "UICompositeView.h"
#import "LinphoneManager.h"
#import "PhoneMainView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DashboardViewController : TPMultiLayoutViewController <UITextFieldDelegate, UICompositeViewDelegate, MFMailComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property IBOutlet UIButton *dialerButton;
@property IBOutlet UIButton *historyButton;
@property IBOutlet UIButton *phonebookButton;
@property IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UITableView *historyTableView;

@end

NS_ASSUME_NONNULL_END
