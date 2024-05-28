import Fluent
import FluentPostgresDriver
import Vapor


// configures your application
public func configure(_ app: Application) async throws {
    

    
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    // register routes
    
    if let databaseURL = Environment.get("DATABASE_URL") {
        var tlsConfig: TLSConfiguration = .makeClientConfiguration()
        tlsConfig.certificateVerification = .none
        let nioSSLContext = try NIOSSLContext(configuration: tlsConfig)
        
        var postgresConfig = try SQLPostgresConfiguration(url: databaseURL)
        postgresConfig.coreConfiguration.tls = .require(nioSSLContext)
        
        app.databases.use(.postgres(configuration: postgresConfig), as: .psql)
    } else {
        //connect the database here
        app.databases.use(
            .postgres(
                configuration: .init(
                    hostname: Environment.get("DB_HOST_NAME") ?? "localhost",
                    username: Environment.get("DB_USER_NAME") ?? "postgres",
                    password: Environment.get("DB_Password") ?? "",
                    database: Environment.get("DB_NAME") ?? "chatappdb",
                    tls: .disable
                )
            ),
            as: .psql
        )
    }
    
    //register Migrations
    app.migrations.add(UserMigration())
    app.migrations.add(ChannelMigration())
    
    // register the Controller
    try app.register(collection: UserController())
    
    
    // Add this configeration so JWT will Provide a Tocken for sign in user
    app.jwt.signers.use(.hs256(key: Environment.get("JWT_SECRET_KEY") ?? "SECRET_KEY"))
    
    // Register middleware
    app.middleware.use(UserAuthenticator())
    
    try routes(app)
}
