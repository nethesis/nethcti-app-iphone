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
    let id, extensionDescription, secret, username: String?
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
        
        let actions = from["actions"] as? [String: Any]
        
        self.id = from["id"] as? String
        self.type = type // This is the only field that can't be null.
        self.secret = from["secret"] as? String
        self.username = from["username"] as? String
        self.extensionDescription = from["description"] as? String
        self.actions = Actions(from:actions ?? ["":""])
        self.proxyPort = from["proxy_port"] as? Int
    }
}
