//
//  File.swift
//
//
//  Created by Robinson Cartagena on 6/10/22.
//

import Fluent

struct CreateHallazgo: AsyncMigration {

    func prepare(on database: Database) async throws {
    let enumMargen = try await database.enum("enumMargen")
                      .case("M_DERECHA")
                      .case("M_IZQUIERDA")
                      .case("NA")
                      .case("CENTRO")
                      .create()
      
    let enumZona = try await database.enum("enumZona")
                      .case("SUR_CANALIZADA")
                      .case("SUR_SIN_CANALIZAR")
                      .case("NORTE_CANALIZADA")
                      .case("NORTE_SIN_CANALIZAR")
                      .case("CENTRO_CANALIZADA")
                      .case("NA")
                      .create()
      
      let  enumComponente  = try await database.enum("enumComponente")
        .case("BARRA")
        .case("ESTRUCTURA_DE_CAIDA")
        .case("MURO")
        .case("OBSTRUCCION")
        .case("PLACA")
        .case("AZUD")
        .case("BANCA")
        .case("BOCATOMA")
        .case("BOLSA_DE_GRAVILLA")
        .case("CONTRADIQUE")
        .case("CONTROL_DE_GRADIENTE")
        .case("DIQUE")
        .case("DIRECCIONADOR")
        .case("GAVION")
        .case("LLAVE")
        .case("TABIQUE")
        .case("TRAVIEZA")
        .create()

      let enumEstado = try await database.enum("enumEstado")
        .case("BUENO")
        .case("MALO")
        .case("REGULAR")
        .case("NA")
        .case("SIN_ESTADO")
        .case("CRITICO")
        .case("OTRO")
        .case("REPOTENCIADO")
        .create()

    return try await database.schema("hallazgo")
      .id()
      .field("fecha", .date)
      .field("nomenclatura", .string)
      .field("margen", enumMargen)
      .field("hallazgo1", .string)
      .field("hallazgo2", .string)
      .field("hallazgo3", .string)
      .field("observacion", .string)
      .field("estadoanterior", .int16)
      .field("afectacion", .string)
      .field("nivelriesgo", .string)
      .field("coordenadas", .string)
      .field("position", .string)
      .field("referencia", .string)
      .field("zona", enumZona)
      .field("tramo1", .string)
      .field("abscisakm", .float)
      .field("shapeleng", .float)
      .field("diagnostico", .string)
      .field("criticidad", .string)
      .field("tipodiseno", .string)
      .field("propuesta", .string)
      .field("costo", .float)
      .field("cota", .string)
      .field("linkdiseno", .string)
      .field("componente", enumComponente)
      .field("estado", enumEstado)
      .field("corrienteID", .uuid, .required, .references("corriente", "id"))
      .create()
  }

  func revert(on database: Database) async throws {
    try await database.schema("hallazgo").delete()
    try await database.enum("enumMargen").delete()
    try await database.enum("enumZona").delete()
    try await database.enum("enumComponente").delete()
    try await database.enum("enumEstado").delete()
  }
}
