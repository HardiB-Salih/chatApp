//
//  LoginResponseDTO.swift
//
//
//  Created by HardiB.Salih on 5/28/24.
//

import Foundation
import Vapor

// Define a struct to represent the login request payload
struct LoginRequestDTO: Content {
    var identifier: String
    var password: String
}
