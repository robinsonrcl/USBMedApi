import Vapor
import Fluent
import FluentPostgresDriver

struct ContratoController: RouteCollection {
  
    func boot(routes: RoutesBuilder) throws {
      let contratoRoute = routes.grouped("api")

      contratoRoute.get("contratos", use: getAllContrato)
      contratoRoute.get("corrientes", use: getAllCorrientes)
      contratoRoute.get("hallazgos", use: getAllHallazgos)
      contratoRoute.get("hallazgo",":hallazgoID", use: getHallazgo)
      contratoRoute.get("loadcsvunal", use: getCSVData)
    }

  func getHallazgo(_ req: Request) async throws -> Hallazgo {
    return try await Hallazgo.find(req.parameters.get("hallazgoID"), on: req.db)!
  }
  
  func getAllContrato(_ req: Request) async throws -> [Contrato] {
    return try await Contrato.query(on: req.db).all()
  }
  
    func getAllCorrientes(_ req: Request) async throws -> [Corriente] {
//        let contrato = try await Contrato.query(on: req.db).first()
//
//        let corrientes = (try await contrato?.$corriente.get(on: req.db))!
        
      return try await Corriente.query(on: req.db).all()
      
    }
  
  func getAllHallazgos(_ req: Request) async throws -> [Hallazgo] {
    return try await Hallazgo.query(on: req.db).all()
  }
    
    func getCSVData(_ req: Request) async throws -> [Array<String>] {
        do {
            let content = try String(contentsOfFile: "./dataFluvial01.csv")
            
            let parsedCSV: [[String]] = content.components(separatedBy: "\n").map {
                var arreglo = [String]()
                
                for item in $0.components(separatedBy: ";") {
                    arreglo.append(item)
                }
                return arreglo
            }
            
            try await saveJson(archivo: parsedCSV, req)
            
            return parsedCSV
        }
        catch let err {
            print("Error en carga de contratos: " + err.localizedDescription)
            return []
        }
    }
    
  class Agreement {
    var contrato = Contrato()
    var flow = [Flow]()
    
    init() {}
    
  }
  
  class Flow {
    var corriente = Corriente()
    var visitas = [HallazgoWide]()
    
    init() {}
    
  }
  
  class HallazgoWide {
    var hallazgo = Hallazgo()
    var revisors = [String]()
    var fotos = [ClaseFoto()]
  }
  
  class ClaseFoto {
    var src: String = ""
    var text: String = ""
  }
  
    func saveJson(archivo: [Array<String>], _ req: Request) async throws {
      let contrato = Contrato()
      let corriente = Corriente()
      var flow = Flow()
      var contratoAnterior = ""
      var corrienteAnterior = ""
      
      var agreements = [Agreement]()
      let agreement = Agreement()
      
        archivo.forEach {
            let row = $0
            let cont_nombre = row[0]
            
            if(cont_nombre != "NOMBRE") {
                
                if(contratoAnterior != cont_nombre)  {
                  contratoAnterior = cont_nombre

                  contrato.nombre = cont_nombre
                  contrato.year = Int16(row[1]) ?? 1972
                  contrato.mes =  Int16(row[2]) ?? 0
                  contrato.descripcion = row[3]
                  contrato.fecha = Date()
                  
                  agreement.contrato = contrato
                  agreements.append(agreement)

                }
                let corr_nombre = row[4]
                
                if(corrienteAnterior != corr_nombre)  {
                  corrienteAnterior = corr_nombre
                    
                  corriente.nombre = corr_nombre
                  corriente.coordenadas = row[5]
                  corriente.descripcion = row[6]
                  corriente.puntomedio = row[7]
                  corriente.etiquetas = ""
                  corriente.fecha = asignarFecha(fecha: row[8])
                  
                  flow = Flow()
                  flow.corriente = corriente
                  
                  agreement.flow.append(flow)
                }
                
              flow.visitas.append(loadRowHallazgo(row))
              //flow.visitas.revisors.append(contentsOf: readRevisors(row[35]))
            }
        }
        
        try await saveContratoToDB(req, agreements)
    }
  
