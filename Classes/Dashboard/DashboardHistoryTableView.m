//
//  DashboardHistoryTableView.m
//  NethCTI
//
//  Created by Luca Giorgetti on 31/05/2021.
//

#import "DashboardHistoryTableView.h"

@implementation DashboardHistoryTableView

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(loadData)
                                               name:kLinphoneAddressBookUpdate
                                             object:nil];

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(loadData)
                                               name:kLinphoneCallUpdate
                                             object:nil];

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(coreUpdateEvent:)
                                               name:kLinphoneCoreUpdate
                                             object:nil];
    
    // Wait for the core update event.
    // [self loadData];
    // Fake event
    [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneCoreUpdate object:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [NSNotificationCenter.defaultCenter removeObserver:self name:kLinphoneAddressBookUpdate object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:kLinphoneCoreUpdate object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:kLinphoneCallUpdate object:nil];
}

#pragma mark - Event Functions

- (void)coreUpdateEvent:(NSNotification *)notif {
    @try {
        // Invalid all pointers
        [self loadData];
    }
    @catch (NSException *exception) {
        if ([exception.name isEqualToString:@"LinphoneCoreException"]) {
            LOGE(@"Core already destroyed");
            return;
        }
        LOGE(@"Uncaught exception : %@", exception.description);
        abort();
    }
}

- (void)loadData {
    for (id log in self.historyLogs) {
        linphone_call_log_unref([log pointerValue]);
    }
    
    const bctbx_list_t *logs = linphone_core_get_call_logs(LC);
    self.historyLogs = [NSMutableArray array];
    while (logs != NULL) {
        LinphoneCallLog *log = (LinphoneCallLog *)logs->data;
        if (self.historyLogs.count < HISTORY_SIZE) {
            [self.historyLogs addObject:[NSValue valueWithPointer: linphone_call_log_ref(log)]];
        }
        
        linphone_call_log_set_user_data(log, NULL);
        logs = bctbx_list_next(logs);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        // Here we calc the new total, this is a long time running operation.
        [self.tableView reloadData];
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _historyLogs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellId = @"RecentCallTableViewCell";
    RecentCallTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (cell == nil) {
        cell = [[RecentCallTableViewCell alloc] initWithIdentifier:kCellId];
    }
    
    id logId = _historyLogs[indexPath.row];
    LinphoneCallLog *log = [logId pointerValue];
    [cell setRecentCall:log];
    cell.contentView.userInteractionEnabled = false;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

@end
