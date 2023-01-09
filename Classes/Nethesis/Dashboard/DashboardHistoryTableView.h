//
//  DashboardHistoryTableView.h
//  NethCTI
//
//  Created by Luca Giorgetti on 31/05/2021.
//

#import <UIKit/UIKit.h>
#import "RecentCallTableViewCell.h"

#define HISTORY_SIZE 2

NS_ASSUME_NONNULL_BEGIN

@interface DashboardHistoryTableView : UITableViewController {
}


- (void)loadData;

@property (nonatomic) IBOutlet NSLayoutConstraint *historyViewHeight;
@property (weak, nonatomic) IBOutlet UIView *historyView;

@property(strong, nonatomic) NSMutableArray *historyLogs;

@end

NS_ASSUME_NONNULL_END
