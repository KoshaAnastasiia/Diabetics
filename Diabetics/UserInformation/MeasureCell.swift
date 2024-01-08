import UIKit

class MeasureCell: UITableViewCell {
    private lazy var measureDate: UILabel = {
       let label = UILabel()
        label.widthAnchor.constraint(equalToConstant: 150).isActive = true
        return label
    } ()

    private lazy var value: UILabel = {
       let label = UILabel()
        return label
    } ()

    func makeLabelStyle(label: UILabel) {
        label.textColor = .white
        label.backgroundColor = .gray
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    
    private lazy var stackView: UIStackView = {
      let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 5
        stackView.addArrangedSubview(measureDate)
        makeLabelStyle(label: measureDate)
        stackView.addArrangedSubview(value)
        makeLabelStyle(label: value)
        return stackView
    } ()
    
    private func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 10).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func configure (_ viewModel: DataModel.Measurement) {
        let date = viewModel.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy HH:mm"
        let stringDate = dateFormatter.string(from: date)

        let stringValue = "\(viewModel.value)"

        measureDate.text = stringDate
        value.text = stringValue
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(stackView)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
