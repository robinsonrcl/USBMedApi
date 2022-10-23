import Fluent

struct CreateRevisor: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema("revisor")
    .id()
    .field("cedula", .int32)
    .field("nombres", .string)
    .field("apellidos", .string)
    .field("nickname", .string)
    .create()
  }

  func revert(on database: Database) async throws {
    try await database.schema("revisor").delete()
  }
}
