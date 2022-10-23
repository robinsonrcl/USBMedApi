//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 22/10/22.
//

import Fluent

struct CreateHallazgoRevisorPivot: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("hallazgorevisorpivot")
            .id()
            .field("idhallazgo", .uuid, .required, .references("hallazgo", "id", onDelete: .cascade))
            .field("idrevisor", .uuid, .required, .references("revisor", "id", onDelete: .cascade))
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("hallazgorevisorpivot").delete()
    }
}
