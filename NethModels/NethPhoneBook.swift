//
//  NethPhoneBook.swift
//  NethCTI
//
//  Created by Administrator on 27/01/2021.
//

import Foundation
import linphonesw

class NethPhoneBook: NSObject {
    var map: Dictionary<String, NethContact>
    
    fileprivate override init() {
        map = Dictionary<String, NethContact>()
    }
    private static var _singleton: NethPhoneBook?
    @objc public class func instance() -> NethPhoneBook {
        if _singleton == nil {
            _singleton = NethPhoneBook()
        }
        return _singleton!
    }
}
