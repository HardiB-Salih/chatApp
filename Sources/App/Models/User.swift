import Fluent
import Vapor

final class User: Model, @unchecked Sendable, Validatable, Authenticatable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "avatar_name")
    var avatarName: String
    
    @Field(key: "avatar_color")
    var avatarColor: String
    
    init() { }
    
    init(id: UUID? = nil, name: String, email: String, username: String, password: String, avatarName: String, avatarColor: String) {
        self.id = id
        self.name = name
        self.email = email
        self.username = username
        self.password = password
        self.avatarName = avatarName
        self.avatarColor = avatarColor
    }
    
    func toDTO() -> UserDOT {
        return UserDOT(
            id: self.id,
            name: self.name,
            email: self.email,
            username: self.username,
            avatarName: self.avatarName,
            avatarColor: self.avatarColor
        )
    }
    
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty, customFailureDescription: "Name cannot be empty.")
        validations.add("email", as: String.self, is: !.empty && .email, customFailureDescription: "Invalid email format.")
        validations.add("username", as: String.self, is: !.empty && .alphanumeric && .count(3...), customFailureDescription: "Username must be at least 3 characters long and contain only alphanumeric characters.")
        
        // Combined validation for password
        validations.add("password", as: String.self, is: !.empty && .count(6...10), customFailureDescription: "Password must be between 6 to 10 characters long and cannot be empty.")
        
        validations.add("avatarName", as: String.self, is: !.empty, customFailureDescription: "Avatar name cannot be empty.")
        validations.add("avatarColor", as: String.self, is: !.empty, customFailureDescription: "Avatar color cannot be empty.")
    }
}

