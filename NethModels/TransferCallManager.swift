//
//  TransferCallManager.swift
//  NethCTI
//
//  Created by Administrator on 08/07/2020.
//

import Foundation
import linphonesw

class TransferCallManager: NSObject {
    var origin: Call?
    var destination: Call?
    var isTransfer: Bool
    
    fileprivate override init(){
        origin = nil
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
     Get or set the origin call pointer before completing the transfer.
     */
    @objc public var mTransferCallOrigin: OpaquePointer? {
        get {
            return origin?.getCobject
        }
        
        set {
            // If we get a nil pointer, we save it.
            guard let callPointer = newValue as OpaquePointer? else {
                self.origin = nil
                // TODO: Set the destination call to nil too?
                return
            }
                
            guard let tcall = Call.getSwiftObject(cObject: callPointer) as Call? else {
                // Error when we can't get the call from a not nil pointer.
                print("[WEDO] Fail to get call to transfer.")
                return
            }
            
            self.origin = tcall
        }
    }
    
    /**
     Get or set the destination call pointer before completing the transfer.
     */
    @objc public var mTransferCallDestination: OpaquePointer? {
        get {
            return destination?.getCobject
        }
        set {
            // If we get a nil pointer, we save it.
            guard let callPointer = newValue as OpaquePointer? else {
                self.destination = nil
                // TODO: Set the origin call to nil too?
                return
            }
                
            guard let tcall = Call.getSwiftObject(cObject: callPointer) as Call? else {
                // Error when we can't get the call from a not nil pointer.
                print("[WEDO] Fail to get call to transfer.")
                return
            }
            
            self.destination = tcall
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
            // If we are not transfering anymore, set all pointer to nil.
            if(!newValue) {
                mTransferCallOrigin = nil
                mTransferCallDestination = nil
            }
            
            isTransfer = newValue;
        }
    }
}
