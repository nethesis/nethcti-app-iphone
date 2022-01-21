//
//  MacroPermissions.swift
//  NethCTI
//
//  Created by Marco on 21/01/22.
//

import Foundation

struct MacroPermissions: Codable {
    
    let presencePanel: PresencePanel?
    
    enum CodingKeys: String, CodingKey {
        case presencePanel = "presence_panel"
    }
    
}

extension MacroPermissions {
    
    init?(from:[String:Any]){
                
        guard let presence_panel = from["presence_panel"] as? [String: Any] else {
            return nil
        }
        self.presencePanel = PresencePanel(from:presence_panel)
    }
    
    public func export() -> MacroPermissions {
        
        return MacroPermissions.init(presencePanel: self.presencePanel)
    }
}
