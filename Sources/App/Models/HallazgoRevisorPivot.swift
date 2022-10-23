//
//  File.swift
//  
//
//  Created by Robinson Cartagena on 22/10/22.
//
import Fluent
import Foundation

final class HallazgoRevisorPivot: Model {
    static let schema = "hallazgorevisorpivot"
    
    @ID
    var id: UUID?
    
    @Parent(key: "idhallazgo")
    var hallazgo: Hallazgo
    
    @Parent(key: "idrevisor")
    var revisor: Revisor
    
    init() {}
    
    init(id: UUID? = nil, hallazgo: Hallazgo, revisor: Revisor) throws {
        self.id = id
        self.$hallazgo.id = try hallazgo.requireID()
        self.$revisor.id = try revisor.requireID()
    }
}
