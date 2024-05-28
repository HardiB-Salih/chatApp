//
//  File.swift
//  
//
//  Created by HardiB.Salih on 5/28/24.
//

import Foundation
import Vapor

struct ChangePasswordDTO: Content {
    var currentPassword: String
    var newPassword: String
}
