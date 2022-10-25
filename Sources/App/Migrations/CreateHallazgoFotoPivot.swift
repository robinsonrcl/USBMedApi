//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 23/10/22.
//

import Foundation
import Fluent

struct CreateHallazgoFotoPivot: AsyncMigration  {
  func prepare(on database: Database) async throws {
    try await database.schema("hallazgofotopivot")
      .id()
      .field("idhallazgo", .uuid, .required, .references("hallazgo", "id", onDelete: .cascade))
      .field("idfoto", .uuid, .required, .references("foto", "id", onDelete: .cascade))
      .create()
  }
  
  func revert(on database: Database) async throws {
    try await database.schema("hallazgofotopivot").delete()
  }
}
