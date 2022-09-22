//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 26/05/22.
//

import Vapor
import Fluent
import wkhtmltopdf
import Foundation

struct InformesController: RouteCollection  {
    
    func boot(routes: RoutesBuilder) throws {
        
        let informesApiRoute =  routes.grouped("api","informes")
        
        informesApiRoute.get("listadogeneral", use: reportegeneral)
        
        let authHostname: String
        if let host = Environment.get("AUTH_HOSTNAME") {
          authHostname = host
        } else {
          authHostname = "localhost"
        }
          
//        let authGroupInformes = routes.grouped(UserAuthMiddleware(authHostname: authHostname))
    }
    
    func reportegeneral(_ req: Request) -> EventLoopFuture<[ListadoGeneral]> {
        var context = [ListadoGeneral]()
        
        return Curso.query(on: req.db)
            .with(\.$docentes)
            .with(\.$rubricas)
            .all()
            .flatMap { cursos in
                
                var rubricasResults: [EventLoopFuture<Void>] = []
                
                for curso in cursos {
                    rubricasResults.append(curso.$rubricas.get(on: req.db).and(curso.$docentes.get(on: req.db)).flatMapThrowing { result in
                        
                        let rubricas = result.0
                        let docentes = result.1
                        
                        var arrRubricas = [arrRubrica]()
                        
                        let sortRubricas = rubricas.sorted { rub1, rub2 in
                            rub1.numConcepto < rub2.numConcepto
                        }
                        
                        for rub in sortRubricas {
                            let arrRubrica = arrRubrica(conceptoRubrica: rub.conceptoRubrica, total: String(rub.total))
                            arrRubricas.append(arrRubrica)
                        }
                        
                        let docString = docentes.map { arrDocente(nombres: $0.nombres + " " + $0.apellidos) }
                        
                        let lista = ListadoGeneral(nombre: curso.nombre, codigo: curso.codigo, rubrica: String(curso.rubrica), avanceRubrica: String(curso.avanceRubrica), estadoCurso: curso.estadoCurso, inicio: curso.inicio, fin: curso.fin, docentes: docString, conceptoRubrica: arrRubricas)
                        
                        context.append(lista)
                    })
                }
                
                return rubricasResults.flatten(on: req.eventLoop).flatMapThrowing { dato in
                    
                    return context
                }
                
            }
    }
}

struct ListadoGeneral: Encodable, Decodable, Content {
    var nombre: String = ""
    var codigo: String = ""
    var rubrica: String = ""
    var avanceRubrica: String = ""
    var estadoCurso: EstadoCurso = .Activo
    var inicio: Date = Date()
    var fin: Date = Date()
    var docentes = [arrDocente]()
    var conceptoRubrica = [arrRubrica]()
    
    init() {}
    
    init(nombre: String, codigo: String, rubrica: String, avanceRubrica: String,
         estadoCurso: EstadoCurso, inicio: Date, fin: Date, docentes: [arrDocente],
         conceptoRubrica: [arrRubrica]) {
        self.nombre = nombre
        self.codigo = codigo
        self.rubrica = rubrica
        self.avanceRubrica = avanceRubrica
        self.estadoCurso = estadoCurso
        self.inicio = inicio
        self.fin = fin
        self.docentes = docentes
        self.conceptoRubrica = conceptoRubrica
    }
}

struct arrDocente: Encodable, Decodable {
    let nombres: String
}

struct arrRubrica: Encodable, Decodable {
    var conceptoRubrica: ConceptoRubrica
    var total: String
}

