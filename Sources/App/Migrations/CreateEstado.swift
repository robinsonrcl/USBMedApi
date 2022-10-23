import Fluent

struct CreateEstado: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema("estado")
    .id()
    .field("nombre", .string)
    .field("icono", .string)
    .field("estado", .bool )
    .create()
  }

  func revert(on database: Database) async throws {
    try await database.schema("estado").delete()
  }
}
