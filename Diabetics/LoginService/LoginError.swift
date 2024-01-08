import Foundation

enum LoginError: Error {
    case emptyFields
    case badlyFormattedEmail
    case userNotFound
    case invalidPassword
    case unknownSignUpError
    
    var dataErrorDescription: String {
        switch self {
        case .emptyFields:
            return "Not all fields are raised"
        case .badlyFormattedEmail:
            return "The email address is badly formatted."
        case .userNotFound:
            return "There is no user record corresponding to this identifier. The user may have been deleted."
        case.invalidPassword:
            return "The password is invalid (less than 6 characters) or the user does not have a password."
        case .unknownSignUpError:
            return "Registration failed"
        }
    }
}
