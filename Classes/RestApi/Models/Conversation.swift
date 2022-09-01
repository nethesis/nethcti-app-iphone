//
//  Conversation.swift
//  NethCTI
//
//  Created by Democom S.r.l. on 21/02/22.
//

import Foundation


struct Conversation: Codable {
    
    let conversationId: String?
    let owner: String?
    
    enum CodingKeys: String, CodingKey {
        case conversationId = "id"
        case owner = "owner"
    }
}

extension Conversation {
    
    init?(from:[String:Any]){
        
        guard let conversationId = from["id"] as? String else {
            return nil
        }
        
        self.conversationId = conversationId
        
        guard let owner = from["owner"] as? String else {
            return nil
        }
        
        self.owner = owner
    }
    
    public func exportObjc() -> ConversationObjc {
        
        return ConversationObjc.init(from: self)!
    }
}



@objc public class ConversationObjc: NSObject, Codable {
    
    @objc public let conversationId: String?
    @objc public let owner: String?
    
    init?(from:Conversation){
        
        self.conversationId = from.conversationId
        self.owner = from.owner
        
    }
}
