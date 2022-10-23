import Fluent
import Vapor
import Foundation

final class Revisor: Model, Content {
  static let schema = "revisor"

  @ID
  var id: UUID?

  @Field(key: "cedula")
  var cedula: Int32

  @Field(key: "nombres")
  var nombres: String

  @Field(key: "apellidos")
  var apellidos: String

  @Field(key: "nickname")
  var nickname: String

  @Siblings(through:  HallazgoRevisorPivot.self, from: \.$revisor, to: \.$hallazgo)
  var hallazgos: [Hallazgo]

  init() {}

  init(id: UUID? = nil, 
      cedula: Int32 = 0,
      nombres: String, 
      apellidos: String, 
      nickname: String) {
    self.cedula = cedula
    self.nombres = nombres
    self.apellidos = apellidos
    self.nickname = nickname
  }
}
