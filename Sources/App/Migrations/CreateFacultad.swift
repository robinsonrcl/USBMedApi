//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 26/05/22.
//

import Fluent

struct CreateFacultad: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("facultades")
            .id()
            .field("nombre", .string, .required)
            .field("decana", .string, .required)
            .field("abreviatura", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("facultades").delete()
    }
}
