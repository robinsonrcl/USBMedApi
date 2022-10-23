//
//  File.swift
//
//
//  Created by Robinson Cartagena
//

import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(User.v20221006.schemaName)
          .id()
          .field(User.v20221006.name, .string, .required)
          .field(User.v20221006.username, .string, .required)
          .field(User.v20221006.password, .string, .required)
          .field(User.v20221006.siwaIdentifier, .string)
          .field(User.v20221006.email, .string, .required)
          .field(User.v20221006.profilePicture, .string)
          .field(User.v20221006.twitterURL, .string)
          .unique(on: User.v20221006.email)
          .unique(on: User.v20221006.username)
          .create()
    }
    
    func revert(on database: Database) async throws {
      try await database.schema(User.v20221006.schemaName).delete()
    }
}

extension User {
    enum v20221006 {
        static let schemaName = "users"
        
        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
        static let username = FieldKey(stringLiteral: "username")
        static let password = FieldKey(stringLiteral: "password")
        static let siwaIdentifier = FieldKey(stringLiteral: "siwaIdentifier")
        static let email = FieldKey(stringLiteral: "email")
        static let profilePicture = FieldKey(stringLiteral: "profilePicture")
        static let twitterURL = FieldKey(stringLiteral: "twitterURL")
    }
}
