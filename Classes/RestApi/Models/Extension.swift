//
//  Extension.swift
//  NethCTI
//
//  Created by Democom S.r.l. on 22/02/22.
//

import Foundation


struct Extension: Codable {
    
    let exten: String?
    let conversations: Conversation?
    
    enum CodingKeys: String, CodingKey {
        case exten = "exten"
        case conversations = "conversations"
    }
}

extension Extension {
    
    init?(from:[String:Any]){
        
        guard let exten = from["exten"] as? String else {
            return nil
        }
        
        self.exten = exten
        
        guard let conversations = from["conversations"] as? [String: Any] else {
            return nil
        }
        
        //print("conversations: \(conversations)")
        
        if conversations.isEmpty {

            self.conversations = nil

        }else {
            
            guard let firstConversation = conversations.first?.value as? [String: Any] else {
                return nil
            }
            
            self.conversations = Conversation(from:firstConversation)
        }

    }
    
    public func export() -> ExtensionObjc {
        
        return ExtensionObjc.init(from: self)!
    }
}



@objc public class ExtensionObjc: NSObject, Codable {
    
    @objc public let exten: String?
    
    init?(from:Extension){
        
        self.exten = from.exten
    }
}

