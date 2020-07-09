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
            // If we get a nil pointer, we save it.
            guard let callPointer = newValue as OpaquePointer? else {
                self.call = nil
                return
            }
                
            guard let tcall = Call.getSwiftObject(cObject: callPointer) as Call? else {
                // Error when we can't get the call from a not nil pointer.
                print("[WEDO] Fail to get call to transfer.")
                return
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