  func loadRowHallazgo(_ row: [String]) -> HallazgoWide {
    let hallazgoWide = HallazgoWide()
    
    hallazgoWide.hallazgo.fecha = asignarFecha(fecha: row[8])
    hallazgoWide.hallazgo.componente = readComponente(row[10])
    
    hallazgoWide.hallazgo.nomenclatura = row[11]
    hallazgoWide.hallazgo.margen = readMargen(row[12])   // Margen
    hallazgoWide.hallazgo.hallazgo1 = row[13]
    hallazgoWide.hallazgo.hallazgo2 = row[14]
    hallazgoWide.hallazgo.hallazgo3 = row[15]
    hallazgoWide.hallazgo.estado = readEstado(row[16]) // Estado
    hallazgoWide.hallazgo.observacion = row[17]
    
    if(row[18] != "0" && row[18] != "1") {
      hallazgoWide.hallazgo.estadoanterior = 0
    } else {
      hallazgoWide.hallazgo.estadoanterior = Int16(row[18])
    }
    
    hallazgoWide.hallazgo.afectacion = row[19]
    hallazgoWide.hallazgo.nivelriesgo = row[20]
    hallazgoWide.hallazgo.coordenadas = coordenadaFinal(coordenadaOriginal: row[21])
    hallazgoWide.hallazgo.position = row[22]
    
    let fotos = readFotos(f1: row[23],t1: row[24],
                          f2: row[25],t2: row[26],
                          f3: row[27],t3: row[28],
                          f4: row[29],t4: row[30])
    
    hallazgoWide.hallazgo.$foto.value = fotos  // Fotos
    hallazgoWide.hallazgo.referencia = row[31]
    hallazgoWide.hallazgo.zona = readZona(row[32])   // Zona
    hallazgoWide.hallazgo.tramo1 = row[33]
    
    let abscisakm = row[34].replacingOccurrences(of: ",", with: ".")
    hallazgoWide.hallazgo.abscisakm = (abscisakm as NSString).floatValue
    
    hallazgoWide.hallazgo.shapeleng = Float(row[36]) ?? 0.0  // Shape Leng -Float
    hallazgoWide.hallazgo.diagnostico = row[37]
    hallazgoWide.hallazgo.criticidad = row[38]
    hallazgoWide.hallazgo.tipodiseno = row[39]
    hallazgoWide.hallazgo.propuesta = row[40]
    hallazgoWide.hallazgo.costo = Float(row[41]) ?? 0.0
    hallazgoWide.hallazgo.cota = row[42]
    hallazgoWide.hallazgo.linkdiseno = row[43]
    
    hallazgoWide.revisors.append(contentsOf: readRevisors(row[35]))
    return hallazgoWide
  }
  
  func readRevisors(_ revisorsCSV: String) -> [String] {
    var revisors = [String]()
    
    let revisorsTmp = revisorsCSV.components(separatedBy: ",")
    
    revisorsTmp.forEach { nombreRevisor in
      revisors.append(nombreRevisor.trimmingCharacters(in: .whitespaces))
    }
    
    return revisors
  }
  
  func coordenadaFinal(coordenadaOriginal: String ) -> String {
    var lineString = coordenadaOriginal
    lineString = coordenadaOriginal.replacingOccurrences(of: "LINESTRING", with: "")
    lineString = lineString.replacingOccurrences(of: "MULTILINESTRING", with: "")
    lineString = lineString.replacingOccurrences(of: "Z", with: "")
    lineString = lineString.replacingOccurrences(of: "POINT", with: "")
    lineString = lineString.replacingOccurrences(of: "(", with: "")
    lineString = lineString.replacingOccurrences(of: ")", with: "")
    
    let coordenadas = lineString.components(separatedBy: ",")
    var result: String = ""
    var coordenada: String = ""
    var lat = ""
    var lng = ""
    var alt = ""
    
    coordenadas.forEach { fila in
      let row = fila.trimmingCharacters(in: .whitespaces)
      let coordenadas =  row.components(separatedBy: " ")
      
      lng = coordenadas[0]
      if(coordenadas.count>1){
        lat = coordenadas[1]
      }
          
      if(coordenadas.count>2) {
        alt = coordenadas[2]
      }
      
      coordenada = "{ 'lng': \(lng), 'lat': \(lat), 'alt': \(alt) },"
      result += coordenada
      
      lng = ""
      lat = ""
      alt = ""
      
    }
    
    var coordenadaFinal = "[\(result)]"
    coordenadaFinal = coordenadaFinal.replacingOccurrences(of: "},]", with: "}]")
    
    return coordenadaFinal
  }
    
