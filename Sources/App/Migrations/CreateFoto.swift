import Fluent

struct CreateFoto: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema("foto")
    .id()
    .field("src", .string)
    .field("etiqueta", .string)
    .field("hallazgoID", .uuid, .required, .references("hallazgo", "id"))
    .create()
  }

  func revert(on database: Database) async throws {
    try await database.schema("foto").delete()
  }
}