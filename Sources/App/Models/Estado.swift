import Fluent
import Vapor

final class Estado: Model, Content {
  static let schema = "estado"

  @ID
  var id: UUID?

  @Field(key: "nombre")
  var nombre: String

  @Field(key: "icono")
  var icono: String

  @Field(key: "estado")
  var estado: Bool

  init() {}

  init(id: UUID? = nil, 
      nombre: String, 
      icono: String, 
      estado: Bool = true) {
    self.nombre = nombre
    self.icono = icono
    self.estado = estado
  }
}
