//
//  AdPermission.swift
//  NethCTI
//
//  Created by Democom S.r.l. on 21/01/22.
//

import Foundation

struct AdPermission: Codable {
    
    let id: String?
    let name: String?
    let value: Bool
}

extension AdPermission {
    
    init?(from:[String:Any]) {
        
        guard let id = from["id"] as? String else {
            return nil
        }
        self.id = id
        
        guard let name = from["name"] as? String else {
            return nil
        }
        self.name = name
        
        guard let value = from["value"] as? Bool else {
            return nil
        }
        self.value = value
    }
    
    func export() -> AdPermission {
        
        return AdPermission.init(id: self.id,
                                 name: self.name,
                                 value: self.value)
    }
}
