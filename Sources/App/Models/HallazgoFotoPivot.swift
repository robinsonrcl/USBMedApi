//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 23/10/22.
//

import Foundation
import Fluent

final class HallazgoFotoPivot: Model {
  static let schema = "hallazgofotopivot"
  
  @ID
  var id: UUID?
  
  @Parent(key: "idhallazgo")
  var hallazgo: Hallazgo
  
  @Parent(key: "idfoto")
  var foto: Foto
  
  init() {}
  
  init(id: UUID? = nil, hallazgo: Hallazgo, foto: Foto) throws {
    self.id = id
    self.$hallazgo.id = try hallazgo.requireID()
    self.$foto.id = try foto.requireID()
  }
}
