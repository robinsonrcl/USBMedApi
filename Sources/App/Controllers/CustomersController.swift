import Vapor
import Fluent
import FluentPostgresDriver
import Foundation

struct CustomerController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    
    let customersGroup = routes.grouped("customers")
    
    customersGroup.get("get",":page", ":size", use: getAllCustomers)
    customersGroup.get(":id", use: getCustomer)
    customersGroup.post(use: createCustomer)
    
  }

  func createCustomer(_ req: Request) async throws -> Customer {
    let customer = try req.content.decode(Customer.self)
    
    try await customer.save(on: req.db)
    
    return customer
  }
  
  func validaBearer(aplication: String) -> String {
    return "eyJhbGciOiJSUzI1NiIsImtpZCI6IkQ3OTkxNEU2MTJFRkI4NjE5RDNFQ0U4REFGQTU0RDFBMDdCQjM5QjJSUzI1NiIsInR5cCI6ImF0K2p3dCIsIng1dCI6IjE1a1U1aEx2dUdHZFBzNk5yNlZOR2dlN09iSSJ9.eyJuYmYiOjE2NzYxMzczODksImV4cCI6MTY3NjIyMzc4OSwiaXNzIjoiaHR0cDovL21zLXNlY3VyaXR5c2VydmljZTo1MDAwIiwiYXVkIjoiaHR0cDovL21zLXNlY3VyaXR5c2VydmljZTo1MDAwL3Jlc291cmNlcyIsImNsaWVudF9pZCI6IlNpaWdvQVBJIiwic3ViIjoiMTAxODMxNSIsImF1dGhfdGltZSI6MTY3NjEzNzM4OSwiaWRwIjoibG9jYWwiLCJuYW1lIjoic2lpZ29hcGlAcHJ1ZWJhcy5jb20iLCJtYWlsX3NpaWdvIjoic2lpZ29hcGlAcHJ1ZWJhcy5jb20iLCJjbG91ZF90ZW5hbnRfY29tcGFueV9rZXkiOiJTaWlnb0FQSSIsInVzZXJzX2lkIjoiNjI5IiwidGVuYW50X2lkIjoiMHgwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDM5MjIwMSIsInVzZXJfbGljZW5zZV90eXBlIjoiMCIsInBsYW5fdHlwZSI6IjE0IiwidGVuYW50X3N0YXRlIjoiMSIsIm11bHRpdGVuYW50X2lkIjoiNDA4IiwiY29tcGFuaWVzIjoiMCIsImFwaV9zdWJzY3JpcHRpb25fa2V5IjoiNTYyZTNhMTViMTQ4NDg2ZDkyMTYxYjdhZmNiODdmM2MiLCJhY2NvdW50YW50IjoiZmFsc2UiLCJqdGkiOiIzQzRBRkFDMTQzQjUyMTg3NUY3N0JDNDMzODVFNTJCMCIsImlhdCI6MTY3NjEzNzM4OSwic2NvcGUiOlsiU2lpZ29BUEkiXSwiYW1yIjpbImN1c3RvbSJdfQ.pj0H3GhH1GHex3xwVQGkE94kyRD5T_q0npm7pl6uiq1HLt1SUOxfAfjX6-h4Ha47FyRvUxpaeyQh1j95881HPYCUGYXtJ9-xMsIQpAqu3Dbaaa0KEz0sR0cbjK_U7w5rNePlK6CvimmrMkEq9EHOIxYDQ99z2Ee30wC9OdEU-M2wQTvG5qEk1mcLhiN6H0sIWAzmtHnJckPOBVY6_v0mUX2Q20CauebE3TyMMRnNlPzaL1dd3Sf_rzxogsv4hHDJ-xemUJaVchmf8zXsguDAkxA0JzFcW2YUfE0-RDLfj9H2esP310SQwlB7MvW3zIia15hVxTHiar0EMxXm9eQUZQ"
  }
  
  func getAllCustomers(_ req: Request) async throws -> DataTable {
    var page = 1
    let size = 100
    var linkCRM: URI
//    var dataAll: customersAll
    var arregloResults = [Results]()
    var controlCiclo = true
    var controlLecturasERP = 1
    
    let dataCRMLocal = try await Customer.query(on: req.db).all()
    
    linkCRM = "https://api.siigo.com/v1/customers?page=\(page)&page_size=\(size)"
    
    while controlCiclo {
      var customerCRM = try await req.client.get(linkCRM) { createRequest in
        let authHeader = validaBearer(aplication: "ERP")
        createRequest.headers.add(name: .authorization, value: authHeader)
      }
      
      let data = try customerCRM.content.decode(dataCRM.self)  //.content.decode(dataCRM.self)
      
      data.results.forEach { result in
        var resultLocal = Results()
        resultLocal.id = result.id
        resultLocal.type = result.type
        resultLocal.person_type = result.person_type
        resultLocal.identification = result.identification
        
        resultLocal.id_type = result.id_type
        resultLocal.name = result.name
        resultLocal.commercial_name = result.commercial_name
        resultLocal.active = result.active
        resultLocal.vat_responsible = result.vat_responsible
        resultLocal.address = result.address
        resultLocal.phones = result.phones
        resultLocal.contacts = result.contacts
        
        let record = dataCRMLocal.filter { row in
          row.idcrm == resultLocal.id
        }
        
        if(!record.isEmpty){
          resultLocal.ltipocliente = record[0].ltipocliente
          resultLocal.lmoneda = record[0].lmoneda
          resultLocal.lsector = record[0].lsector
          resultLocal.lemailfacturar = record[0].lemailfacturar
        }else{
          resultLocal.lmoneda = "COP"
          resultLocal.ltipocliente = "Platino"
          
          let CustomerNew = Customer(idcrm: resultLocal.id!,
                                     ltipocliente: "Platino",
                                     lmoneda: "COP",
                                     lemailfacturar: "",
                                     lsector: "")
          _ = CustomerNew.save(on: req.db)
        }
        
        arregloResults.append(resultLocal)
      }
      let link = data._links.next!.href
      controlLecturasERP += 1
      if(link == "" || controlLecturasERP > 5){
        controlCiclo = false
      }
      linkCRM = URI(stringLiteral: link)
    }
    
    //dataAll.results = arregloResults
    
    let data = DataTable(data: arregloResults, draw: 1, recordsTotal: 100, recordsFiltered: 100)
    
    return data
  }
  
