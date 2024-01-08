import UIKit

class StackViewModel: UIStackView {
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.layer.borderColor = UIColor.systemGray.cgColor
        label.layer.borderWidth = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 100).isActive = true
        return label
    } ()
    
    lazy var userTextField: UITextField = {
        let textField = UITextField()
        textField.clearButtonMode = .always
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .black
        textField.textAlignment = .left
        textField.backgroundColor = .gray
        return textField
    } ()
    
    func setupStackView() {
        self.axis = .horizontal
        self.spacing = 20
        self.layer.borderColor = UIColor.systemGray.cgColor
        self.layer.borderWidth = 1
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        self.addArrangedSubview(label)
        self.addArrangedSubview(userTextField)
    }

    static func newStackView(labelTitle: String) -> StackViewModel {
        let newStack = StackViewModel()
        newStack.setupStackView()
        newStack.label.text = labelTitle
        return newStack
    }
}
