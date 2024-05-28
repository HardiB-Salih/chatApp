//
//  File.swift
//  
//
//  Created by HardiB.Salih on 5/28/24.
//

import Fluent
import Vapor

struct UserDOT: Content {
    var id: UUID?
    var name: String?
    var email: String?
    var username: String?
    var avatarName: String?
    var avatarColor: String?
    
    func toModel() -> User {
        return User(
            id: self.id,
            name: self.name ?? "",
            email: self.email ?? "",
            username: self.username ?? "",
            password: "", // Password is handled separately
            avatarName: self.avatarName ?? "",
            avatarColor: self.avatarColor ?? ""
        )
    }
}
