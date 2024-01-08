import Foundation

enum DataError: Error {
    case emptyFields
    case wrongFormat
    case invalidDateOfBirth
    case invalidDateFormat
    case invalidMesureValue
    case dataIsNotSend
    case getDataError
    
    var localizedDescription: String {
        switch self {
        case .emptyFields:
            return "Not all fields are filled. Back to editing fields?"
        case .wrongFormat:
            return "You can use only letters when filling in the first and last name fields."
        case .invalidDateOfBirth:
            return "Date of birth does not match the format dd.MM.yyyy."
        case .invalidDateFormat:
            return "Date of mesure does not match the format dd-MM-yyyy HH:mm"
        case .invalidMesureValue:
            return "The measurement data format must be 0.0"
        case .dataIsNotSend:
            return "Error! Try request later."
        case .getDataError:
            return "Error! Cannot get data."
        }
    }
}
