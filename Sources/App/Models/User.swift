//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 26/05/22.
//

import Foundation
import Vapor

struct User: Content {
  let id: UUID
  let name: String
  let username: String

  init(id: UUID, name: String, username: String) {
    self.id = id
    self.name = name
    self.username = username
  }
}

extension User: Authenticatable {}
