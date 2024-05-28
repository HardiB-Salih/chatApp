//
//  JSONWebTokenAuthenticator.swift
//
//
//  Created by HardiB.Salih on 5/28/24.
//

import Foundation
import Vapor

struct JSONWebTokenAuthenticator: AsyncRequestAuthenticator {
    func authenticate(request: Vapor.Request) async throws {
        try request.jwt.verify(as: AuthPayload.self)
    }
}

//struct JSONWebTokenAuthenticator: AsyncRequestAuthenticator {
//    typealias User = AuthenticatedUser // Specify the authenticated user type
//    
//    func authenticate(request: Vapor.Request) async throws {
//        guard let token = request.headers.bearerAuthorization?.token else {
//            return
//        }
//        
//        do {
//            let payload = try request.jwt.verify(token, as: AuthPayload.self)
//            // Here you should create your user object and attach it to the request
//            let user = AuthenticatedUser(userId: payload.userId)
//            request.auth.login(user)
//        } catch {
//            // Handle the error (logging, custom error response, etc.)
//            throw Abort(.unauthorized, reason: "Invalid or expired token.")
//        }
//    }
//}
//
//// Define a simple authenticated user type
//struct AuthenticatedUser: Authenticatable {
//    var userId: UUID
//}
//

