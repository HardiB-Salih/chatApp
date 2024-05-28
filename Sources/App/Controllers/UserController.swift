//
//  UserController.swift
//
//
//  Created by HardiB.Salih on 5/28/24.
//

import Foundation
import Vapor
import Fluent

class UserController: RouteCollection, @unchecked Sendable {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let api = routes.grouped("api")
        api.post("register", use: register.self)
        api.post("login", use: login.self)

        let protectedUser = api.grouped("users").grouped(JSONWebTokenAuthenticator())
        protectedUser.get(use: listUsers.self)
        protectedUser.post("change-password", ":userId", use: changePassword.self)
        protectedUser.get(":userId", use: findUserById.self)
        protectedUser.patch(":userId", use: updateUserProfile.self)
        protectedUser.delete(":userId", use: deleteUser.self)
    }
    
    @Sendable
    func register(req: Request) async throws -> UserResponseDTO {
        // Validate the user input
        try User.validate(content: req)
        let user = try req.content.decode(User.self)
        
        // Check if the email is already taken
        if let _ = try await User.query(on: req.db)
            .filter(\.$email == user.email)
            .first() {
            throw Abort(.conflict, reason: "A user with this email already exists.")
        }
        
        // Check if the username is already taken
        if let _ = try await User.query(on: req.db)
            .filter(\.$username == user.username)
            .first() {
            throw Abort(.conflict, reason: "A user with this username already exists.")
        }
        
        // Hash the password
        user.password = try await req.password.async.hash(user.password)
        
        // Save the user to the database
        // Return the user DTO
        try await user.save(on: req.db)
        return try UserResponseDTO(error: false, userId: user.requireID())
    }
    
    @Sendable
    func login(req: Request) async throws -> UserResponseDTO {
        // Retrieve the username or email from request parameters
        let user = try req.content.decode(LoginRequestDTO.self)

        let existUser = try await findUser(identifier: user.identifier, on: req.db)
        
        // Validate the password
        let result = try await req.password.async.verify(user.password, created: existUser.password)
        if !result {
            throw Abort(.badRequest, reason: "Incorrect password")
        }

        // generate the token and return it to user
        // Create a Payload using JWT package
        let authPayload = try AuthPayload(userId:  existUser.requireID())
        
        return try UserResponseDTO(error: false, token: req.jwt.sign(authPayload), userId: existUser.requireID())
    }
    
    @Sendable
    func changePassword(req: Request) async throws -> UserResponseDTO {
        let changePasswordDTO = try req.content.decode(ChangePasswordDTO.self)
        
        // Get authenticated user from the request
        let user = try await getUserById(req: req)
        
        // Verify the current password
        let result = try await req.password.async.verify(changePasswordDTO.currentPassword, created: user.password)
        if !result {
            throw Abort(.badRequest, reason: "Current password is incorrect")
        }
        
        // Hash the new password and update the user
        user.password = try await req.password.async.hash(changePasswordDTO.newPassword)
        try await user.save(on: req.db)
        
        return try UserResponseDTO(error: false, userId: user.requireID())
    }
    
    @Sendable
    func listUsers(req: Request) async throws -> [UserDOT] {
        let users = try await User.query(on: req.db).all()
        return users.map { $0.toDTO() }
    }
    
    @Sendable
    func findUserById(req: Request) async throws -> UserDOT {
        let user = try await getUserById(req: req)
        return user.toDTO()
    }
    
    @Sendable
    func updateUserProfile(req: Request) async throws -> UserDOT {
        let foundUser = try await getUserById(req: req)
        
        let updateUserDTO = foundUser.toDTO()
            let user = try req.auth.require(User.self)

            if let name = updateUserDTO.name {
                user.name = name
            }
            if let email = updateUserDTO.email {
                user.email = email
            }
            if let avatarName = updateUserDTO.avatarName {
                user.avatarName = avatarName
            }
            if let avatarColor = updateUserDTO.avatarColor {
                user.avatarColor = avatarColor
            }

            try await user.save(on: req.db)
            return user.toDTO()
    }
    
    @Sendable
    func deleteUser(req: Request) async throws -> UserResponseDTO {
        // get user id
        guard let userId =  req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        // Fetch the user from the database
        guard let user = try await User.find(userId, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        
        try await user.delete(on: req.db)
        return UserResponseDTO(error: false)
    }
    
}


extension UserController {
    // Function to find user by email or username
    private func findUser(identifier: String, on database: Database) async throws -> User {
        if let user = try await User.query(on: database).filter(\.$email == identifier).first() {
            return user
        } else if let user = try await User.query(on: database).filter(\.$username == identifier).first() {
            return user
        } else {
            throw Abort(.unauthorized, reason: "Invalid credentials")
        }
    }
    
    private func getUserById(req: Request) async throws -> User {
        // get user id
        guard let userId =  req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        // Fetch the user from the database
        guard let user = try await User.find(userId, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        
        return user
    }

}
