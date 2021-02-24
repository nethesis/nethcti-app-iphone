//
//  NethPhoneBook.swift
//  NethCTI
//
//  Created by Administrator on 27/01/2021.
//

import Foundation
import linphonesw

/**
 Singleton store of number of phonebook rows already downloaded from remote phonebook and max contacts to download.
 */
class NethPhoneBook: NSObject {
    /// Total number of contacts in neth user phonebook.
    var count: Int
    
    /// Current contacts number loaded from user phonebook.
    var rows: Int
    
    fileprivate override init() {
        count = 0;
        rows = 0;
    }
    
    private static var _singleton: NethPhoneBook?
    
    @objc public class func instance() -> NethPhoneBook {
        if _singleton == nil {
            _singleton = NethPhoneBook()
        }
        return _singleton!
    }
    
    /**
     Return true if api can return more results.
     
     If rows is equal or more the count of phonebook contact, no more contacts need to be downloaded.
     */
    @objc public func hasMore(_ index: Int) -> Bool {
        return rows < count && index + 50 > rows
    }
    
    /// Increment the number of contacts loaded.
    /// - Parameters:
    ///   - number: number of contacts loaded in the last api call.
    ///   - max: max contacts number in the user phonebook.
    @objc public func load(_ number: Int, max: Int) {
        rows += number;
        count = max;
    }
    
    /**
     Reset current max number of phonebook contacts.
     */
    @objc public func reset() -> Void {
        rows = 0;
    }
}
