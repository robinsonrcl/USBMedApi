//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 26/05/22.
//

import Vapor
import Fluent
import Foundation

struct ProgramaController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        
        let programaRoute = routes.grouped("api", "programa")
        
        let authHostname: String
        if let host = Environment.get("AUTH_HOSTNAME") {
          authHostname = host
        } else {
          authHostname = "localhost"
        }
          
        let authGroup = routes.grouped(UserAuthMiddleware(authHostname: authHostname))
        let authGroupPrograma = authGroup.grouped("api", "programas")
        
        authGroupPrograma.delete(":programaID", "delete", use: deleteProgramaHandler)
        
    }
    
    func deleteProgramaHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        
       Programa.find(req.parameters.get("programaID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { programa in
                programa.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
}

