//
//  EndpointExtensions.swift
//  linphone
//
//  Created by Administrator on 08/11/2019.
//

import Foundation

// MARK: - Extension
struct Extension: Codable {
    let type: String
    let id,
        extensionDescription,
        secret,
        username: String?
    let actions: Actions?
    let proxyPort : Int?
    
    enum CodingKeys: String, CodingKey {
        case id, type, secret, username
        case extensionDescription = "description"
        case actions
        case proxyPort
    }
}

extension Extension {
    
    init?(from:[String:Any]){
        
        guard let type = from["type"] as? String else {
            
            return nil
        }
        self.type = type // This is the only field that can't be null.

        self.id = from["id"] as? String
        self.secret = from["secret"] as? String
        self.username = from["username"] as? String
        self.extensionDescription = from["description"] as? String
        
        let actions = from["actions"] as? [String: Any]
        self.actions = Actions(from:actions ?? ["":""])
        
        self.proxyPort = from["proxy_port"] as? Int
    }
    
    public func export() -> Extension {
        
        return Extension.init(type: self.type,
                              id: self.id,
                              extensionDescription: self.extensionDescription,
                              secret: nil,
                              username: self.username,
                              actions: self.actions,
                              proxyPort: self.proxyPort)
    }
}
