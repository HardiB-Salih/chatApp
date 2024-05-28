//
//  File.swift
//  
//
//  Created by HardiB.Salih on 5/28/24.
//
//static let schema = "channel"
//
//@ID(key: .id)
//var id: UUID?
//
//@Field(key: "name")
//var name: String
//
//@Field(key: "description")
//var description: String
import Foundation
import Fluent

struct ChannelMigration: AsyncMigration {
    func prepare(on database: any FluentKit.Database) async throws {
        try await database.schema("channel")
            .id()
            .field("name", .string, .required)
            .field("description", .string)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("channel").delete()
    }
    
    
}
