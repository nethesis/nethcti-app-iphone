//
//  TransferCallManager.m
//  NethCTI
//
//  Created by Administrator on 25/06/2020.
//

#import "TransferCallManager.h"

@implementation TransferCallManager

@synthesize call;
@synthesize isTransfer;

+(id)sharedManager {
    static TransferCallManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

-(id)init {
    if(self = [super init]) {
        call = nil;
        isTransfer = NO;
    }
    return self;
}

-(void) setmTransferCall:(LinphoneCall * _Nullable)dest {
    call = dest;
}

-(LinphoneCall *) getmTransferCall {
    return call;
}

-(void) isCallTransfer:(BOOL) is{
    isTransfer = is;
}

-(BOOL) isCallTransfer {
    return isTransfer;
}

@end
