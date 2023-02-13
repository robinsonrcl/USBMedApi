import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    let customerController = CustomerController()
    
    try app.register(collection: customerController)
    
}