    func saveContratoToDB(_ req: Request, _ agreements: [Agreement]) async throws {
      var contrato: Contrato
      var corriente: Corriente
  
      for agreement in agreements {
        contrato = agreement.contrato
        
        try await contrato.save(on: req.db)
          
        guard let id = contrato.id else {
          fatalError("Can't get the id")
        }
        
        var i = 0
        for flow in agreement.flow {
          i += 1
          corriente = flow.corriente
          
          let corrienteFinal = Corriente(nombre: corriente.nombre,
                                          puntomedio: corriente.puntomedio,
                                          coordenadas: corriente.coordenadas,
                                          etiquetas: corriente.etiquetas,
                                          descripcion: corriente.descripcion,
                                          fecha: corriente.fecha,
                                          contratoID: id)
            
          try await corrienteFinal.save(on: req.db)
          
          guard let idCorriente = corrienteFinal.id else {
            fatalError("Can't get the id")
          }
          
          for hallazgoWide in flow.visitas {
            
            let hallazgoFinal = Hallazgo(fecha: hallazgoWide.hallazgo.fecha,
                                         nomenclatura: hallazgoWide.hallazgo.nomenclatura,
                                         margen: hallazgoWide.hallazgo.margen,
                                         hallazgo1: hallazgoWide.hallazgo.hallazgo1,
                                         hallazgo2: hallazgoWide.hallazgo.hallazgo2,
                                         hallazgo3: hallazgoWide.hallazgo.hallazgo3,
                                         observacion: hallazgoWide.hallazgo.observacion,
                                         estadoanterior: hallazgoWide.hallazgo.estadoanterior!,
                                         afectacion: hallazgoWide.hallazgo.afectacion,
                                         nivelriesgo: hallazgoWide.hallazgo.nivelriesgo,
                                         coordenadas: hallazgoWide.hallazgo.coordenadas,
                                         position: hallazgoWide.hallazgo.position,
                                         referencia: hallazgoWide.hallazgo.referencia,
                                         zona: hallazgoWide.hallazgo.zona,
                                         tramo1: hallazgoWide.hallazgo.tramo1,
                                         abscisakm: hallazgoWide.hallazgo.abscisakm,
                                         shapeleng: hallazgoWide.hallazgo.shapeleng,
                                         diagnostico: hallazgoWide.hallazgo.diagnostico,
                                         criticidad: hallazgoWide.hallazgo.criticidad,
                                         tipodiseno: hallazgoWide.hallazgo.tipodiseno,
                                         propuesta: hallazgoWide.hallazgo.propuesta,
                                         costo: hallazgoWide.hallazgo.costo,
                                         cota: hallazgoWide.hallazgo.cota,
                                         linkdiseno: hallazgoWide.hallazgo.linkdiseno,
                                         componente: hallazgoWide.hallazgo.componente,
                                         estado: hallazgoWide.hallazgo.estado,
                                        corrienteID: idCorriente)
            
            try await hallazgoFinal.save(on: req.db)
            // ------
            var newRevisor = Revisor()
            for revisor in hallazgoWide.revisors {
              if(revisor != "") {
                let revisorDB = try await Revisor.query(on: req.db)
                  .filter(\.$nickname == revisor)
                  .first()
                
                if(revisorDB == nil) {
                  newRevisor = Revisor(nombres: revisor, apellidos: "", nickname: revisor)
                  try await newRevisor.save(on: req.db)
                  try await hallazgoFinal.$revirsors.attach(newRevisor, on: req.db)
                }else{
                  try await hallazgoFinal.$revirsors.attach(revisorDB!, on: req.db)
                }
              }
            }
            // ------
          }

        }
      }
        
    }
    
