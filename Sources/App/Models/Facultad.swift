//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 26/05/22.
//

import Vapor
import Fluent

final class Facultad: Model {
    static let schema = "facultades"
    
    @ID
    var id: UUID?
    
    @Field(key: "nombre")
    var nombre: String
    
    @Field(key: "decana")
    var decana: String
    
    @Field(key: "abreviatura")
    var abreviatura: String
    
    @Children(for: \Programa.$facultad)
    var programas: [Programa]
    
    @Siblings(through: FacultadDocentePivot.self, from: \.$facultad, to: \.$docente)
    var docentes: [Docente]
    
    init() {}
    
    init(id: UUID? = nil, nombre: String, decana: String, abreviatura: String) {
        self.id = id
        self.nombre = nombre
        self.decana = decana
        self.abreviatura = abreviatura
    }
}

extension Facultad: Content { }


