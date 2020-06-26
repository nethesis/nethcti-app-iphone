//
//  TransferCallManager.h
//  NethCTI
//
//  Created by Administrator on 25/06/2020.
//

#import <Foundation/Foundation.h>
#include "linphone/linphonecore.h"

NS_ASSUME_NONNULL_BEGIN

@interface TransferCallManager : NSObject {
    LinphoneCall *call;
    BOOL isTransfer;
}

@property (nonatomic, nullable) LinphoneCall *call;
@property (nonatomic) BOOL isTransfer;

+(id)sharedManager;

// Getter setter for the address where is transfer.
-(void)setmTransferCall:(LinphoneCall * _Nullable) address;
-(LinphoneCall *)getmTransferCall;

// Getter setter when the call is transfer.
-(void) isCallTransfer:(BOOL) is;
-(BOOL) isCallTransfer;

@end

NS_ASSUME_NONNULL_END
