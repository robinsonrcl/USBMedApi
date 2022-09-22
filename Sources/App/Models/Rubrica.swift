//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 26/05/22.
//

import Fluent
import Vapor

final class Rubrica: Model, Content {
    
    static let schema = "rubricas"
    
    @ID
    var id: UUID?
    
    @Enum(key: "conceptoRubrica")
    var conceptoRubrica: ConceptoRubrica
    
    @Field(key: "factor1")
    var factor1: Int16
    
    @Field(key: "factor2")
    var factor2: Int16
    
    @Field(key: "factor3")
    var factor3: Int16
    
    @Field(key: "total")
    var total: Int16
    
    @Field(key: "labConcepto")
    var labConcepto: String
    
    @Field(key: "labFactor1")
    var labFactor1: String
    
    @Field(key: "labFactor2")
    var labFactor2: String
    
    @Field(key: "labFactor3")
    var labFactor3: String
    
    @Field(key: "numConcepto")
    var numConcepto: Int16
    
    @Field(key: "listo")
    var listo: Bool
    
    @Field(key: "urlFile")
    var urlFile: String
    
    @Parent(key: "cursoid")
    var curso: Curso
    
    init() {}
    
    init(conceptoRubrica: ConceptoRubrica,
         cursoID: Curso.IDValue,
         labConcepto: String,
         labFactor1: String,
         labFactor2: String,
         labFactor3: String,
         numConcepto: Int16,
         factor1: Int16,
         factor2: Int16,
         factor3: Int16,
         urlFile: String = "") {
        
        self.conceptoRubrica = conceptoRubrica
        self.$curso.id = cursoID
        self.factor1 = 0
        self.factor2 = 0
        self.factor3 = 0
        self.labConcepto = labConcepto
        self.labFactor1 = labFactor1
        self.labFactor2 = labFactor2
        self.labFactor3 = labFactor3
        self.numConcepto = numConcepto
        self.total = 0
        self.listo = false
        self.factor1 = factor1
        self.factor2 = factor2
        self.factor3 = factor3
        self.urlFile = urlFile
    }
    
    init(id: UUID? = nil,
         conceptoRubrica: ConceptoRubrica =  .CORG_Inducciones,
         factor1: Int16 = 0,
         factor2: Int16 = 0,
         factor3: Int16 = 0,
         labConcepto: String,
         labFactor1: String,
         labFactor2:  String,
         labFactor3:  String,
         numConcepto: Int16 = 0,
         cursoid: Curso.IDValue,
         listo: Bool = false,
         urlFile: String = "") {
        
        self.conceptoRubrica = conceptoRubrica
        self.factor1 = factor1
        self.factor2 = factor2
        self.factor3 = factor3
        self.labConcepto = labConcepto
        self.labFactor1 = labFactor1
        self.labFactor2 =  labFactor2
        self.labFactor3 = labFactor3
        self.numConcepto = numConcepto
        self.total = 0
        self.$curso.id = cursoid
        self.listo = listo
        self.urlFile = urlFile
    }
}

enum ConceptoRubrica: String, Codable, CaseIterable {
    
    case CORG_Inducciones
    case CORG_UtilizaTic
    case CORG_TemaCero
    case CORG_ActualizaPerfil
    case CORG_ConfiguraUnidades
    case CORG_EnlazaMicrocurriculo
    case CORG_ManejoDomus
    case CCOM_AnuncioBienvenida
    case CCOM_AnuncioInformativo
    case CCOM_RespondeForos
    case CCOM_IncentivaAlumnos
    case CCOM_FomentaActividades
    case CCOM_MotivaEvaluacion
    case CPED_DisenaActividades
    case CPED_ActividadRubrica
    case CPED_CalificaActividades
    case CPED_Retroalimenta
}

//extensiosn Rubrica {
//    static func addRubrica(_ concepto: ConceptoRubrica, to  curso: Curso, on req: Request) throws -> Future<Void> {
//        let rubrica = Rubrica(conceptoRubrica: concepto)
//
//        return  rubrica.save(on: req)
//
//    }
//}

