//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 26/05/22.
//

import Fluent

struct CreateRubrica: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        
        database.enum("conceptoRubrica")
            .case("TemaCero")
            .case("Calificacion")
            .case("Anuncio")
            .case("DisenoCurso")
            .case("CalificaActividad")
            .case("DisenoActividad")
            .case("Inquietud")
            .case("Recurso")
            .create()
            .flatMap { conceptoRubrica in
                database.schema("rubricas")
                    .id()
                    .field("conceptoRubrica", conceptoRubrica, .required)
                    .field("factor1", .int16)
                    .field("factor2", .int16)
                    .field("factor3", .int16)
                    .field("total", .int16)
                    .field("labConcepto", .string)
                    .field("labFactor1", .string)
                    .field("labFactor2", .string)
                    .field("labFactor3", .string)
                    .field("numConcepto", .int16)
                    .field("cursoid", .uuid, .required, .references("cursos","id") )
                    .field("listo", .bool)
                    .field("urlFile", .string)
                    .create()
            }
    }
                      
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("rubricas").delete().flatMap {
            database.enum("conceptoRubrica").delete()
        }
    }
}
