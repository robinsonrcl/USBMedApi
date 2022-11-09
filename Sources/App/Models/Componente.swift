import Fluent
import Vapor

final class Componente: Model, Content {
  static let schema = "componente"

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
      estado: Bool = false) {
    self.nombre = nombre
    self.icono = icono
    self.estado = estado
  }
}