    func asignarFecha(fecha: String) -> Date {
      let fechaFinal: Date
      let stringFecha: String
      
      if(fecha != "" && fecha != "1900-01-00") {
        stringFecha = fecha
      } else {
        stringFecha = "01/01/1990"
      }
      
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MM/dd/yy"
      fechaFinal = dateFormatter.date(from: stringFecha)!
      
      return fechaFinal
    }
    
    func readZona(_ zonaCSV: String) -> EnumZona {
        var zona: EnumZona = .NA
        
        switch zonaCSV {
            case "SUR CANALIZADA":
            zona = EnumZona.SUR_CANALIZADA
            case "SUR SIN CANALIZAR":
                zona = EnumZona.SUR_SIN_CANALIZAR
            case "NORTE CANALIZADA":
                zona = EnumZona.NORTE_CANALIZADA
            case "NORTE SIN CANALIZAR":
                zona = EnumZona.NORTE_SIN_CANALIZAR
            case "CENTRO CANALIZADA":
                zona = EnumZona.CENTRO_CANALIZADA
            case "NA":
                zona = EnumZona.NA
            default: break
        }
        
        return zona
    }
    
    func readMargen(_ margenCSV: String) -> EnumMargen {
        var margen: EnumMargen = .NA
        
        switch margenCSV {
            case "M_DERECHA":
                margen = EnumMargen.M_DERECHA
            case "M_IZQUIERDA":
                margen = EnumMargen.M_IZQUIERDA
            case "NA":
                margen = EnumMargen.NA
            case "CENTRO":
                margen = EnumMargen.CENTRO
            default: break
        }
        
        return margen
    }
    
    func readFotos(f1: String, t1: String,
                   f2: String, t2: String,
                   f3: String, t3: String,
                   f4: String, t4: String) -> [Foto] {
        
        var fotos = [Foto]()
        let foto = Foto()
        
        if(f1 != "") {
            foto.src = f1
            foto.etiqueta = t1
            fotos.append(foto)
        }
        if(f2 != "") {
            foto.src = f2
            foto.etiqueta = t2
            fotos.append(foto)
        }
        if(f3 != "") {
            foto.src = f3
            foto.etiqueta = t3
            fotos.append(foto)
        }
        if(f4 != "") {
            foto.src = f4
            foto.etiqueta = t4
            fotos.append(foto)
        }
        
        return fotos
    }
        
    func readEstado(_ estadoCSV: String) -> EnumEstado {
      var estado: EnumEstado = .NA
        
        switch estadoCSV {
            case "BUENO":
            estado = .BUENO
            case "MALO":
            estado = .MALO
            case "REGULAR":
            estado = .REGULAR
            case "NA":
            estado = .NA
            case "SIN ESTADO":
            estado = .SIN_ESTADO
            case "CRITICO":
            estado = .CRITICO
            case "OTRO":
            estado = .OTRO
            case "REPOTENCIADO":
            estado = .REPOTENCIADO
        default: break
        }
        
        return estado
    }
    
    func readComponente(_ componenteCSV: String) -> EnumComponente {
      var componente: EnumComponente = .AZUD
        
        switch componenteCSV {
            case "BARRA":
            componente = .BARRA
            case "ESTRUCTURA DE CAIDA":
            componente = .ESTRUCTURA_DE_CAIDA
            case "MURO":
            componente = .MURO
            case "OBSTRUCCION":
            componente = .OBSTRUCCION
            case "PLACA":
            componente = .PLACA
            case "AZUD":
            componente = .AZUD
            case "BANCA":
            componente = .BANCA
            case "BOCATOMA":
            componente = .BOCATOMA
            case "BOLSA DE GRAVILLA":
            componente = .BOLSA_DE_GRAVILLA
            case "CONTRADIQUE":
            componente = .CONTRADIQUE
            case "CONTROL DE GRADIENTE":
            componente = .CONTROL_DE_GRADIENTE
            case "DIQUE":
            componente = .DIQUE
            case "DIRECCIONADOR":
            componente = .DIRECCIONADOR
            case "GAVION":
            componente = .GAVION
            case "LLAVE":
            componente = .LLAVE
            case "TABIQUE":
            componente = .TABIQUE
            case "TRAVIEZA":
            componente = .TRAVIEZA
            default: break
        }
        
        return componente
    }
    
}
