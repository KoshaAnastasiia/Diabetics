import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    let factory: ViewControllerFactory
    let loginServise: Loginable

    init(loginServise: Loginable, factory: ViewControllerFactory) {
        self.loginServise = loginServise
        self.factory = factory
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var mainStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillEqually
        view.spacing = 20
        return view
    } ()

    private lazy var email: StackViewModel = {
        return StackViewModel.newStackView(labelTitle: "Email")
    }()

    private lazy var password: StackViewModel = {
        return StackViewModel.newStackView(labelTitle: "Password")
    }()

    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .gray
        button.addTarget(self, action: #selector(tapLoginButton), for: .touchUpInside)
        return button
    }()

    private lazy var signUpNewUsersButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign UP", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .gray
        button.addTarget(self, action: #selector(tapSignUpNewUsersButton), for: .touchUpInside)
        return button
    }()

    private func makeErrorAlert(description: String) {
        let errorAlert = UIAlertController(title: "Error", message: description, preferredStyle: .alert)
        let errorAction = UIAlertAction(title: "OK", style: .default)
        errorAlert.addAction(errorAction)
        DispatchQueue.main.async {
            self.present(errorAlert, animated: true)
        }
    }

    @objc func tapLoginButton() {
        do {
            try loginServise.login(email: email.userTextField.text, password: password.userTextField.text, completion: { [weak self] authResalt, error in
                guard authResalt != nil else {
                    let errorText = LoginError.userNotFound.dataErrorDescription
                    let errorAlert = UIAlertController(title: "\(errorText)", message: "Go to registration screen?", preferredStyle: .alert)
                    let agreeAction = UIAlertAction(title: "Yes", style: .default) { _ in
                        if let signUpViewController = self?.factory.makeSignUpViewController(userEmail: self?.email.userTextField.text, userPassword: self?.password.userTextField.text) {
                            self?.navigationController?.pushViewController(signUpViewController, animated: true)
                            return
                        }
                    }
                    let failureAction = UIAlertAction(title: "No", style: .cancel)
                    errorAlert.addAction(agreeAction)
                    errorAlert.addAction(failureAction)
                    self?.present(errorAlert, animated: true)
                    return
                }
                if let viewController = self?.factory.makeUserInfoViewController() {
                    self?.navigationController?.pushViewController(viewController, animated: true)
                    return
                }
            })
        } catch LoginError.emptyFields {
            makeErrorAlert(description: LoginError.emptyFields.dataErrorDescription)
        } catch LoginError.invalidPassword {
            makeErrorAlert(description: LoginError.invalidPassword.dataErrorDescription)
        } catch LoginError.badlyFormattedEmail {
            makeErrorAlert(description: LoginError.badlyFormattedEmail.dataErrorDescription)
        } catch {
            makeErrorAlert(description: error.localizedDescription)
        }
    }

    @objc func tapSignUpNewUsersButton() {
        let signUpViewController = factory.makeSignUpViewController(userEmail: email.userTextField.text, userPassword: password.userTextField.text)
        self.navigationController?.pushViewController(signUpViewController, animated: true)
    }

    private func setupStackView() {
        view.addSubview(mainStackView)
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        mainStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        mainStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        
        mainStackView.addArrangedSubview(email)
        mainStackView.addArrangedSubview(password)
        mainStackView.addArrangedSubview(loginButton)
        mainStackView.addArrangedSubview(signUpNewUsersButton)
        
    }

    private func chekUser() {
        if loginServise.isLoggedIn {
            let viewController = self.factory.makeUserInfoViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
        } else {
            view.backgroundColor = .white
            setupStackView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        chekUser()
    }
}
