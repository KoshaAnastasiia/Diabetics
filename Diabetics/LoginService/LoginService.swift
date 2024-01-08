import FirebaseAuth

protocol Loginable {
    var isLoggedIn: Bool { get }
    func signUpNewUsers(email: String?, password: String?, completion: @escaping (AuthDataResult?, Error?) -> Void) throws
    func login(email: String?, password: String?, completion: @escaping (AuthDataResult?, Error?) -> Void) throws
    func logout() -> Bool?
    
}

protocol UserInfoSavable: AnyObject {
    var user: User? { get set }
}

class SaveUserInfo: UserInfoSavable {
    var user: User?
    
    init() {
        user = Auth.auth().currentUser
    }
}

class LoginServise: NSObject, Loginable {
    var userInfo: UserInfoSavable
    private var completion: (() -> Void)?
    
    init(userInfo: UserInfoSavable) {
        self.userInfo = userInfo
    }
    
    var isLoggedIn: Bool {
        return userInfo.user != nil
    }

    func signUpNewUsers(email: String?, password: String?, completion: @escaping (AuthDataResult?, Error?) -> Void) throws {
        guard let userEmail = email,
              let userPassword = password else {
            throw LoginError.emptyFields
        }
        if userEmail.contains("@") == false && userEmail.contains(".") == false {
            throw LoginError.badlyFormattedEmail
        }
        if userPassword.count < 6 {
            throw LoginError.invalidPassword
        }
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { authResult, error in
            if authResult == nil && error == nil {
                completion(nil, LoginError.unknownSignUpError)
                return
            }
            if let authResult = authResult, error == nil {
                self.userInfo.user = authResult.user
                print("registered \(authResult.user.email)")
                completion(authResult, nil)
                return
            }
            if let error = error, authResult == nil {
                print("\(error.localizedDescription)")
                completion(nil, error)
                
            }
        }
    }

    func login(email: String?, password: String?, completion: @escaping (AuthDataResult?, Error?) -> Void) throws {
        guard let userEmail = email,
              !userEmail.isEmpty,
              let userPassword = password,
              !userPassword.isEmpty
        else {
            throw LoginError.emptyFields
        }
        if userEmail.contains("@") == false && userEmail.contains(".") == false {
            throw LoginError.badlyFormattedEmail
        }
        if userPassword.count < 6 {
            throw LoginError.invalidPassword
        }
        Auth.auth().signIn(withEmail: userEmail, password: userPassword) { authResult, error in
            if authResult == nil && error == nil {
                completion(nil, LoginError.userNotFound)
                return
            }
            if let authResult = authResult, error == nil {
                self.userInfo.user = authResult.user
                print("registered \(authResult.user.email)")
                completion(authResult, nil)
                return
            }
            if let error = error, authResult == nil {
                print("\(error.localizedDescription)")
                completion(nil, LoginError.userNotFound)
                
            }
        }
    }

    func logout() -> Bool? {
        do {
            try Auth.auth().signOut()
            self.userInfo.user = nil
            return true
        } catch {
            return false
        }
    }
}

