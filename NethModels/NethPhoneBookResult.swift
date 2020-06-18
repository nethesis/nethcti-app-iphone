//
//  NethPhoneBookResult.swift
//  NethCTI
//
//  Created by Administrator on 21/04/2020.
//

import Foundation

// MARK: - PhonebookReturn
@objcMembers class NethPhoneBookReturn: NSObject {
    let count: Int
    var rows: [NethContact]

    init(count: Int, rows: [NethContact]) {
        self.count = count
        self.rows = rows
    }
    
    init(raw: [String:Any]) throws {
        guard let count = raw["count"] as? Int else {
            throw SerializationError.missing("count")
        }
        guard let rawRows = raw["rows"] as? [Any] else {
            throw SerializationError.missing("rows")
        }
        
        
        self.count = count
        self.rows = []
        for some in rawRows {
            guard let rawContact = some as? [String:Any] else {
                throw SerializationError.missing("contact")
            }
            
            self.rows.append(NethContact(raw: rawContact))
        }
        
    }
}
