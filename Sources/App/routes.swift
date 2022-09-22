import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    let facultadController = FacultadController()
    let docentesController = DocenteController()
    let cursoController = CursoController()
    let informesController = InformesController()
    let programaController = ProgramaController()
    
    try app.register(collection: facultadController)
    try app.register(collection: docentesController)
    try app.register(collection: cursoController)
    try app.register(collection: informesController)
    try app.register(collection: programaController)
    
}
