//
//  NethCTIAPI.ErrorCodes.swift
//  linphone
//
//  Created by Administrator on 17/12/2019.
//

import Foundation

extension NethCTIAPI {
    /**
     Those enums was used for coding common api errors.
     */
    public enum ErrorCodes : String {
        case MissingAuthentication = "No authentication provided."
        case MissingServerURL = "Cannot create URL."
    }
}
