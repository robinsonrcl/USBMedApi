//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 26/05/22.
//

import Fluent

struct CreateDocente: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("docentes")
            .id()
            .field("nombres", .string, .required)
            .field("apellidos", .string)
            .field("nombrecompleto", .string)
            .field("cedulaid", .int32)
            .field("correousb", .string)
            .field("correotau", .string)
            .field("correopersonal", .string)
            .field("telefonofijo", .string)
            .field("telefonomovil", .string)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("docentes").delete()
    }
}
