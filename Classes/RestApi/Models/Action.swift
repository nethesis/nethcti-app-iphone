//
//  Action.swift
//  linphone
//
//  Created by Administrator on 08/11/2019.
//

import Foundation

// MARK: - Actions
struct Actions: Codable {
    let answer, dtmf, hold: Bool
}

extension Actions {
    init?(from:[String:Any]) {
        guard let answer = from["answer"] as? Bool,
            let dtmf = from["dtmf"] as? Bool,
            let hold = from["hold"] as? Bool else {
                return nil
        }
        
        self.answer = answer
        self.dtmf = dtmf
        self.hold = hold
    }
}
