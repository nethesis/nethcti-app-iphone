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
        bool emptyLog = _historyLogs == nil || [_historyLogs count] == 0;
        [self.historyView setHidden:emptyLog];
        self.historyViewHeight.constant = emptyLog ? 0 : 175;
        [self.tableView reloadData];
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // If there isn't any log, the table view has to be hidden.
    bool emptyLog = _historyLogs == nil || [_historyLogs count] == 0;
    NSInteger numSections = emptyLog ? 0 : 1;
    return numSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    bool emptyLog = _historyLogs == nil || [_historyLogs count] == 0;
    NSInteger numRows = emptyLog ? 0 : [_historyLogs count];
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kCellId = @"RecentCallTableViewCell";
    
    RecentCallTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    
    if (cell == nil) {
        
        cell = [[RecentCallTableViewCell alloc] initWithIdentifier:kCellId];
    }
    
    @try {
        
        id logId = _historyLogs[indexPath.row];
        
        LinphoneCallLog *log = [logId pointerValue];
        
        if(!log) {
            
            return nil;
        }
        
        [cell setRecentCall:log];
        
        cell.contentView.userInteractionEnabled = false;
        
        return cell;
    }
    @catch (NSException *exception) {
        
        LOGE(@"Uncaught exception : %@", exception.description);
        
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 87;
}

@end
