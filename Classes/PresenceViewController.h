
#import <UIKit/UIKit.h>
#import "UICompositeView.h"
#import "RecordingsListTableView.h"
//#import "UIInterfaceStyleButton.h"



@interface PresenceViewController : UIViewController <UICompositeViewDelegate>

@property (strong, nonatomic) IBOutlet RecordingsListTableView *tableController;
@property (strong, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

- (IBAction)onBackPressed:(id)sender;

@end
