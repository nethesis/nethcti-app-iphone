//
//  Group.swift
//  NethCTI
//
//  Created by Democom S.r.l. on 24/01/22.
//

import Foundation

struct Group: Codable {
    
    let id_group: String?
    let name: String?
    let users: [String]?
}

extension Group {
    
    init?(key: String, value:[String: Any]) {

        let id_group_lowercased: String = key.lowercased()
        //print("id_group_lowercased: \(id_group_lowercased)")
        
        let id_group_normalized = "grp_\(id_group_lowercased.stripped)"
        //print("id_group_normalized: \(id_group_normalized)")
        
        self.id_group = id_group_normalized
        
        self.name = key

        self.users = value["users"] as? [String]
    }
    
    func export() -> Group {
        return Group.init(id_group: self.id_group,
                          name: self.name,
                          users: self.users)
    }
    
    public func portable() -> PortableGroup {
        
        return PortableGroup.init(from: self)!
    }
}


@objc public class PortableGroup: NSObject, Codable {
    
    @objc public let id_group: String?
    @objc public let name: String?
    @objc public let users: [String]?

    init?(from:Group){
        
        self.id_group = from.id_group
        self.name = from.name
        self.users = from.users
    }
}


extension String {

    var stripped: String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        return self.filter {okayChars.contains($0) }
    }
}
