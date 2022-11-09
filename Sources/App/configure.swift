import Fluent
import FluentPostgresDriver
import Vapor
import PostgresKit
import SendGrid
import Redis

// configures your application
public func configure(_ app: Application) throws {

    /// Configure max upload file size
    app.routes.defaultMaxBodySize = "2mb"
    
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(app.sessions.middleware)
    
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
//            .any(["http://localhost:8080",
//                            "http://localhost:3333",
//                            "https://virtualidad.usbmed.edu.co",
//                            "http://localhost:8081",
//                            "http://localhost:8082",
//                            "http://localhost:8083"]),
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept,
                         .authorization,
                         .contentType,
                         .origin,
                         .xRequestedWith,
                         .userAgent,
                         .accessControlAllowOrigin,
                         .accessControlAllowHeaders,
                         .init("crossDomain")],
        allowCredentials: true
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    // cors middleware should come before default error middleware using `at: .beginning`
    app.middleware.use(cors, at: .beginning)
    
    let port: Int
    if let environmentPort = Environment.get("PORT") {
      port = Int(environmentPort) ?? 8082
    } else {
      port = 8082
    }
    app.http.server.configuration.port = port
    
    let databaseName: String
    let databasePort: Int
    
    if (app.environment == .testing) {
      databaseName = "vapor-test"
      if let testPort = Environment.get("DATABASE_PORT") {
        databasePort = Int(testPort) ?? 5433
      } else {
        databasePort = 5433
      }
    } else {
      databaseName = "vapor_database"
      databasePort = 5432
    }
    
    if var config = Environment.get("DATABASE_URL")
        .flatMap(URL.init)
        .flatMap(PostgresConfiguration.init) {
      config.tlsConfiguration = .forClient(certificateVerification: .none)
      app.databases.use(.postgres(configuration: config), as: .psql)
    } else {
        app.databases.use(
            .postgres(
                hostname: Environment.get("DATABASE_HOST") ?? "localhost",
                port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
                username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
                password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
                database: Environment.get("DATABASE_NAME") ?? databaseName
        ), as: .psql)
    }
    
    // Configuración de Redis
    let redisHostname = Environment.get("REDIS_HOSTNAME") ?? "localhost"
    let redisConfig = try RedisConfiguration(hostname: redisHostname)
    
    app.redis.configuration = redisConfig
    //-----

    app.migrations.add(CreateUser())
    app.migrations.add(CreateContrato())
    app.migrations.add(CreateCorriente())
    app.migrations.add(CreateHallazgo())
    app.migrations.add(CreateComponente())
    app.migrations.add(CreateEstado())
    app.migrations.add(CreateFoto())
    app.migrations.add(CreateRevisor())
  app.migrations.add(CreateHallazgoRevisorPivot())
  app.migrations.add(CreateHallazgoFotoPivot())
  app.migrations.add(AddIcono())
  app.migrations.add(AddColorestado())
    
//    app.databases.middleware.use(UserMiddleware(), on: .psql)

    app.logger.logLevel = .debug
    
    try app.autoMigrate().wait()
    
    app.sessions.use(.redis)

    app.sendgrid.initialize()
    
    try routes(app)
    
}