//  func getAllCustomers(_ req: Request) async throws -> DataTable  {
//
//    let data = try await readAllCustomerERP(req)
//
//    let dataCRM = try await Customer.query(on: req.db).all()
//
//    var customers = customersAll()
//    var arregloResults = [Results]()
//
//    data.results.forEach { result in
//      var resultLocal = Results()
//      resultLocal.id = result.id
//      resultLocal.type = result.type
//      resultLocal.person_type = result.person_type
//      resultLocal.identification = result.identification
//
//      resultLocal.id_type = result.id_type
//      resultLocal.name = result.name
//      resultLocal.commercial_name = result.commercial_name
//      resultLocal.active = result.active
//      resultLocal.vat_responsible = result.vat_responsible
//      resultLocal.address = result.address
//      resultLocal.phones = result.phones
//      resultLocal.contacts = result.contacts
//
//      let record = dataCRM.filter { row in
//        row.idcrm == resultLocal.id
//      }
//
//      if(!record.isEmpty){
//        resultLocal.ltipocliente = record[0].ltipocliente
//        resultLocal.lmoneda = record[0].lmoneda
//        resultLocal.lsector = record[0].lsector
//        resultLocal.lemailfacturar = record[0].lemailfacturar
//      }else{
//        resultLocal.lmoneda = "COP"
//        resultLocal.ltipocliente = "Platino"
//
//        let CustomerNew = Customer(idcrm: resultLocal.id!,
//                                   ltipocliente: "Platino",
//                                   lmoneda: "COP",
//                                   lemailfacturar: "",
//                                   lsector: "")
//        _ = CustomerNew.save(on: req.db)
//      }
//
//      arregloResults.append(resultLocal)
//    }
//
//    customers.results = arregloResults
//    customers.pagination = data.pagination
//    customers._links = data._links
//
//    //--- Info para datatable
//    let datatable = DataTable(data: arregloResults,
//                              draw: data.pagination.page,
//                              recordsTotal: data.pagination.total_results,
//                              recordsFiltered: data.pagination.total_results)
//    //---
//
//    return datatable
//  }
  
  struct DataTable: Content {
    var data: [Results]
    var draw: Int
    var recordsTotal: Int
    var recordsFiltered: Int
  }
  
  struct Pagination: Content {
    var page: Int
    var page_size: Int
    var total_results: Int
  }
  
  struct ResultsCRM: Content {
    var id: UUID
    var identification: String?
    var type: String?
    var person_type: String?
    var id_type: idType?
    var name: [String]?
    var commercial_name: String?
    var active: Bool
    var vat_responsible: Bool
    var address: Address?
    var phones: [Phone]?
    var contacts: [Contact]?
  }
  
  struct Contact: Content {
    var first_name: String?
    var last_name: String?
    var email: String?
    var phone: Phone?
  }
  
  struct Phone: Content {
    var indicative: String?
    var number: String?
  }
  
  struct Address: Content {
    var address: String?
    var postal_code: String?
    var city: City?
  }
  
  struct City: Content {
    var country_name: String?
    var state_name: String?
    var city_name: String?
  }
  
  struct idType: Content {
    var code: String?
    var name: String?
  }
  
  struct Results: Content {
    var id: UUID?
    var identification: String?
    var type: String?
    var person_type: String?
    var id_type: idType?
    var name: [String]?
    var commercial_name: String?
    var active: Bool?
    var vat_responsible: Bool?
    var address: Address?
    var phones: [Phone]?
    var contacts: [Contact]?
    
    var ltipocliente: String?
    var lmoneda: String?
    var lsector: String?
    var lemailfacturar: String?
    
    init() {}
  }
  
  struct dataCRM: Content {
    var pagination:  Pagination?
    var results: [ResultsCRM]
    var _links: Links
  }
  
  struct Links: Content {
    var `self`: Href
    var next: Href?
    var previous: Href?
  }
  
  struct Href: Content {
    var href: String
  }
  
  struct customersAll: Content {
    var pagination: Pagination?
    var results: [Results]?
    var _links: Links?
    
    init() {}
  }
  
  func getCustomer(_ req: Request) async throws -> Customer {
    try await Customer.find(req.parameters.get("id"), on: req.db)!
  }
}
