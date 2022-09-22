//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 26/05/22.
//

import Fluent
import Vapor

final class Curso: Model, Content {
    static let schema = "cursos"
    
    @ID
    var id: UUID?
    
    @Field(key: "nombre")
    var nombre: String
    
    @Field(key: "rubrica")
    var rubrica: Int16
    
    @Field(key: "codigo")
    var codigo: String
    
    @Enum(key: "estadoCurso")
    var estadoCurso: EstadoCurso
    
    @Field(key: "inicio")
    var inicio: Date
    
    @Field(key: "fin")
    var fin: Date
    
    @Field(key: "avanceRubrica")
    var avanceRubrica: Double
    
    @Field(key: "facultad")
    var facultad: String
    
    @Field(key: "programa")
    var programa: String
    
    @Field(key: "year")
    var year: Int16
    
    @Field(key: "semestre")
    var semestre: Int16
    
    @Children(for: \Rubrica.$curso)
    var rubricas: [Rubrica]
    
    @Siblings(through: DocenteCursoPivot.self, from: \.$curso, to: \.$docente)
    var docentes: [Docente]
    
    init() {}
    
    init(id: UUID?  = nil,
         nombre: String,
         rubrica: Int16 = 0,
         codigo: String = "",
         estadoCurso: EstadoCurso = .Activo,
         inicio: Date = Date(),
         fin: Date = Date(),
         avanceRubrica: Double = 0.0,
         facultad: String,
         programa: String,
         year: Int16 = 2022,
         semestre: Int16 = 2) {
        
        self.nombre = nombre
        self.rubrica = rubrica
        self.codigo = codigo
        self.estadoCurso = estadoCurso
        self.inicio = inicio
        self.fin = fin
        self.avanceRubrica = avanceRubrica
        self.facultad = facultad
        self.programa = programa
        self.year = year
        self.semestre = semestre
    }
}

enum EstadoCurso: String, Codable {
    
    case Activo
    case Inactivo
    case Cancelado

}

enum EnumFacultad: String, Codable, CaseIterable {
    case ING = "Facultad de Ingeniería"
    case PSI = "Facultad de Psicología"
    case CIE = "Faculta de Ciencias Empresariales"
    case EDU = "Facultad de Educación"
    case ART = "Faculta de Artes Integradas"
    case DER = "Facultad de Derecho"
    case VAR = "Varias facultades"
}

enum EnumPrograma: String, Codable, CaseIterable {
    case PRPSICM = "Psicología"
    case PRLEINM = "Licenciatura en educación infantil - Medellín"
    case PRLEINA = "Licenciatura en educación infantil - Armenia"
    case PRLEARM = "Licenciatura en educación artistica"
    case PRLEFDM = "Licenciatura en educación fisica y deporte"
    case PRLHLCM = "Licenciatura en humanidades y lengua castellana"
    case TEEDEPM = "Tecnología en entrenamiento deportivo"
    case PRISONM = "Ingeniería de sonido"
    case PRIAMBM = "Ingeniería ambiental"
    case PRIINDM = "Ingeniería industrial"
    case PRIMULM = "Ingeniería multimedia"
    case PRIDYSM = "Ingeniería de datos y software"
    case PRISCIM = "Ingeniería de sistemas ciberneticos"
    case PRANEGM = "Administración de negocios"
    case PRNINTM = "Negocios internacionales"
    case PRCPUBM = "Contaduria publica"
    case PRARQUA = "Arquitectura - Armenia"
    case PRARQUM = "Arquitectura - Medellín"
    case PRDINDM = "Diseño industrial"
    case PRDEREM = "Derecho"
    case PRVARIO = "Varios programas (preg y tecn)"
}

