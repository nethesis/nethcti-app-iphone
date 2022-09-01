//
//  Profile.swift
//  NethCTI
//
//  Created by Democom S.r.l. on 21/01/22.
//

import Foundation

struct Profile: Codable {
    
    let id: String?
    let name: String?
    let macroPermissions: MacroPermissions?
}

extension Profile {
    
    init?(from:[String:Any]){
        
        self.id = from["id"] as? String
        self.name = from["name"] as? String
        
        guard let macroPermissions = from["macro_permissions"] as? [String: Any] else {
            return nil
        }
        self.macroPermissions = MacroPermissions(from:macroPermissions)
    }
    
    public func export() -> Profile {
        
        return Profile.init(id: self.id,
                            name: self.name,
                            macroPermissions: self.macroPermissions)
    }
}
