//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 8/11/22.
//

import Foundation
import Fluent

struct AddIcono: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema(Hallazgo.v20221108.schemaName)
      .field(Hallazgo.v20221108.icono, .string)
      .update()
  }
  
  func revert(on database: Database) async throws {
    try await database.schema(Hallazgo.v20221108.schemaName)
      .deleteField(Hallazgo.v20221108.icono).update()
  }
}
