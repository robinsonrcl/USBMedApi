//
//  File.swift
//
//
//  Created by Robinson Cartagena on 6/10/22.
//

import Fluent

struct CreateContrato: AsyncMigration {

  func prepare(on database: Database) async throws {
    try await database.schema("contrato")
    .id()
    .field("nombre", .string, .required)
    .field("fecha", .date)
    .field("year", .int16)
    .field("mes", .int16)
    .field("descripcion", .string)
    .create()
  }
    
  func revert(on database: Database) async throws {
      try await database.schema("contrato").delete()
  }
}