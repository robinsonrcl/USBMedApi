//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 5/10/22.
//

import Fluent
import Vapor

final class Hallazgo: Model, Content {
    static let schema = "hallazgo"
    
    @ID
    var id: UUID?
    
    @Field(key: "fecha")
    var fecha: Date
    
    @Field(key: "nomenclatura")
    var nomenclatura: String
    
    @Enum(key: "margen")
    var margen: EnumMargen
    
    @Field(key: "hallazgo1")
    var hallazgo1: String

    @Field(key: "hallazgo2")
    var hallazgo2: String

    @Field(key: "hallazgo3")
    var hallazgo3: String

    @Field(key: "observacion")
    var observacion: String
    
    @Field(key: "estadoanterior")
    var estadoanterior: Int16?

    @Field(key: "afectacion")
    var afectacion: String

    @Field(key: "nivelriesgo")
    var nivelriesgo: String

    @Field(key: "coordenadas")
    var coordenadas: String

    @Field(key: "position")
    var position: String

    @Field(key: "referencia")
    var referencia: String

    @Enum(key: "zona")
    var zona: EnumZona

    @Field(key: "tramo1")
    var tramo1: String

    @Field(key: "abscisakm")
    var abscisakm: Float

    @Field(key: "shapeleng")
    var shapeleng: Float

    @Field(key: "diagnostico")
    var diagnostico: String

    @Field(key: "criticidad")
    var criticidad: String

    @Field(key: "tipodiseno")
    var tipodiseno: String

    @Field(key: "propuesta")
    var propuesta: String

    @Field(key: "costo")
    var costo: Float

    @Field(key: "cota")
    var cota: String

    @Field(key: "linkdiseno")
    var linkdiseno: String

    @Enum(key: "componente")
    var componente: EnumComponente

    @Enum(key: "estado")
    var estado: EnumEstado

    @Children(for: \.$hallazgo)
    var foto: [Foto]

  @Siblings(through:  HallazgoRevisorPivot.self, from: \.$hallazgo, to: \.$revisor)
  var revirsors: [Revisor]

    @Parent(key: "corrienteID")
    var corriente: Corriente

    init() {}
    
    init(id: UUID? = nil, 
          fecha: Date = Date(),
          nomenclatura: String = "",
          margen: EnumMargen = .NA,
          hallazgo1: String = "",
          hallazgo2: String = "",
          hallazgo3: String = "",
          observacion: String = "",
          estadoanterior: Int16,
          afectacion: String = "",
          nivelriesgo: String = "",
          coordenadas: String = "",
          position: String = "",
          referencia: String = "",
          zona: EnumZona = .NA,
          tramo1: String = "",
          abscisakm: Float = 0.0,
          shapeleng: Float = 0.0,
          diagnostico: String = "",
          criticidad: String = "",
          tipodiseno: String = "",
          propuesta: String = "",
          costo: Float = 0.0,
          cota: String = "",
          linkdiseno: String = "",
         componente: EnumComponente,
         estado: EnumEstado,
          corrienteID: Corriente.IDValue
         ) {
        
        self.fecha = fecha
        self.nomenclatura = nomenclatura
        self.margen = margen
        self.hallazgo1 = hallazgo1
        self.hallazgo2 = hallazgo2
        self.hallazgo3 = hallazgo3
        self.observacion = observacion
        self.estadoanterior = estadoanterior
        self.afectacion = afectacion
        self.nivelriesgo = nivelriesgo
        self.coordenadas = coordenadas
        self.position = position
        self.referencia = referencia
        self.zona = zona
        self.tramo1 = tramo1
        self.abscisakm = abscisakm
        self.shapeleng = shapeleng
        self.diagnostico = diagnostico
        self.criticidad = criticidad
        self.tipodiseno = tipodiseno
        self.propuesta = propuesta
        self.costo = costo
        self.cota = cota
        self.linkdiseno = linkdiseno
      self.componente = componente
      self.estado = estado
        self.$corriente.id = corrienteID
    }
    
}

enum EnumMargen: String, Codable, CaseIterable {
    case M_DERECHA
    case M_IZQUIERDA
    case NA
    case CENTRO
}

enum EnumZona: String, Codable, CaseIterable {
    case SUR_CANALIZADA
    case SUR_SIN_CANALIZAR
    case NORTE_CANALIZADA
    case NORTE_SIN_CANALIZAR
    case CENTRO_CANALIZADA
    case NA
}

enum EnumComponente: String, Codable, CaseIterable {
    case BARRA
    case ESTRUCTURA_DE_CAIDA
    case MURO
    case OBSTRUCCION
    case PLACA
    case AZUD
    case BANCA
    case BOCATOMA
    case BOLSA_DE_GRAVILLA
    case CONTRADIQUE
    case CONTROL_DE_GRADIENTE
    case DIQUE
    case DIRECCIONADOR
    case GAVION
    case LLAVE
    case TABIQUE
    case TRAVIEZA
}

enum EnumEstado: String, Codable, CaseIterable {
    case BUENO
    case MALO
    case REGULAR
    case NA
    case SIN_ESTADO
    case CRITICO
    case OTRO
    case REPOTENCIADO
}

