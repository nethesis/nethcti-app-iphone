//
//  CallIdTest.swift
//  NethCTI
//
//  Created by Simone Raffaelli on 22/07/2020.
//

import Foundation
import linphonesw

class CallIdTest: NSObject {
    var callId: String?
    
    fileprivate override init(){
        callId = ""
    }
    private static var _singletonInstance: CallIdTest?
    @objc public class func instance() -> CallIdTest {
        if(_singletonInstance == nil) {
            _singletonInstance = CallIdTest()
        }
        return _singletonInstance!
    }
    
    /**
     Get or set the call that we are transfering.
     */
    @objc public var mCallId: String? {
        get {
            return callId
        }
        
        set {
            self.callId = newValue
        }
    }
}
