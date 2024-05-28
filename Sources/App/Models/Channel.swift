//
//  File.swift
//  
//
//  Created by HardiB.Salih on 5/28/24.
//

import Foundation
import Fluent
import Vapor

final class Channel: Model, @unchecked Sendable, Validatable {
    static let schema = "channel"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String
    
    init() { }
    init(id: UUID? = nil, name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
    }
    
    static func validations(_ validations: inout Vapor.Validations) {
        validations.add("name", as: String.self, is: !.empty, customFailureDescription: "Name cannot be empty.")
    }
    
}
