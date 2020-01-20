//
//  Endpoints.swift
//  linphone
//
//  Created by Administrator on 08/11/2019.
//

import Foundation

// MARK: - Endpoints
struct Endpoints: Codable {
    let endpointsExtension: [Extension]
    
    enum CodingKeys: String, CodingKey {
        case endpointsExtension = "extension"
    }
}

extension Endpoints {
    init?(from:[String:Any]){
        guard let endpointExtension = from["extension"] as? [[String: Any]] else {
            return nil
        }
        
        var extensions: [Extension] = []
        for string in endpointExtension {
            guard let elem = string as [String: Any]? else {
                return nil
            }
            
            guard let ext = Extension(from: elem) else {
                return nil
            }
            
            extensions.append(ext)
        }
        self.endpointsExtension = extensions
    }
}
