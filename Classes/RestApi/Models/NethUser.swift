//
//  NethUser.swift
//  linphone
//
//  Created by Administrator on 08/11/2019.
//

import Foundation

struct NethUser: Codable {
    let name, username, presence: String?
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
    
    public func export() -> PortableNethUser {
        let user = PortableNethUser.init(from: self)
        user?.endpoints = self.endpoints.export()
        return user!
    }
    
    public func portable() -> PortableNethUser {
        return PortableNethUser.init(from: self)!
    }
}

@objc public class PortableNethUser: NSObject, Codable {
    @objc public let name, username, presence: String?
    var endpoints: Endpoints
    @objc public let intern: String?
    @objc public let secret: String?
    @objc public let proxyPort : Int
    
    init?(from:NethUser){
        self.name = from.name
        self.username = from.username
        self.presence = from.presence
        self.endpoints = from.endpoints
        let mobile = from.endpoints.endpointsExtension.first(where: { (Extension) -> Bool in
            Extension.type == "mobile"
        })!
        self.secret = mobile.secret
        self.intern = mobile.username
        self.proxyPort = mobile.proxyPort ?? -1
    }
}
