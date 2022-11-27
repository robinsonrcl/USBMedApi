//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 27/11/22.
//

import Foundation
import Fluent

struct AddConsecutivo: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema(Hallazgo.v20221108.schemaName)
      .field(Hallazgo.v20221127.consecutivo, .int)
      .update()
  }
  
  func revert(on database: Database) async throws {
    try await database.schema(Hallazgo.v20221108.schemaName)
      .deleteField(Hallazgo.v20221127.consecutivo).update()
  }
}

