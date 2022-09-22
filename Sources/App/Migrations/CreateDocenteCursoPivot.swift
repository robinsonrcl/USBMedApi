//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 26/05/22.
//

import Fluent

struct CreateDocenteCursoPivot: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("docentecursopivot")
            .id()
            .field("idcurso", .uuid, .required, .references("cursos", "id", onDelete: .cascade))
            .field("iddocente", .uuid, .required, .references("docentes", "id", onDelete: .cascade))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("docentecursopivot").delete()
    }
}
