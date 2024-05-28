//
//  UserResponseDTO.swift
//
//
//  Created by HardiB.Salih on 5/28/24.
//

import Foundation
import Vapor

struct UserResponseDTO: Content {
    let error  : Bool
    var reason : String? = nil
    var token  : String? = nil
    var userId : UUID? = nil
    
    init(error: Bool, reason: String? = nil, token: String? = nil, userId: UUID? = nil) {
        self.error = error
        self.reason = reason
        self.token = token
        self.userId = userId
    }
}
