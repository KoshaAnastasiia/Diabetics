import UIKit
import FirebaseAuth

class NewMeasureViewController: UIViewController {

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

    private lazy var measureLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    lazy var measureTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .decimalPad
        return textField
    } ()

    
    private lazy var saveMeasureButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save measure", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .gray
        button.addTarget(self, action: #selector(tapSaveMeasure), for: .touchUpInside)
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

    @objc func tapSaveMeasure() {
        do {
            let willSendModel = try makeDataModel()
            dataServise.getData(identificator: currentUser) { dataModel, error in
                if let cloudDataModel = dataModel {
                    if var measurmentInfo = cloudDataModel.mesurement {
                        measurmentInfo.append(contentsOf: willSendModel.mesurement!)
                        cloudDataModel.mesurement = measurmentInfo
                        self.dataServise.setData(data: cloudDataModel, identificator: self.currentUser) { error in
                            if error != nil {
                                self.makeErrorAlert(description: DataError.dataIsNotSend.localizedDescription)
                            } else {
                                self.dateTextField.text = nil
                                self.measureTextField.text = nil
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
        } catch DataError.invalidMesureValue {
            makeErrorAlert(description: DataError.invalidMesureValue.localizedDescription)
        } catch {
            makeErrorAlert(description: error.localizedDescription)
        }
    }

    func makeDataModel() throws -> DataModel {
        guard
            let measureDateString = dateTextField.text,
            let mesureValue = measureTextField.text
        else {
            throw DataError.emptyFields
        }
        if measureDateString.isEmpty || mesureValue.isEmpty {
            throw DataError.emptyFields
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

        let model = DataModel(birthday: nil, firstName: nil, lastName: nil, mesurement: [DataModel.Measurement(date: measureDate, value: doubleMeasure)], foodInfo: nil)
        return model
    }

    private func setupConstraints() {
        view.addSubview(dateLabel)
        makeLabelStyle(label: dateLabel, text: "Date and time of new measure")

        view.addSubview(dateTextField)
        makeTextFieldStyle(textField: dateTextField)

        view.addSubview(measureLabel)
        makeLabelStyle(label: measureLabel, text: "New measure value")

        view.addSubview(measureTextField)
        makeTextFieldStyle(textField: measureTextField)

        
        view.addSubview(saveMeasureButton)

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dateLabel.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        dateTextField.translatesAutoresizingMaskIntoConstraints = false
        dateTextField.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 40).isActive = true
        dateTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        dateTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40).isActive = true
        dateTextField.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        measureLabel.translatesAutoresizingMaskIntoConstraints = false
        measureLabel.topAnchor.constraint(equalTo: dateTextField.bottomAnchor, constant: 40).isActive = true
        measureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        measureLabel.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        measureTextField.translatesAutoresizingMaskIntoConstraints = false
        measureTextField.topAnchor.constraint(equalTo: measureLabel.bottomAnchor, constant: 40).isActive = true
        measureTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        measureTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40).isActive = true
        measureTextField.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        saveMeasureButton.translatesAutoresizingMaskIntoConstraints = false
        saveMeasureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        saveMeasureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        saveMeasureButton.heightAnchor.constraint(equalToConstant: 100).isActive = true

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

extension UIViewController {
    func addTapGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing))
        view.addGestureRecognizer(tapGesture)
    }

    func hideNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

