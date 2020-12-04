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
    let proxyPort : Int?
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
        self.proxyPort = nil //Verrà assegnato in PortableNethUser
    }
}

@objc public class PortableNethUser: NSObject {
    @objc public let name: String
    @objc public let username: String
    @objc public let intern: String
    @objc public let secret: String
    @objc public let proxyPort : Int
    
    init?(from:NethUser){
        self.name = from.name
        self.username = from.username
        let mobile = from.endpoints.endpointsExtension.first(where: { (Extension) -> Bool in
            Extension.type == "mobile"
        })!
        self.secret = mobile.secret
        self.intern = mobile.username
        self.proxyPort = mobile.proxyPort ?? -1
    }
}
