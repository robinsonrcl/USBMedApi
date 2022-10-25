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
  
  @Siblings(through:  HallazgoFotoPivot.self, from: \.$foto, to: \.$hallazgo)
  var hallazgos: [Hallazgo]

  init() {}

  init(id: UUID? = nil, 
      src: String, 
      etiqueta: String) {
    self.src = src
    self.etiqueta = etiqueta
  }
}
