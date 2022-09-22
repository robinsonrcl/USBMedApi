//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 26/05/22.
//

import Fluent
import Foundation

final class DocenteCursoPivot: Model {
    static let schema = "docentecursopivot"
    
    @ID
    var id: UUID?
    
    @Parent(key: "idcurso")
    var curso: Curso
    
    @Parent(key: "iddocente")
    var docente: Docente
    
    init() {}
    
    init(id: UUID? = nil, curso: Curso, docente: Docente) throws {
        self.id = id
        self.$docente.id = try docente.requireID()
        self.$curso.id = try curso.requireID()
    }
}


