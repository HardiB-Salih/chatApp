//
//  File.swift
//  
//
//  Created by HardiB.Salih on 5/28/24.
//

import Foundation
import Vapor
import JWT

struct UserAuthenticator: JWTAuthenticator {
    typealias User = App.User

    func authenticate(jwt: AuthPayload, for request: Request) -> EventLoopFuture<Void> {
        User.find(jwt.userId, on: request.db).map { user in
            if let user = user {
                request.auth.login(user)
            }
        }
    }
}
