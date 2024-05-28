//
//  AuthPayload.swift
//  
//
//  Created by HardiB.Salih on 5/28/24.
//

import Foundation
import JWT

struct AuthPayload: JWTPayload {
    enum CodingKeys: String, CodingKey {
        case expiration = "exp"
        case userId = "uid"
    }
    
    var expiration: ExpirationClaim
    var userId: UUID
    
    init(userId: UUID) {
        self.userId = userId
        
        //Add 90 day as expiration date
        var dateComponents = DateComponents()
        dateComponents.month = 3
        let expirationDate = Calendar.current.date(byAdding: dateComponents, to: Date())!
        self.expiration = ExpirationClaim(value: expirationDate)
    }
    
    func verify(using signer: JWTSigner) throws {
        try self.expiration.verifyNotExpired()
    }
}


