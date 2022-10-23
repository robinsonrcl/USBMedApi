import Vapor
import Fluent
import FluentPostgresDriver

struct HallazgoController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let hallazgoRoute = routes.grouped("api","hallazgo")

    hallazgoRoute.get(use: getAllHallazgo)
  }

  func getAllHallazgo(_ req: Request) async throws -> [Hallazgo] {
    try await Hallazgo.query(on: req.db).all()
  }
}
