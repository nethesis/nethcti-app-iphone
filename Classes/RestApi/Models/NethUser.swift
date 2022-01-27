//
//  NethUser.swift
//  linphone
//
//  Created by Administrator on 08/11/2019.
//

import Foundation

struct NethUser: Codable {
    
    let name: String?
    let username: String?
    let presence: String?
    let endpoints: Endpoints
    let profile: Profile
    let recallOnBusy: String?
    let mainExtension: String?
    let permissionsSpy: Bool?
    let permissionsIntrude: Bool?
    let permissionsRecording: Bool?
    let permissionsPickup: Bool?
    let permissionsHangup: Bool?
    let arrayPermissionsIdGroups: Array <String>?
}

enum SerializationError: Error {
    case missing(String)
}

extension NethUser {
    
    init?(from: [String:Any]) throws {
        
        guard let name = from["name"] as? String else {
            
            throw SerializationError.missing("name")
        }
        self.name = name

        guard let username = from["username"] as? String else {
            
            throw SerializationError.missing("username")
        }
        self.username = username

        // MODIFICARE...
        guard let presence = from["presence"] as? String,
            let endpoints = from["endpoints"] as? [String: Any] else {
            
                return nil
        }
        
        self.presence = presence
        self.endpoints = Endpoints(from:endpoints)!
        
        
        guard let profile = from["profile"] as? [String: Any] else {
            return nil
        }
        self.profile = Profile(from: profile)!
        
        guard let recallOnBusy = from["recallOnBusy"] as? String else {
            return nil
        }
        self.recallOnBusy = recallOnBusy
        
        self.mainExtension = self.endpoints.mainExtension

        self.permissionsSpy = self.profile.macroPermissions?.presencePanel?.permissions?.spy?.value

        self.permissionsIntrude = self.profile.macroPermissions?.presencePanel?.permissions?.intrude?.value
        
        self.permissionsRecording = self.profile.macroPermissions?.presencePanel?.permissions?.ad_recording?.value
        
        self.permissionsPickup = self.profile.macroPermissions?.presencePanel?.permissions?.pickup?.value
        
        self.permissionsHangup = self.profile.macroPermissions?.presencePanel?.permissions?.hangup?.value
        
        self.arrayPermissionsIdGroups = self.profile.macroPermissions?.presencePanel?.permissions?.arrayKeyGroupEnable
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
    let profile : Profile
    @objc public let recallOnBusy: String?
    @objc public let mainExtension: String?
    @objc public let permissionsSpy: Bool
    @objc public let permissionsIntrude: Bool
    @objc public let permissionsRecording: Bool
    @objc public let permissionsPickup: Bool
    @objc public let permissionsHangup: Bool
    @objc public let arrayPermissionsIdGroups: Array <String>
    
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
        self.profile = from.profile
        
        self.mainExtension = from.endpoints.mainExtension
        
        // --- Permessi ---
        self.recallOnBusy = from.recallOnBusy

        self.permissionsSpy = ((from.profile.macroPermissions?.presencePanel?.permissions?.spy?.value) != nil)
        
        self.permissionsIntrude = ((from.profile.macroPermissions?.presencePanel?.permissions?.intrude?.value) != nil)
        
        self.permissionsRecording = ((self.profile.macroPermissions?.presencePanel?.permissions?.ad_recording?.value) != nil)

        self.permissionsPickup = ((self.profile.macroPermissions?.presencePanel?.permissions?.pickup?.value) != nil)
        
        self.permissionsHangup = ((self.profile.macroPermissions?.presencePanel?.permissions?.hangup?.value) != nil)

        self.arrayPermissionsIdGroups = self.profile.macroPermissions?.presencePanel?.permissions?.arrayKeyGroupEnable ?? []
        
        // -----------------
    }
}
