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
    let barrier = 50
    
    /// Current contacts number loaded from user phonebook.
    var rows: Int
    
    /// True if can fetch more contacts, false otherwise. Reset it before a new call.
    var canFetch: Bool
    
    fileprivate override init() {
        rows = 0
        canFetch = true
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
        guard index > 0 else {
            print("Useless call for index below 0")
            return false;
        }
        
        return canFetch // && index + barrier > rows // rows < count &&
    }
    
    /// Increment the number of contacts loaded.
    /// - Parameters:
    ///   - number: number of contacts loaded in the last api call.
    ///   - more: true if there are more contacts to load in next call, false otherwise.
    @objc public func load(_ number: Int, more: Bool) {
        guard let n = number as Int?, n > 0 else {
            print("[PHONEBOOK] Loaded a phonebook with less than 0 contacts")
            return;
        }
        
        rows += number
        canFetch = more
    }
    
    /**
     Reset current max number of phonebook contacts.
     */
    @objc public func reset() -> Void {
        rows = 0
        canFetch = true;
    }
}
