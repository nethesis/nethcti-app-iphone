//
//  PresenceUser.swift
//  NethCTI
//
//  Created by Marco on 25/01/22.
//

import Foundation


struct PresenceUser: Codable {
    
    let name: String?
    let username: String?
    let presence: String?
    let endpoints: Endpoints
    let mainExtension: String?
}


extension PresenceUser {
    
    init?(from: [String:Any]) throws {
        
        guard let name = from["name"] as? String else {
            
            return nil
        }
        self.name = name

        guard let username = from["username"] as? String else {
            
            return nil
        }
        self.username = username

        // MODIFICARE!!!!
        guard let presence = from["presence"] as? String else {
            
            return nil
        }
        self.presence = presence
                        
        
        guard let endpoints = from["endpoints"] as? [String: Any] else {
            return nil
        }
        self.endpoints = Endpoints(from:endpoints)!
        
        
        self.mainExtension = self.endpoints.mainExtension

    }
        
    
    public func portable() -> PortablePresenceUser {
        
        return PortablePresenceUser.init(from: self)!
    }
    
}

@objc public class PortablePresenceUser: NSObject, Codable {
    
    @objc public let name: String?
    @objc public let username: String?
    @objc public let presence: String?
    @objc public let mainExtension: String?
    //var endpoints: Endpoints

    
    init?(from:PresenceUser) {
        
        self.name = from.name
        self.username = from.username
        self.presence = from.presence
        self.mainExtension = from.endpoints.mainExtension
        //self.endpoints = from.endpoints

    }
}
