import Fluent
import Vapor

final class Foto: Model, Content {
  static let schema = "foto"

  @ID
  var id: UUID?

  @Field(key: "src")
  var src: String

  @Field(key: "etiqueta")
  var etiqueta: String

  @Parent(key: "hallazgoID")
  var hallazgo: Hallazgo

  init() {}

  init(id: UUID? = nil, 
      src: String, 
      etiqueta: String,
      hallazgoID: Hallazgo.IDValue) {
    self.src = src
    self.etiqueta = etiqueta
    self.$hallazgo.id = hallazgoID
  }
}