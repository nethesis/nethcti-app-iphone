//
//  NethUser.swift
//  linphone
//
//  Created by Administrator on 08/11/2019.
//

import Foundation

struct NethUser: Codable {
    let name, username, presence: String
    let endpoints: Endpoints
}

enum SerializationError: Error {
    case missing(String)
}

extension NethUser {
    init?(from: [String:Any]) throws {
        guard let name = from["name"] as? String else {
            throw SerializationError.missing("name")
        }
        guard let username = from["username"] as? String else {
            throw SerializationError.missing("username")
        }
        guard let presence = from["presence"] as? String,
            let endpoints = from["endpoints"] as? [String: Any] else {
                return nil
        }
        
        self.name = name
        self.username = username
        self.presence = presence
        self.endpoints = Endpoints(from:endpoints)!
    }
}

@objc public class PortableNethUser: NSObject {
    @objc public let name: String
    @objc public let username: String
    @objc public let intern: String
    @objc public let secret: String
    
    init?(from:NethUser){
        self.name = from.name
        self.username = from.username
        let ext = from.endpoints.endpointsExtension.first(where: { (Extension) -> Bool in
            Extension.type == "mobile"
        })!
        self.secret = ext.secret
        self.intern = ext.username
    }
}