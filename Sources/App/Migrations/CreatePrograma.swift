//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 26/05/22.
//

import Fluent

struct CreatePrograma: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("programas")
            .id()
            .field("nombre", .string, .required)
            .field("director", .string, .required)
            .field("abreviatura", .string, .required)
            .field("facultadID", .uuid, .required, .references("facultades","id") )
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("programas").delete()
    }
}
