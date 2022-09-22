//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 26/05/22.
//

import Fluent
import Vapor

final class Docente: Model, Content {
    static let schema = "docentes"
    
    @ID
    var id: UUID?
    
    @Field(key: "nombres")
    var nombres: String
    
    @Field(key: "apellidos")
    var apellidos: String
    
    @Field(key: "nombrecompleto")
    var nombrecompleto: String
    
    @Field(key: "cedulaid")
    var cedulaid: Int32
    
    @Field(key: "correousb")
    var correousb: String
    
    @Field(key: "correotau")
    var correotau: String
    
    @Field(key: "correopersonal")
    var correopersonal: String
    
    @Field(key: "telefonofijo")
    var telefonofijo: String
    
    @Field(key: "telefonomovil")
    var telefonomovil: String
    
    @Siblings(through: FacultadDocentePivot.self, from: \.$docente, to: \.$facultad)
    var facultades: [Facultad]
    
    @Siblings(through: DocenteCursoPivot.self, from: \.$docente, to: \.$curso)
    var cursos: [Curso]
    
    init() {}
    
    init(id: UUID?  = nil, nombres: String, apellidos: String, nombrecompleto: String,
         cedulaid: Int32 = 0, correousb: String = "", correotau: String,
         correopersonal: String,telefonofijo: String, telefonomovil: String) {
        self.nombres = nombres
        self.apellidos =  apellidos
        self.nombrecompleto = nombrecompleto
        self.cedulaid = cedulaid
        self.correousb = correousb
        self.correotau = correotau
        self.correopersonal = correopersonal
        self.telefonofijo = telefonofijo
        self.telefonomovil = telefonomovil
    }
}

