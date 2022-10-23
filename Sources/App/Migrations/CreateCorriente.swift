//
//  File.swift
//
//
//  Created by Robinson Cartagena on 6/10/22.
//

import Fluent

struct CreateCorriente: AsyncMigration {

  func prepare(on database: Database) async throws {
    try await database.schema("corriente")
    .id()
    .field("nombre", .string, .required)
    .field("puntomedio", .string)
    .field("coordenadas", .string)
    .field("etiquetas", .string)
    .field("descripcion", .string)
    .field("fecha", .date)
    .field("contratoID", .uuid, .required, .references("contrato", "id"))
    .create()
  }
    
  func revert(on database: Database) async throws {
    try await database.schema("corriente").delete()
  }
}
