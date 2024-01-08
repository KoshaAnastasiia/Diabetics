import Foundation
import UIKit

final class ViewControllerFactory {
    private let graph: Graph
    
    init(graph: Graph) {
        self.graph = graph
    }

    func makeLoginViewController() -> UIViewController {
        return LoginViewController(loginServise: graph.loginService, factory: self)
    }

    func makeUserInfoViewController() -> UIViewController {
        return FillUserFormViewController(currentUser: graph.userInfoSavable, loginServise: graph.loginService, factory: self, dataServise: graph.dataManegment)
    }

    func makeSignUpViewController(userEmail: String?, userPassword: String?) -> UIViewController {
        return SignUpViewController(loginServise: graph.loginService, factory: self, userEmail: userEmail, userPassword: userPassword)
    }

    func makeUserViewController() -> UIViewController {
        return UserViewController(currentUser: graph.userInfoSavable, loginServise: graph.loginService, factory: self, dataServise: graph.dataManegment)
    }
    
    func makeNewMeasureViewController() -> UIViewController {
        return NewMeasureViewController(currentUser: graph.userInfoSavable, loginServise: graph.loginService, factory: self, dataServise: graph.dataManegment)
    }

    func makeNewFoodViewController() -> UIViewController {
        return NewFoodViewController(currentUser: graph.userInfoSavable, loginServise: graph.loginService, factory: self, dataServise: graph.dataManegment)
    }
    
    func makeMeasureTableViewController() -> UIViewController {
        return MeasureTableViewController(currentUser: graph.userInfoSavable, loginServise: graph.loginService, factory: self, dataServise: graph.dataManegment)
    }
    
}

