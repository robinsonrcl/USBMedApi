//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 26/05/22.
//

import Vapor
import Fluent

final class Programa: Model {
    static let schema = "programas"
    
    @ID
    var id: UUID?
    
    @Field(key: "nombre")
    var nombre: String
    
    @Field(key: "director")
    var director: String
    
    @Field(key: "abreviatura")
    var abreviatura: String
    
    @Parent(key: "facultadID")
    var facultad: Facultad
    
    init() {}
    
    init(id: UUID? = nil, nombre: String, director: String, abreviatura: String,
         facultadID: Facultad.IDValue) {
        self.id = id
        self.nombre = nombre
        self.director = director
        self.abreviatura = abreviatura
        self.$facultad.id = facultadID
    }
}

extension Programa: Content { }

