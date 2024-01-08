import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {
    let factory: ViewControllerFactory
    let loginServise: Loginable
    let userEmail: String?
    let userPassword: String?

    init(loginServise: Loginable, factory: ViewControllerFactory, userEmail: String?, userPassword: String?) {
        self.loginServise = loginServise
        self.factory = factory
        self.userEmail = userEmail
        self.userPassword = userPassword
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

    func setupKeyboard() {
        email.userTextField.keyboardType = .emailAddress
        password.userTextField.passwordRules = .none
    }
    
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

    @objc func tapSignUpNewUsersButton() {
        do {
            try loginServise.signUpNewUsers(email: email.userTextField.text, password: password.userTextField.text, completion: { [weak self] authResalt, error in
                guard authResalt != nil else {
                    self?.makeErrorAlert(description: LoginError.unknownSignUpError.dataErrorDescription)
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
            makeErrorAlert(description: LoginError.invalidPassword.dataErrorDescription)
        } catch {
            makeErrorAlert(description: error.localizedDescription)
        }
    }

    private func setupStackView() {
        view.addSubview(mainStackView)
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        mainStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        mainStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        
        mainStackView.addArrangedSubview(email)
        mainStackView.addArrangedSubview(password)
        mainStackView.addArrangedSubview(signUpNewUsersButton)
    }

    private func checkFields() {
        if userEmail != nil {
            email.userTextField.text = userEmail
        }
        if userPassword != nil {
            password.userTextField.text = userPassword
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        checkFields()
        setupStackView()
    }
    
}
