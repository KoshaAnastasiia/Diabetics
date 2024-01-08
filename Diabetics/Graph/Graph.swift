import Foundation
import UIKit

final class Graph {
    let loginService: Loginable
    let userInfoSavable: UserInfoSavable
    let dataManegment: DataManagment
    
    init() {
        self.userInfoSavable = SaveUserInfo()
        self.loginService  = LoginServise(userInfo: userInfoSavable)
        self.dataManegment = DataService()
    }
}
