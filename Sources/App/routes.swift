import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    let hallazgoController = HallazgoController()
    let contratoController = ContratoController()
    
    try app.register(collection: hallazgoController)
    try app.register(collection: contratoController)
    
}
