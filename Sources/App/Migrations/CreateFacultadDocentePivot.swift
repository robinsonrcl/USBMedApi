//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 26/05/22.
//

import Fluent

struct CreateFacultadDocentePivot: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("facultad-docente-pivot")
            .id()
            .field("docenteID", .uuid, .required, .references("docentes", "id", onDelete: .cascade))
            .field("facultadID", .uuid, .required, .references("facultades", "id", onDelete: .cascade))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("facultad-docente-pivot").delete()
    }
}
