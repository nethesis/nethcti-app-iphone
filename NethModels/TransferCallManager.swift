//
//  TransferCallManager.swift
//  NethCTI
//
//  Created by Administrator on 08/07/2020.
//

import Foundation
import linphonesw

class TransferCallManager: NSObject {
    var call: Call?
    var isTransfer: Bool
    
    fileprivate override init(){
        call = nil
        isTransfer = false
    }
    private static var _singletonInstance: TransferCallManager?
    @objc public class func instance() -> TransferCallManager {
        if(_singletonInstance == nil) {
            _singletonInstance = TransferCallManager()
        }
        return _singletonInstance!
    }
    
    /**
     Get or set the call that we are transfering.
     */
    @objc public var mTransferCall: OpaquePointer? {
        get {
            return call?.getCobject
        }
        
        set {
            guard let tcall = Call.getSwiftObject(cObject: newValue!) as Call? else {
                print("[WEDO] Fail to get call to transfer.")
            }
            
            self.call = tcall
        }
    }
    
    /**
     Get or set if we are transfering a call or not.
     */
    @objc public var isCallTransfer: Bool {
        get {
            return isTransfer;
        }
        
        set {
            if(!newValue) {
                mTransferCall = nil
            }
            
            isTransfer = newValue;
        }
    }
}
