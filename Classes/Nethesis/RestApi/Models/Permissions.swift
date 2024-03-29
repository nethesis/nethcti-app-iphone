//
//  Permissions.swift
//  NethCTI
//
//  Created by Democom S.r.l. on 21/01/22.
//

import Foundation


struct Permissions: Codable {
    let spy,
        intrude,
        ad_recording,
        pickup,
        hangup: AdPermission?
    var arrayPermissionGroups: [[String: AdPermission]]?
    var arrayKeyGroupEnable = [String]()
}


extension Permissions {
    
    init?(from:[String:Any]) {
        
        guard let spy = from["spy"] as? [String: Any],
            let intrude = from["intrude"] as? [String: Any],
            let ad_recording = from["ad_recording"] as? [String: Any],
            let pickup = from["pickup"] as? [String: Any],
            let hangup = from["hangup"] as? [String: Any] else {
                return nil
        }
        
        // azione “Spia”
        self.spy = AdPermission(from: spy)
        // azione “Intromettiti”
        self.intrude = AdPermission(from: intrude)
        // azione “Registra”
        self.ad_recording = AdPermission(from: ad_recording)
        self.pickup = AdPermission(from: pickup)
        // azione “Chiudi”
        self.hangup = AdPermission(from: hangup)
        
        var arrayAdPermission: [[String: AdPermission]] = []
        var arrayKeyNameEnables: [String] = []
        
        for (key, value) in from {
            
            if key.contains("grp_") {
                
                //print("Permissions key: \(key)")
                //print("Permissions value: \(value)")

                guard let currentGroupValue = value as? [String: Any] else {
                    return nil
                }
                //print("currentGroupValue: \(currentGroupValue)")

                let currentGroupAdPermission: AdPermission = AdPermission(from: currentGroupValue)!
                //print("currentGroupAdPermission: \(currentGroupAdPermission)")

                arrayAdPermission.append([key : currentGroupAdPermission])
                
                if currentGroupAdPermission.value {
                    
                    arrayKeyNameEnables.append(key)
                }
                
            }/*else {
                
                print("key: %@ NON aggiunta", key)
            }
            */
        }
                
        self.arrayPermissionGroups = arrayAdPermission
        //print("arrayPermissionGroups.count: \(arrayPermissionGroups?.count)")
        
        //print("arrayKeyNameEnables: \(arrayKeyNameEnables)")

        self.arrayKeyGroupEnable = arrayKeyNameEnables
        //print("arrayKeyGroupEnable.count: \(arrayKeyGroupEnable.count)")

    }
    
    func export() -> Permissions {
        return Permissions.init(spy: self.spy,
                                intrude: self.intrude,
                                ad_recording: self.ad_recording,
                                pickup: self.pickup,
                                hangup: self.hangup,
                                arrayPermissionGroups: self.arrayPermissionGroups,
                                arrayKeyGroupEnable: self.arrayKeyGroupEnable)
    }
}
