//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 5/10/22.
//

import Fluent
import Vapor

final class Contrato: Model, Content {
    static let schema = "contrato"
    
    @ID
    var id: UUID?
    
    @Field(key: "nombre")
    var nombre: String
    
    @Field(key: "fecha")
    var fecha: Date
    
    @Field(key: "year")
    var year: Int16
    
    @Field(key: "mes")
    var mes: Int16
    
    @Field(key: "descripcion")
    var descripcion: String

    @Children(for: \.$contrato)
    var corriente: [Corriente]
    
    init() {}
    
    init(id: UUID? = nil, nombre: String, fecha: Date = Date(),
         year: Int16 = 2022, mes: Int16 = 1, descripcion: String = "") {
        
        self.nombre = nombre
        self.fecha = fecha
        self.year = year
        self.mes = mes
        self.descripcion = descripcion
    }
    
}
