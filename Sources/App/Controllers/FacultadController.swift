//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 26/05/22.
//

import Vapor
import Fluent

struct FacultadController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        let facultadRoutes = routes.grouped("api", "facultades")
        
        facultadRoutes.get(use: getAllHandler)
        facultadRoutes.get(":facultadID", use: getHandler)
        facultadRoutes.get("search", use: searchHandler)
        facultadRoutes.get("first", use: getFirstHandler)
        facultadRoutes.get("sorted", use: sortedHandler)
        facultadRoutes.get("docentes", ":facultadID", use: getDocentesHandler)
        
        let authHostname: String
        if let host = Environment.get("AUTH_HOSTNAME") {
          authHostname = host
        } else {
          authHostname = "localhost"
        }
          
        let authGroup = routes.grouped(UserAuthMiddleware(authHostname: authHostname))
        let authGroupFacultad = authGroup.grouped("api", "facultades")
        
        authGroupFacultad.post(use: createHandler)
        authGroupFacultad.put("update", ":facultadID", use: updateHandler)
        authGroupFacultad.delete(":facultadID","delete", use: deleteHandler)
        
    }
    
    func getAllHandler(_  req: Request)  -> EventLoopFuture<[Facultad]> {
        Facultad.query(on: req.db)
            .sort(\.$nombre, .ascending)
            .all()
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<Facultad> {
      let facultad = try req.content.decode(Facultad.self)
      return facultad.save(on: req.db).map { facultad }
    }

    func getHandler(_ req: Request)  -> EventLoopFuture<Facultad> {
        Facultad.find(req.parameters.get("facultadID"), on: req.db)
        .unwrap(or: Abort(.notFound))
    }

    func updateHandler(_ req: Request) throws -> EventLoopFuture<Facultad> {
      let updatedFacultad = try req.content.decode(Facultad.self)
      return Facultad.find(
        req.parameters.get("facultadID"),
        on: req.db)
        .unwrap(or: Abort(.notFound)).flatMap { facultad in
            facultad.nombre = updatedFacultad.nombre
            facultad.decana = updatedFacultad.decana
            facultad.abreviatura = updatedFacultad.abreviatura
            
          return facultad.save(on: req.db).map {
              facultad
          }
        }
    }

    func deleteHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        Facultad.find(req.parameters.get("facultadID"), on: req.db)
        .unwrap(or: Abort(.notFound))
        .flatMap { facultad in
            facultad.delete(on: req.db)
            .transform(to: .noContent)
        }
    }
    
//headers: {
//    "Access-Control-Allow-Headers" : "Content-Type",
//    "Access-Control-Allow-Origin":"http://localhost:8083",
//    "Access-Control-Allow-Methods": "OPTIONS,POST,GET,DELETE"
//},

    func searchHandler(_ req: Request) throws -> EventLoopFuture<[Facultad]> {
      guard let searchTerm = req
        .query[String.self, at: "term"] else {
          throw Abort(.badRequest)
      }
        
      return Facultad.query(on: req.db).group(.or) { or in
        or.filter(\.$nombre == searchTerm)
        or.filter(\.$decana == searchTerm)
      }.all()
    }

    func getFirstHandler(_ req: Request) -> EventLoopFuture<Facultad> {
      return Facultad.query(on: req.db)
        .first()
        .unwrap(or: Abort(.notFound))
    }

    func sortedHandler(_ req: Request) -> EventLoopFuture<[Facultad]> {
      return Facultad.query(on: req.db)
        .sort(\.$nombre, .ascending).all()
    }
    
    func getDocentesHandler(_ req: Request)  -> EventLoopFuture<[Docente]> {
        Facultad.find(req.parameters.get("facultadID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { facultad in
                facultad.$docentes.get(on: req.db)
            }
    }

}

struct CreateFacultadData: Content {
    let nombre: String
    let decana: String
    let abreviatura: String
    let csrfToken: String?
}

