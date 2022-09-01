//
//  PresenceUser.swift
//  NethCTI
//
//  Created by Democom S.r.l. on 25/01/22.
//

import Foundation


struct PresenceUser: Codable {
    
    let name: String?
    let username: String?
    let presence: String?
    let mainPresence: String?
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

        guard let presence = from["presence"] as? String else {
            
            return nil
        }
        self.presence = presence
                        
        guard let mainPresence = from["mainPresence"] as? String else {
            
            return nil
        }
        self.mainPresence = mainPresence
        
        guard let endpoints = from["endpoints"] as? [String: Any] else {
            return nil
        }
        self.endpoints = Endpoints(from:endpoints)!
        
        
        self.mainExtension = self.endpoints.mainExtension

    }
        
    
    public func exportObjc() -> PresenceUserObjc {
        
        return PresenceUserObjc.init(from: self)!
    }
    
}

@objc public class PresenceUserObjc: NSObject, Codable {
    
    @objc public let name: String?
    @objc public let username: String?
    @objc public let presence: String?
    @objc public let mainPresence: String?
    @objc public let mainExtension: String?
    var endpoints: Endpoints
    @objc public let arrayExtensionsId: Array <String>

    
    init?(from:PresenceUser) {
        
        self.name = from.name
        self.username = from.username
        self.presence = from.presence
        self.mainPresence = from.mainPresence

        self.mainExtension = from.endpoints.mainExtension
        self.endpoints = from.endpoints

        var extensionsId: [String] = []
        
        for currentExtension in from.endpoints.endpointsExtension {
                        
            guard let ext = currentExtension.id as String? else {
                
                return nil
            }
            
            extensionsId.append(ext)
        }
        //print("extensionsId: \(extensionsId)");

        self.arrayExtensionsId = extensionsId
    }
}
