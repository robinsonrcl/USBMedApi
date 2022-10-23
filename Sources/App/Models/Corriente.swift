//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 6/10/22.
//

import Fluent
import Vapor

final class Corriente: Model, Content {
    static let schema = "corriente"
    
    @ID
    var id: UUID?
    
    @Field(key: "nombre")
    var nombre: String
    
    @Field(key: "puntomedio")
    var puntomedio: String
    
    @Field(key: "coordenadas")
    var coordenadas: String
    
    @Field(key: "etiquetas")
    var etiquetas: String
    
    @Field(key: "descripcion")
    var descripcion: String
    
    @Field(key: "fecha")
    var fecha: Date

    @Children(for: \.$corriente)
    var hallazgo: [Hallazgo]

    @Parent(key: "contratoID")
    var contrato: Contrato
    
    init() {}
    
    init(id: UUID? = nil, 
        nombre: String, 
        puntomedio: String = "",
        coordenadas: String = "", 
        etiquetas: String = "",
        descripcion: String = "",
        fecha: Date = Date(),
        contratoID: Contrato.IDValue) {
        
        self.nombre = nombre
        self.puntomedio = puntomedio
        self.coordenadas = coordenadas
        self.etiquetas = etiquetas
        self.descripcion = descripcion
        self.$contrato.id = contratoID
        self.fecha = fecha
    }
    
}
