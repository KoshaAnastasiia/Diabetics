import UIKit
import FirebaseAuth

class FillUserFormViewController: UIViewController {
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

    private lazy var mainStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillEqually
        view.spacing = 20
        return view
    } ()

    private lazy var userFirstName: StackViewModel = {
        return StackViewModel.newStackView(labelTitle: "First Name")
    }()

    private lazy var userLastName: StackViewModel = {
        return StackViewModel.newStackView(labelTitle: "Last Name")
    }()

    private lazy var userBirthday: StackViewModel = {
        return StackViewModel.newStackView(labelTitle: "Birthday")
    }()

    private lazy var userMeasureDate: StackViewModel = {
        return StackViewModel.newStackView(labelTitle: "Mesure Date")
    }()

    private lazy var userMeasureValue: StackViewModel = {
        return StackViewModel.newStackView(labelTitle: "Mesure Value")
    }()
    
    func setupKeyboard() {
        userFirstName.userTextField.keyboardType = .namePhonePad
        userLastName.userTextField.keyboardType = .namePhonePad
        userMeasureValue.userTextField.keyboardType = .decimalPad
    }

    private lazy var saveUserInfo: UIButton = {
        let button = UIButton()
        button.setTitle("Save Info", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .gray
        button.addTarget(self, action: #selector(tapSaveUserInfo), for: .touchUpInside)
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

    @objc func tapSaveUserInfo() {
        do {
            let dataModel = try makeDataModel()
            dataServise.setData(data: dataModel, identificator: currentUser) { error in
                if error != nil {
                    self.makeErrorAlert(description: DataError.dataIsNotSend.localizedDescription)
                } else {
                    self.userFirstName.userTextField.text = nil
                    self.userLastName.userTextField.text = nil
                    self.userBirthday.userTextField.text = nil
                    self.userMeasureDate.userTextField.text = nil
                    self.userMeasureValue.userTextField.text = nil
                    let viewController = self.factory.makeUserViewController()
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            }
        } catch DataError.emptyFields {
            makeErrorAlert(description: DataError.emptyFields.localizedDescription)
        } catch DataError.wrongFormat {
            makeErrorAlert(description: DataError.wrongFormat.localizedDescription)
        } catch DataError.invalidDateOfBirth {
            makeErrorAlert(description: DataError.invalidDateOfBirth.localizedDescription)
        } catch DataError.invalidDateFormat {
            makeErrorAlert(description: DataError.invalidDateFormat.localizedDescription)
        } catch DataError.invalidMesureValue {
            makeErrorAlert(description: DataError.invalidMesureValue.localizedDescription)
        } catch {
            makeErrorAlert(description: error.localizedDescription)
        }
        
    }

    private func makeDataModel() throws -> DataModel {
        guard
            let firstName = userFirstName.userTextField.text,
            let lastName = userLastName.userTextField.text,
            let birthday = userBirthday.userTextField.text,
            let measureDateString = userMeasureDate.userTextField.text,
            let mesureValue = userMeasureValue.userTextField.text
        else {
            throw DataError.emptyFields
        }
        if firstName.isEmpty || lastName.isEmpty || birthday.isEmpty || measureDateString.isEmpty || mesureValue.isEmpty {
            throw DataError.emptyFields
        }

        for character in firstName {
            if character.isLetter == false {
                throw DataError.wrongFormat
            }
        }

        for character in lastName {
            if character.isLetter == false {
                throw DataError.wrongFormat
            }
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy HH:mm"
        guard let measureDate = dateFormatter.date(from: measureDateString) else {
            throw DataError.invalidDateFormat
        }

        guard let doubleMeasure = try? Double(mesureValue, format: .number),
                0 < doubleMeasure, doubleMeasure < 20 else {
            throw DataError.invalidMesureValue
        }

        let model = DataModel(birthday: birthday, firstName: firstName, lastName: lastName, mesurement: [DataModel.Measurement(date: measureDate, value: doubleMeasure)], foodInfo: nil)
        return model
    }

    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("Logout", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .gray
        button.addTarget(self, action: #selector(tapLogoutButton), for: .touchUpInside)
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
    
    
    private func setupStackView() {
        view.addSubview(mainStackView)
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        mainStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        mainStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true

        mainStackView.addArrangedSubview(userFirstName)
        mainStackView.addArrangedSubview(userLastName)
        mainStackView.addArrangedSubview(userBirthday)
        mainStackView.addArrangedSubview(userMeasureDate)
        mainStackView.addArrangedSubview(userMeasureValue)
        mainStackView.addArrangedSubview(saveUserInfo)
        mainStackView.addArrangedSubview(logoutButton)
        
        self.userBirthday.userTextField.setDatePickerAsInputViewFor(target: self, selector: #selector(birthdayDateSelected), mode: .date)
        self.userMeasureDate.userTextField.setDatePickerAsInputViewFor(target: self, selector: #selector(mesureDateSelected), mode: .dateAndTime)
        
    }

    @objc func birthdayDateSelected() {
        if let datePicker = self.userBirthday.userTextField.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            self.userBirthday.userTextField.text = dateFormatter.string(from: datePicker.date)
        }
        self.userBirthday.userTextField.resignFirstResponder()
        self.view.endEditing(true)
        
    }
    
    @objc func mesureDateSelected() {
        if let datePicker = self.userMeasureDate.userTextField.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yy HH:mm"
            let mesureDateString = dateFormatter.string(from: datePicker.date)
            self.userMeasureDate.userTextField.text = mesureDateString
            print(mesureDateString)
        }
        self.userMeasureDate.userTextField.resignFirstResponder()
        self.view.endEditing(true)
    }

    func checkUserInfo() {
        dataServise.getData(identificator: currentUser) { dataModel, error in
            if let dataModel = dataModel {
                if dataModel.firstName != nil, dataModel.lastName != nil, dataModel.birthday != nil {
                    let viewController = self.factory.makeUserViewController()
                    self.navigationController?.pushViewController(viewController, animated: true)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        checkUserInfo()
        setupStackView()
        addTapGestureToHideKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
    }
}

extension UITextField {
    func setDatePickerAsInputViewFor(target: Any, selector: Selector, mode: UIDatePicker.Mode) {
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.datePickerMode = mode
        datePicker.preferredDatePickerStyle = .wheels
        self.inputView = datePicker
        
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 40.0))
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(tapCancel))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: target, action: selector)
        toolBar.setItems([cancel,flexibleSpace, done], animated: false)
        self.inputAccessoryView = toolBar
    }
    
    @objc func tapCancel() {
        self.resignFirstResponder()
    }
}
