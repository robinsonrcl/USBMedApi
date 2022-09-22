//
//  File.swift
//
//
//  Created by Robinson Cartagena on 6/04/22.
//

import Vapor
import Fluent
import Foundation
import FluentPostgresDriver
import SQLKit

struct CursoController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
    
        let cursosRoute = routes.grouped("api", "cursos")
        
        // CRUD -> CREATE, READ, UPDATE, DELETE
        
        cursosRoute.get(use: getAllHandler)
        cursosRoute.get(":cursoID", use: getHandler)
        cursosRoute.get("search", use: searchHandler)
        cursosRoute.get("first", use: getFirstHandler)
        cursosRoute.get("sorted", use: sortedHandler)
        cursosRoute.get("dashboard", use: dashboard)
        cursosRoute.get("dashboard", ":numConcepto", use: dashConceptos)
        cursosRoute.get("dashboard","programas", ":numConcepto", use: dashConceptosPRO)
        cursosRoute.get("dashboard","docentes", ":numConcepto", use: dashConceptosDOC)
        
        let authHostname: String
        if let host = Environment.get("AUTH_HOSTNAME") {
          authHostname = host
        } else {
          authHostname = "localhost"
        }
          
        let authGroup = routes.grouped(UserAuthMiddleware(authHostname: authHostname))
        let authGroupCurso = authGroup.grouped("api", "cursos")
        
        authGroupCurso.post(use: createHandler)
        authGroupCurso.put(":cursoID", use: updateHandler)
        authGroupCurso.delete(":cursoID","delete", use: deleteHandler)
        authGroupCurso.post("rubrica", "edit", use: updateRubricaHandler)
        authGroupCurso.post("rubrica","upload", use: loadFileRubrica)
        authGroupCurso.delete("deletefilerubrica", ":rubricaID", use: deleteFileRubricaHandler)
        authGroupCurso.get("rubrica", ":cursoID", use: rubricaHandler)
    }
    
    struct ResultSQL: Content {
        let header: String
        let average: Double
        let count: Int
    }
    
    struct RowFAC:Content {
        let facultad: String
        let count: Int
        let avg: Double
    }
    
    struct RowPRO:Content {
        let programa: String
        let count: Int
        let avg: Double
    }
    
    struct RowDOC:Content {
        let docente: String
        let count: Int
        let avg: Double
    }
    
    struct DataGRA: Content {
        let facultades: [ResultSQL]
        let programas: [ResultSQL]
        let docentes: [ResultSQL]
    }
    
    func dashConceptos(_ req: Request) async throws -> [ResultSQL] {
        guard let sql = req.db as? SQLDatabase else {
            throw Abort(.internalServerError)
        }

        var arrResultFAC = [ResultSQL]()
        
        let query = SQLQueryString(stringLiteral: req.parameters.get("numConcepto")!)
        
        _ = try await sql.raw("select c.facultad, count(*), avg(r.total)::numeric(10,2) from rubricas r join cursos c on r.cursoid = c.id " +
                              "where r.\"numConcepto\" = " + query + " group by c.facultad order by c.facultad").all(decoding: RowFAC.self).compactMap { resultado in
            let newRecFAC = ResultSQL(header: resultado.facultad,
                                      average: resultado.avg,
                                      count: resultado.count)
            arrResultFAC.append(newRecFAC)
        }
        
        return arrResultFAC
    }
    
    func dashConceptosPRO(_ req: Request) async throws -> [ResultSQL] {
        guard let sql = req.db as? SQLDatabase else {
            throw Abort(.internalServerError)
        }

        var arrResultPRO = [ResultSQL]()
        
        let query = SQLQueryString(stringLiteral: req.parameters.get("numConcepto")!)
        
        _ = try await sql.raw("select c.programa, count(*), avg(r.total)::numeric(10,2) from rubricas r join cursos c on r.cursoid = c.id " +
                              "where r.\"numConcepto\" = " + query + " group by c.programa order by c.programa").all(decoding: RowPRO.self).compactMap { resultado in
            let newRecPRO = ResultSQL(header: resultado.programa,
                                      average: resultado.avg,
                                      count: resultado.count)
            arrResultPRO.append(newRecPRO)
        }
        
        return arrResultPRO
    }
    
    func dashConceptosDOC(_ req: Request) async throws -> [ResultSQL] {
        guard let sql = req.db as? SQLDatabase else {
            throw Abort(.internalServerError)
        }

        var arrResultDOC = [ResultSQL]()
        
        let query = SQLQueryString(stringLiteral: req.parameters.get("numConcepto")!)
        
        _ = try await sql.raw("select d.nombrecompleto docente, count(*), avg(r.total)::numeric(10,2)  from rubricas r join cursos c on r.cursoid = c.id join docentecursopivot dc on dc.idcurso = c.id join docentes d on d.id = dc.iddocente " +
                              "where r.\"numConcepto\" = " + query + " group by d.nombrecompleto order by d.nombrecompleto").all(decoding: RowDOC.self).compactMap { resultado in
            let newRecDOC = ResultSQL(header: resultado.docente,
                                      average: resultado.avg,
                                      count: resultado.count)
            arrResultDOC.append(newRecDOC)
        }
        
        return arrResultDOC
    }
    
    func dashboard(_ req: Request) async throws -> DataGRA {
        
        guard let sql = req.db as? SQLDatabase else {
            throw Abort(.internalServerError)
        }
        
        var arrResultFAC = [ResultSQL]()
        var arrResultPRO = [ResultSQL]()
        var arrResultDOC = [ResultSQL]()
        
        _ = try await sql.raw("select facultad,count(*),avg(rubrica)::numeric(10,2) from cursos group by facultad").all(decoding: RowFAC.self).compactMap { resultado in
            let newRecFAC = ResultSQL(header: resultado.facultad,
                                      average: resultado.avg,
                                      count: resultado.count)
            arrResultFAC.append(newRecFAC)
        }
        
        _ = try await sql.raw("select programa,count(*),avg(rubrica)::numeric(10,2) from cursos group by programa").all(decoding: RowPRO.self).compactMap { resultado in
            let newRecFAC = ResultSQL(header: resultado.programa,
                                      average: resultado.avg,
                                      count: resultado.count)
            arrResultPRO.append(newRecFAC)
        }
        
        _ = try await sql.raw("""
                    select d.id, d.nombrecompleto as docente, avg(c.rubrica)::numeric(10,2),count(*)
                    from cursos as c
                    inner join docentecursopivot as dc on c.id = dc.idcurso
                    join docentes as d on d.id = dc.iddocente
                    group by d.id, d.nombrecompleto
                    order by d.nombrecompleto
                    """).all(decoding: RowDOC.self).compactMap { resultado in
            let newRecFAC = ResultSQL(header: resultado.docente ,
                                      average: resultado.avg,
                                      count: resultado.count)
            arrResultDOC.append(newRecFAC)
        }
        
        let newDataGRA = DataGRA(facultades: arrResultFAC, programas: arrResultPRO, docentes: arrResultDOC)
            
        return newDataGRA
//                return newContext
            
         // all(decoding: Row.self).compactMap { resultados in
    }
    
    struct baseRubrica: Content {
        var rubricas: [Rubrica]
        var docentes: [Docente]
    }
    
    func rubricaHandler(_ req: Request) -> EventLoopFuture<baseRubrica> {
        Curso.find(req.parameters.get("cursoID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { curso in
                
                curso.$docentes.get(on: req.db).flatMap { docentes in
                    
                    curso.$rubricas.get(on: req.db)
                        .flatMap { rubricas in
                        
                            let sortedRubricas = rubricas.sorted { rub1, rub2 in
                                rub1.numConcepto < rub2.numConcepto
                            }
                            
                            let rubrica = baseRubrica(rubricas: sortedRubricas, docentes: docentes)
                        
                            return req.eventLoop.future(rubrica)
                        }
                }
            }
    }
    
    func deleteFileRubricaHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
    
        Rubrica.find(req.parameters.get("rubricaID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { rubrica in
                rubrica.urlFile = ""
                
                return rubrica.save(on: req.db).transform(to: HTTPStatus.ok)
            }
    }
    
    func loadFileRubrica(_ req: Request) throws -> EventLoopFuture<String> {
        struct Input: Content {
            var file: File
            var idRubrica: UUID
            var idCurso: UUID
            var numConcepto: Int16
            var codCurso: String
        }
        
        var urlAnexo: String = ""
        let input = try req.content.decode(Input.self)
        
        
        let arregloCodigo = input.codCurso.split(separator: "-")
        
        let labelYear = String(arregloCodigo[2])
        let labelSemester = String(arregloCodigo[3])
        
        guard input.file.data.readableBytes > 0 else {
            throw Abort(.badRequest)
        }
        
        let fileName = input.codCurso +
                                "-EvidConc-" +
                                String(input.numConcepto) +
                                "." + input.file.extension!
        
        let docURL = URL(string: DirectoryConfiguration.detect().publicDirectory)!
        let dataPath = docURL.appendingPathComponent(labelYear)
        if !FileManager.default.fileExists(atPath: dataPath.path) {
            do {
                try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
                try FileManager.default.createDirectory(atPath: dataPath.path + "/1", withIntermediateDirectories: true, attributes: nil)
                try FileManager.default.createDirectory(atPath: dataPath.path + "/2", withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        let path = DirectoryConfiguration.detect().publicDirectory + labelYear + "/" + labelSemester + "/" + fileName
        
        if FileManager.default.fileExists(atPath: path) {
            try FileManager.default.removeItem(atPath: path)
        }
        
        return req.application.fileio.openFile(path: path,
                                               mode: .write,
                                        flags: .allowFileCreation(posixMode: 0x744),
                                        eventLoop: req.eventLoop)
        .flatMap { handle in
            return req.application.fileio.write(fileHandle: handle,
                                         buffer: input.file.data,
                                         eventLoop: req.eventLoop)
            .flatMap { _ in
                
                return Rubrica.find(input.idRubrica, on: req.db)
                    .unwrap(or: Abort(.notFound))
                    .flatMapThrowing { rubrica in
                        
                        try handle.close()
                        
                        urlAnexo = "/" + labelYear + "/" + labelSemester + "/" + fileName
                        rubrica.urlFile = urlAnexo
                        
                        _ = rubrica.save(on: req.db)
                            
                    }.transform(to: urlAnexo)
            }
        }
    }
    
    func updateRubricaHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let data = try req.content.decode([UpdateRubricaWeb].self)
        
        var id: UUID = UUID.init()
        
        if data.count >  0 {
            id = data[0].cursoid
        }
        
        return Curso.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { curso in
                
                return curso.$rubricas.get(on: req.db)
                    .flatMap { rubricas in
                        
                    var rubricaR:  [EventLoopFuture<Void>] = []

                    var index: Int16
                    var totalRubrica: Int16 = 0
                    var conceptosListos = 0
                        
                    for rubrica in rubricas {
                        index =  rubrica.numConcepto
                        let rubIndex = data.first { $0.numConcepto == index }
                        
                        rubrica.factor1 = rubIndex!.factor1
                        rubrica.factor2 = rubIndex!.factor2
                        rubrica.factor3 = rubIndex!.factor3
                        rubrica.total = rubIndex!.total
                        rubrica.listo = rubIndex!.listo
                        
                        if(rubrica.listo) {
                            conceptosListos += 1
                        }
                        
                        totalRubrica += rubIndex!.total

                        rubricaR.append(rubrica.save(on: req.db))
                    }
                        
                        curso.rubrica = totalRubrica
                        
//                        let sub2 = data.count
//                        let sub1 = conceptosListos / sub2
                        
                        curso.avanceRubrica = data[0].avanceRubrica
                        
//                        let formatter = NumberFormatter()
//                        formatter.numberStyle = .percent
//                        let res = formatter.string(from: totalRubrica as NSNumber)
                        
                        return curso.save(on: req.db).flatMap {
                            return rubricaR.flatten(on: req.eventLoop).transform(to: HTTPStatus.created)
                        }
                }
            }
    }
    
    // CREATE
    func createHandler(_ req: Request) throws -> EventLoopFuture<Curso> {
        let data = try req.content.decode(CreateCursoData.self)
        
        let arregloUUIDDocentes = data.docenteID.map { UUID($0) }
        
        return try Docente.query(on: req.db).group(.or) { or in
            for filtro in arregloUUIDDocentes {
                guard let filtro = filtro else {
                    throw Abort(.internalServerError)
                }
                or.filter(\.$id == filtro)
            }
        }
        .all()
        .flatMap { docentes in
            
            var fecha = Date()
            var fechaFin = Date()
            
            let isoDateFechaFin = data.fin
            
            let isoDate = data.inicio
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            if let date = dateFormatter.date(from: isoDate) {
              fecha = date
            }
            
            if let date = dateFormatter.date(from: isoDateFechaFin) {
              fechaFin = date
            }
            
            let curso = Curso(
                nombre: data.nombre,
                rubrica: data.rubrica,
                codigo: data.codigo,
                estadoCurso: data.estadoCurso,
                inicio: fecha,
                fin: fechaFin,
                facultad: data.facultad,
                programa: data.programa
            )
            
            return curso.save(on: req.db).flatMap {
                
                return curso.$docentes.attach(docentes, on: req.db).flatMapThrowing {
                    return curso
                }
            }
        }
    }
    
    // GET ALL
    func getAllHandler(_ req: Request)  -> EventLoopFuture<[Curso]> {
      Curso.query(on: req.db).all()
    }

    func getHandler(_ req: Request) -> EventLoopFuture<Curso> {
        Curso.find(req.parameters.get("cursoID"), on: req.db)
          .unwrap(or: Abort(.notFound))
    }
    
    // UPDATE
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Curso> {
        let updateData = try req.content.decode(CreateCursoData.self)
        
        return Curso
            .find(req.parameters.get("cursoID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { curso in
                curso.nombre = updateData.nombre
                
                return curso.save(on: req.db).map {
                    curso
                }
            }
    }
    // DELETE
    func deleteHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        return Curso.find(req.parameters.get("cursoID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { curso in
                
                return curso.$rubricas.get(on: req.db).flatMap { cursoRubricas in
                    cursoRubricas.delete(on: req.db).flatMap {
                        return curso.delete(on: req.db).transform(to: HTTPStatus.ok)
                    }
                }
            }
    }


    // SEARCH
    func searchHandler(_ req: Request) throws -> EventLoopFuture<[Curso]> {
      guard let searchTerm = req
        .query[String.self, at: "term"] else {
          throw Abort(.badRequest)
      }
        
      return Curso.query(on: req.db).group(.or) { or in
        or.filter(\.$nombre == searchTerm)
      }.all()
    }

    // GET FIRST
    func getFirstHandler(_ req: Request) -> EventLoopFuture<Curso> {
      return Curso.query(on: req.db)
        .first()
        .unwrap(or: Abort(.notFound))
    }

    //GET ALL SORTED
    func sortedHandler(_ req: Request) -> EventLoopFuture<[Curso]> {
      return Curso.query(on: req.db)
        .sort(\.$nombre, .ascending).all()
    }
    
}

struct UpdateCursoDataAPI: Content {
    let nombre: String
//    let codigo: String
//    let estado: Int16
//    let rubrica: Double
//    let inicio: Date
//    let fin: Date
    
    let docenteID: [String]
    let currentlyDocentes: [String]
}

struct CreateCursoData: Content {
    let nombre: String
    let codigo: String
    let estadoCurso: EstadoCurso
    let rubrica: Int16
    let inicio: String
    let fin: String
    let facultad: String
    let programa: String
    
    let docenteID: [String]
}

struct UpdateRubricaWeb: Content {
    let id: UUID
    let total: Int16
    let factor1: Int16
    let factor2: Int16
    let factor3: Int16
    let cursoid: UUID
    let numConcepto: Int16
    let listo: Bool
    let avanceRubrica: Double
}

