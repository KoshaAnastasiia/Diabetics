import UIKit
import FirebaseAuth

class UserViewController: UIViewController {
    let currentUser: UserInfoSavable
    let loginServise: Loginable
    let factory: ViewControllerFactory
    let dataServise: DataManagment

    init(currentUser: UserInfoSavable, loginServise: Loginable, factory: ViewControllerFactory, dataServise: DataManagment) {
        self.currentUser = currentUser
        self.loginServise = loginServise
        self.factory = factory
        self.dataServise = dataServise
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var userBirthdayLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    func makeLabelStyle(label: UILabel) {
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .black
    }
    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        return button
    }()

    @objc func tapLogoutButton() {
        guard loginServise.logout() == true else {
            let alert = UIAlertController(title: "Выход из профиля не выполнен", message: "Попробуйте позже", preferredStyle: .alert)
            let action = UIAlertAction(title: "ОК", style: .default)
            alert.addAction(action)
            present(alert, animated: true)
            return
        }
        let viewController = factory.makeLoginViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func makeButtonStyle(button: UIButton, text: String, selector: Selector) {
        button.setTitle(text, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .gray
        button.addTarget(self, action: selector, for: .touchUpInside)
    }
    
    private lazy var makeNewMeasureButton: UIButton = {
        let button = UIButton()
        return button
    }()

    @objc func tapMakeNewMeasure() {
        let viewController = factory.makeNewMeasureViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

    private lazy var addNewFoodButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    @objc func tapMakeNewFood() {
        let viewController = factory.makeNewFoodViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func getUserInfo() {
        dataServise.getData(identificator: currentUser) { dataModel, error in
            if let dataModel = dataModel {
                if let userFirstName = dataModel.firstName, let userLastName = dataModel.lastName {
                    self.userNameLabel.text = userFirstName + " " + userLastName
                    self.userBirthdayLabel.text = dataModel.birthday
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            if error != nil {
                let errorAlert = UIAlertController(title: "Error", message: "Cannot get data!", preferredStyle: .alert)
                let errorAction = UIAlertAction(title: "OK", style: .default)
                errorAlert.addAction(errorAction)
                DispatchQueue.main.async {
                    self.present(errorAlert, animated: true)
                }
            }
        }
    }

    private lazy var measureTableViewButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    @objc func tapMeasureTableView() {
        let viewController = factory.makeMeasureTableViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func setupConstraints() {
        view.addSubview(userNameLabel)
        makeLabelStyle(label: userNameLabel)

        view.addSubview(userBirthdayLabel)
        makeLabelStyle(label: userBirthdayLabel)

        view.addSubview(makeNewMeasureButton)
        makeButtonStyle(button: makeNewMeasureButton, text: " Make New Measure ", selector: #selector(tapMakeNewMeasure))

        view.addSubview(addNewFoodButton)
        makeButtonStyle(button: addNewFoodButton, text: " Add Food ", selector: #selector(tapMakeNewFood))

        view.addSubview(addNewFoodButton)
        makeButtonStyle(button: addNewFoodButton, text: " Add New Food ", selector: #selector(tapMakeNewFood))

        view.addSubview(logoutButton)
        makeButtonStyle(button: logoutButton, text: "  Logout  ", selector: #selector(tapLogoutButton))

        view.addSubview(measureTableViewButton)
        makeButtonStyle(button: measureTableViewButton, text: "Measure Table", selector: #selector(tapMeasureTableView))
        
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        userNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        userNameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        userBirthdayLabel.translatesAutoresizingMaskIntoConstraints = false
        userBirthdayLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 20).isActive = true
        userBirthdayLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        userBirthdayLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        makeNewMeasureButton.translatesAutoresizingMaskIntoConstraints = false
        makeNewMeasureButton.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -20).isActive = true
        makeNewMeasureButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        makeNewMeasureButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        addNewFoodButton.translatesAutoresizingMaskIntoConstraints = false
        addNewFoodButton.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -20).isActive = true
        addNewFoodButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        addNewFoodButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        measureTableViewButton.translatesAutoresizingMaskIntoConstraints = false
        measureTableViewButton.bottomAnchor.constraint(equalTo: makeNewMeasureButton.topAnchor, constant: -20).isActive = true
        measureTableViewButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        measureTableViewButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        getUserInfo()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar()
    }
    
}
