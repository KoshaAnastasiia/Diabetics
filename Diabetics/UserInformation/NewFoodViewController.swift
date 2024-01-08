import UIKit
import FirebaseAuth

class NewFoodViewController: UIViewController {
    
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
    
    func makeLabelStyle(label: UILabel, text: String) {
        label.text = text
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .black
    }
    
    func makeTextFieldStyle(textField: UITextField) {
        textField.clearButtonMode = .always
        textField.font = UIFont.systemFont(ofSize: 20)
        textField.textColor = .black
        textField.textAlignment = .center
        textField.backgroundColor = .gray
    }

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var dateTextField: UITextField = {
        let textField = UITextField()
        return textField
    } ()
    
    private lazy var foodDescriptionLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var foodDescriptionTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .namePhonePad
        textField.delegate = self
        return textField
    } ()
    
    private lazy var imageLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    
    private lazy var saveFoodButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save measure", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .gray
        button.addTarget(self, action: #selector(tapSaveFood), for: .touchUpInside)
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
    
    @objc func tapSaveFood() {
        do {
            let willSendModel = try makeDataModel()
            dataServise.getData(identificator: currentUser) { dataModel, error in
                if let cloudDataModel = dataModel {
                    if var foodInfo = cloudDataModel.foodInfo {
                        foodInfo.append(contentsOf: willSendModel.foodInfo!)
                        cloudDataModel.foodInfo = foodInfo
                        self.dataServise.setData(data: cloudDataModel, identificator: self.currentUser) { error in
                            if error != nil {
                                self.makeErrorAlert(description: DataError.dataIsNotSend.localizedDescription)
                            } else {
                                self.dateTextField.text = nil
                                self.foodDescriptionTextField.text = nil
                                DispatchQueue.main.async {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        }
                    }
                }
                if let error = error {
                    self.makeErrorAlert(description: error.localizedDescription)
                }
            }
        } catch DataError.emptyFields {
            makeErrorAlert(description: DataError.emptyFields.localizedDescription)
        } catch DataError.invalidDateFormat {
            makeErrorAlert(description: DataError.invalidDateFormat.localizedDescription)
        } catch {
            makeErrorAlert(description: error.localizedDescription)
        }
    }

    func makeDataModel() throws -> DataModel {
        guard
            let dateString = dateTextField.text,
            let foodDescription = foodDescriptionTextField.text
        else {
            throw DataError.emptyFields
        }
        if dateString.isEmpty || foodDescription.isEmpty {
            throw DataError.emptyFields
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy HH:mm"
        guard let dateDate = dateFormatter.date(from: dateString) else {
            throw DataError.invalidDateFormat
        }
        
        let model = DataModel(birthday: nil, firstName: nil, lastName: nil, mesurement: nil, foodInfo: [DataModel.FoodInfo(date: dateDate, description: foodDescription, photo: "photo")])
        return model
    }

    private func setupConstraints() {
        view.addSubview(dateLabel)
        makeLabelStyle(label: dateLabel, text: "Date and time of new measure")
        
        view.addSubview(dateTextField)
        makeTextFieldStyle(textField: dateTextField)
        
        view.addSubview(foodDescriptionLabel)
        makeLabelStyle(label: foodDescriptionLabel, text: "Food description")
        
        view.addSubview(foodDescriptionTextField)
        makeTextFieldStyle(textField: foodDescriptionTextField)
        
        view.addSubview(saveFoodButton)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dateLabel.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        dateTextField.translatesAutoresizingMaskIntoConstraints = false
        dateTextField.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 40).isActive = true
        dateTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        dateTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40).isActive = true
        dateTextField.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        foodDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        foodDescriptionLabel.topAnchor.constraint(equalTo: dateTextField.bottomAnchor, constant: 40).isActive = true
        foodDescriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        foodDescriptionLabel.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        foodDescriptionTextField.translatesAutoresizingMaskIntoConstraints = false
        foodDescriptionTextField.topAnchor.constraint(equalTo: foodDescriptionLabel.bottomAnchor, constant: 40).isActive = true
        foodDescriptionTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        foodDescriptionTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40).isActive = true
        foodDescriptionTextField.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        saveFoodButton.translatesAutoresizingMaskIntoConstraints = false
        saveFoodButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        saveFoodButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        saveFoodButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        self.dateTextField.setDatePickerAsInputViewFor(target: self, selector: #selector(mesureDateSelected), mode: .dateAndTime)
    }
    
    @objc func mesureDateSelected() {
        if let datePicker = self.dateTextField.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yy HH:mm"
            let mesureDateString = dateFormatter.string(from: datePicker.date)
            self.dateTextField.text = mesureDateString
            print(mesureDateString)
        }
        self.dateTextField.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupConstraints()
        addTapGestureToHideKeyboard()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension NewFoodViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        foodDescriptionTextField.resignFirstResponder()
        return true
    }
}

