//
//  File.swift
//
//
//  Created by Robinson Cartagena on 6/04/22.
//

import Fluent

struct CreateCurso: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        
        database.enum("estadoCurso")
            .case("Activo")
            .case("Inactivo")
            .case("Cancelado")
            .create()
            .flatMap { estadoCurso in
                database.schema("cursos")
                    .id()
                    .field("nombre", .string, .required)
                    .field("rubrica", .int16)
                    .field("codigo", .string)
                    .field("estadoCurso", estadoCurso, .required)
                    .field("inicio", .date)
                    .field("fin", .date)
                    .field("avanceRubrica", .double)
                    .field("facultad", .string)
                    .field("programa", .string)
                    .field("year", .int16)
                    .field("semestre", .int16)
                    .create()
            }
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("cursos").delete().flatMap {
            database.enum("estadoCurso").delete()
        }
    }
}
