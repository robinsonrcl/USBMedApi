//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 9/11/22.
//

import Foundation
import Fluent

struct AddColorestado: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema(Hallazgo.v20221108.schemaName)
      .field(Hallazgo.v20221109.colorestado, .string)
      .update()
  }
  
  func revert(on database: Database) async throws {
    try await database.schema(Hallazgo.v20221108.schemaName)
      .deleteField(Hallazgo.v20221109.colorestado).update()
  }
}
