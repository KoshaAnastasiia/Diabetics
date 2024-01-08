import FirebaseCore
import FirebaseFirestore

protocol DataManagment: AnyObject {
    func setData(data: DataModel, identificator: UserInfoSavable, completion: @escaping (Error?) -> Void)
    func getData(identificator: UserInfoSavable, completion: @escaping (DataModel?, Error?) -> Void)
}

enum DataServiceError: Error {
    case unAuthentication
    case internalError
    
    var localizedDescription: String {
        switch self {
        case .unAuthentication:
            return "User is not authorized"
        case .internalError:
            return "Internal error"
        }
    }
}

class DataService: DataManagment {
    let db = Firestore.firestore()
    
    func setData(data: DataModel, identificator: UserInfoSavable, completion: @escaping (Error?) -> Void) {
        if let userEmail = identificator.user?.email {
            guard let dictionary = try? data.asDictionary()
            else {
                completion(DataServiceError.internalError)
                return
            }
            db.collection("profiles").document("\(userEmail)").setData(dictionary) { error in
                if let error = error {
                    print("Error writing document: \(error.localizedDescription)")
                    completion(error)
                } else {
                    print("Document successfully written!")
                    completion(nil)
                }
                
            }
        } else {
            completion(DataServiceError.unAuthentication)
        }
    }
    
    func getData(identificator: UserInfoSavable, completion: @escaping (DataModel?, Error?) -> Void) {
        if let userEmail = identificator.user?.email {
            db.collection("profiles").document("\(userEmail)").getDocument { document, error in
                if let document = document, document.exists {
                    if let data = document.data() {
                        guard let userInfo = try? DataModel(from: data)
                        else {
                            completion(nil, DataServiceError.internalError)
                            return
                        }
                        completion(userInfo, nil)
                        print("Document data: \(userInfo)")
                        return
                    }
                } else {
                    completion(nil, error)
                    print("Document does not exist")
                    return
                }
            }
        } else {
            completion(nil, DataServiceError.unAuthentication)
        }
    }
}




