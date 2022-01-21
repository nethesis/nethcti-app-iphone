//
//  Permissions.swift
//  NethCTI
//
//  Created by Marco on 21/01/22.
//

import Foundation


struct Permissions: Codable {
    let spy,
        intrude,
        ad_recording,
        pickup,
        hangup: AdPermission?
}

extension Permissions {
    
    init?(from:[String:Any]) {
        
        guard let spy = from["spy"] as? AdPermission,
            let intrude = from["intrude"] as? AdPermission,
            let ad_recording = from["ad_recording"] as? AdPermission,
            let pickup = from["pickup"] as? AdPermission,
            let hangup = from["hangup"] as? AdPermission else {
                return nil
        }
        
        // azione “Spia”
        self.spy = spy
        // azione “Intromettiti”
        self.intrude = intrude
        // azione “Registra”
        self.ad_recording = ad_recording
        self.pickup = pickup
        // azione “Chiudi”
        self.hangup = hangup
    }
    
    func export() -> Permissions {
        return Permissions.init(spy: self.spy,
                                intrude: self.intrude,
                                ad_recording: self.ad_recording,
                                pickup: self.pickup,
                                hangup: self.hangup)
    }
}
