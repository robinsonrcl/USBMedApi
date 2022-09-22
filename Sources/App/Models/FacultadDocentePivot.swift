//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 26/05/22.
//

import Fluent
import Foundation

final class FacultadDocentePivot: Model {
    static let schema = "facultad-docente-pivot"
    
    @ID
    var id: UUID?
    
    @Parent(key: "docenteID")
    var docente: Docente
    
    @Parent(key: "facultadID")
    var facultad: Facultad
    
    init() {}
    
    init(id: UUID? = nil, facultad: Facultad, docente: Docente) throws {
        self.id = id
        self.$facultad.id = try facultad.requireID()
        self.$docente.id = try docente.requireID()
    }
}

