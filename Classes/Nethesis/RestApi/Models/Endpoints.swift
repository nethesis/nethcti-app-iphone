//
//  Endpoints.swift
//  linphone
//
//  Created by Administrator on 08/11/2019.
//

import Foundation



struct Endpoints: Codable {
    
    let endpointsExtension: [EndpointExtension]
    let mainExtension: String?
    
    enum CodingKeys: String, CodingKey {
        case endpointsExtension = "extension"
        case mainExtension = "mainextension"
    }
}

extension Endpoints {
    
    init?(from:[String:Any]){
        
        guard let endpointExtension = from["extension"] as? [[String: Any]] else {
            return nil
        }
        
        var extensions: [EndpointExtension] = []
        
        for string in endpointExtension {
            
            guard let elem = string as [String: Any]? else {
                return nil
            }
            
            guard let ext = EndpointExtension(from: elem) else {
                return nil
            }
            
            extensions.append(ext)
        }
        
        self.endpointsExtension = extensions
        
        
        // Get the main extension.
        let mainextension = from["mainextension"] as? [[String:Any]]
        let idFirstMainextension = mainextension?[0]["id"] as? String
        self.mainExtension = idFirstMainextension
    }
    
    public func export() -> Endpoints {
        
        return Endpoints.init(endpointsExtension: self.endpointsExtension.map { $0.export() },
                              mainExtension: self.mainExtension)
    }
}
