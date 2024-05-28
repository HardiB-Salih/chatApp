//
//  ChannelDTO.swift
//
//
//  Created by HardiB.Salih on 5/28/24.
//

import Foundation
import Fluent
import Vapor

struct ChannelDTO: Content {
    var id: UUID?
    var name: String?
    var description: String?
    
    func toModel() -> Channel {
        return Channel(
            id: self.id,
            name: self.name ?? "",
            description: self.description ?? ""
        )
    }
}
