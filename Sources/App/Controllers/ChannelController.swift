//
//  ChannelController.swift
//
//
//  Created by HardiB.Salih on 5/28/24.
//

import Foundation
import Vapor
import Fluent

class ChannelController: RouteCollection, @unchecked Sendable {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let api = routes.grouped("api")
        let protectedChannel = api.grouped("channel").grouped(JSONWebTokenAuthenticator())
        protectedChannel.post(use: addChanel.self)
        protectedChannel.get(use: getAllChannel.self)
        protectedChannel.get(":channelId",use: findChannelById.self)
        protectedChannel.put(":channelId",use: updateChannelById.self)
        protectedChannel.delete(":channelId",use: deleteChannelById.self)

    }
    
    @Sendable
    func addChanel(req: Request) async throws -> ChannelDTO {
        try Channel.validate(content: req)
        let channel = try req.content.decode(Channel.self)
        
        // Check if the username is already taken
        if let _ = try await Channel.query(on: req.db)
            .filter(\.$name == channel.name)
            .first() {
            throw Abort(.conflict, reason: "A channel with this name already exists.")
        }
        
        try await channel.save(on: req.db)
        
        return channel.toDTO()
    }
    
    @Sendable
    func getAllChannel(req: Request) async throws -> [ChannelDTO] {
        let channels = try await Channel.query(on: req.db).all()
        return channels.map { $0.toDTO() }
    }
    
    @Sendable
    func findChannelById(req: Request) async throws -> ChannelDTO {
        let channel = try await getChannel(withRequest: req)
        return channel.toDTO()
    }
    
    @Sendable
    func updateChannelById(req: Request) async throws -> ChannelDTO {
        let foundChannel = try await getChannel(withRequest: req)
        let updateChannelDTO = try req.content.decode(ChannelDTO.self)
        
        if let name = updateChannelDTO.name {
            foundChannel.name = name
        }
        if let description = updateChannelDTO.description {
            foundChannel.description = description
        }
        
        try await foundChannel.save(on: req.db)
        return foundChannel.toDTO()
    }
    
    @Sendable
    func deleteChannelById(req: Request) async throws -> UserResponseDTO {
        let channel = try await getChannel(withRequest: req)
        try await channel.delete(on: req.db)
        return UserResponseDTO(error: false)
    }
    
}


extension ChannelController {
    private func getChannel(withRequest req: Request) async throws -> Channel {
        // get user id
        guard let channelId =  req.parameters.get("channelId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Your channel Id is not correct")
        }
        
        // Fetch the user from the database
        guard let channel = try await Channel.find(channelId, on: req.db) else {
            throw Abort(.notFound, reason: "Channel not found")
        }
        
        return channel
    }
}
