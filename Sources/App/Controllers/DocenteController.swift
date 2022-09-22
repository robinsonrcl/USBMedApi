//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 26/05/22.
//

import Vapor
import Fluent
import Foundation

struct DocenteController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
    
        let docentesRoute = routes.grouped("api", "docente")
        
        docentesRoute.get(use: getAllHandler)
        docentesRoute.get(":docenteID", use: getHandler)
        docentesRoute.get(":docenteID", "facultades", use: getFacultadesHandler)
        
        let authHostname: String
        if let host = Environment.get("AUTH_HOSTNAME") {
          authHostname = host
        } else {
          authHostname = "localhost"
        }
          
        let authGroup = routes.grouped(UserAuthMiddleware(authHostname: authHostname))
        let authGroupDocente = authGroup.grouped("api", "docentes")

        authGroupDocente.post(use: createHandler)
        authGroupDocente.put(":docenteID", use: updateHandler)
        authGroupDocente.post(":docenteID",  "facultades", ":facultadID", use: addFacultadesHandler)
        authGroupDocente.delete(":docenteID", "facultades", ":facultadID", use: removeFacultadesHandler)
        
        authGroupDocente.delete(":docenteID","delete", use: deleteDocenteHandler)
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<Docente> {
        let data = try req.content.decode(CreateDocenteData.self)
    
        let nombrecompleto = data.nombres.uppercased() + " " + data.apellidos.uppercased()
        
        let docente = Docente(nombres: data.nombres.uppercased(), apellidos: data.apellidos.uppercased(),
                              nombrecompleto: nombrecompleto, cedulaid: data.cedulaid, correousb: data.correousb.uppercased(), correotau: data.correotau.uppercased(), correopersonal: data.correopersonal.uppercased(), telefonofijo: data.telefonofijo, telefonomovil: data.telefonomovil)
        
        return docente.save(on: req.db).map { docente  }
    }
    
    func getAllHandler(_ req: Request)  -> EventLoopFuture<[Docente]> {
      Docente.query(on: req.db).all()
    }

    func getHandler(_ req: Request) -> EventLoopFuture<Docente> {
      Docente.find(req.parameters.get("docenteID"), on: req.db)
          .unwrap(or: Abort(.notFound))
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Docente> {
        let updateData = try req.content.decode(CreateDocenteData.self)
        
        return Docente
            .find(req.parameters.get("docenteID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { docente in
                
                let nombrecompleto = updateData.nombres.uppercased() + " " + updateData.apellidos.uppercased()
                
                docente.nombres = updateData.nombres
                docente.apellidos = updateData.apellidos
                docente.nombrecompleto = nombrecompleto
                
                return docente.save(on: req.db).map {
                    docente
                }
            }
    }
    
    func addFacultadesHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        let docenteQuery = Docente.find(req.parameters.get("docenteID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        let facultadQuery  = Facultad.find(req.parameters.get("facultadID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        return docenteQuery.and(facultadQuery).flatMap { docente, facultad in
            docente
                .$facultades
                .attach(facultad, on: req.db)
                .transform(to: .created)
        }
    }
    
    func getFacultadesHandler(_ req: Request) -> EventLoopFuture<[Facultad]> {
        Docente.find(req.parameters.get("docenteID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { docente in
                docente.$facultades.query(on: req.db).all()
            }
    }
    
    func removeFacultadesHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        let docenteQuery = Docente.find(req.parameters.get("docenteID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        let facultadQuery = Facultad.find(req.parameters.get("facultadID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        return docenteQuery.and(facultadQuery).flatMap { docente, facultad in
            docente
                .$facultades
                .detach(facultad, on: req.db)
                .transform(to: .noContent)
        }
    }
    
    func deleteDocenteHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        Docente.find(req.parameters.get("docenteID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { docente in
                docente.delete(on: req.db).transform(to: HTTPStatus.ok)
            }
    }
    
}

struct CreateDocenteData: Content {
    let nombres: String
    let apellidos: String
    let cedulaid: Int32
    let correousb: String
    let correotau: String
    let correopersonal: String
    let telefonofijo: String
    let telefonomovil: String
}



