//
//  PresencePanel.swift
//  NethCTI
//
//  Created by Democom S.r.l. on 21/01/22.
//

import Foundation


struct PresencePanel: Codable {
    
    let value: Bool
    let permissions: Permissions?
    
    enum CodingKeys: String, CodingKey {
        case value = "value"
        case permissions = "permissions"
    }
}

extension PresencePanel {
    
    init?(from:[String:Any]) {
        
        guard let value = from["value"] as? Bool else {
            return nil
        }
        self.value = value
        
        guard let permissions = from["permissions"] as? [String: Any] else {
            return nil
        }
        self.permissions = Permissions(from:permissions)
    }
    
    
    func export() -> PresencePanel {
        
        return PresencePanel.init(value: self.value,
                                  permissions: self.permissions)
    }
}
