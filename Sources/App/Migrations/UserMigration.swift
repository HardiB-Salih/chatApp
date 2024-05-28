//
//  UserMigration.swift
//
//
//  Created by HardiB.Salih on 5/28/24.
//

import Foundation
import Fluent

struct UserMigration: AsyncMigration {
    func prepare(on database: any FluentKit.Database) async throws {
        try await database.schema("users")
            .id()
            .field("name", .string, .required)
            .field("password", .string, .required)
            .field("username", .string, .required)
            .unique(on: "username") // Ensure username is unique
            .field("email", .string, .required)
            .unique(on: "email") // Ensure email is unique
            .field("avatar_name", .string, .required)
            .field("avatar_color", .string, .required)
            .create()
    }

    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema("users").delete()
    }
}
