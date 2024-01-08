import UIKit
import SwiftUI
import FirebaseAuth

class MeasureTableViewController: UIViewController {
    let measureCell = "MeasureCell"
    let foodCell = "FoodCell"
    
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

    enum Item {
        case food(DataModel.FoodInfo)
        case measurement(DataModel.Measurement)

        var timestamp: Date {
            switch self {
            case let .food(foodInfo): return foodInfo.date
            case let .measurement(measurement): return measurement.date
            }
        }
    }

    var measure = [DataModel.Measurement]() {
        didSet {
            updateItems()
        }
    }

    var foodInfo = [DataModel.FoodInfo]() {
        didSet {
            updateItems()
        }
    }

    var items: [Item] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }

    func items(from measurements: [DataModel.Measurement]) -> [Item] {
        let items = measurements.map { measurement in
            Item.measurement(measurement)
        }
        return items
    }

    func items(from foodInfos: [DataModel.FoodInfo]) -> [Item] {
        let items = foodInfos.map { foodInfo in
            Item.food(foodInfo)
        }
        return items
    }

    func updateItems() {
        let measurementItems = items(from: measure)
        let foodItems = items(from: foodInfo)
        let resultArray = measurementItems + foodItems
        let sortedResult = resultArray.sorted { item1, item2 in
            if item1.timestamp < item2.timestamp {
                return true
            } else {
                return false
            }
        }
        items = sortedResult
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        return tableView
    } ()

    private lazy var chartsButton: UIButton = {
        let button = UIButton()
        button.setTitle("See charts", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .gray
        button.addTarget(self, action: #selector(tapChartsButton), for: .touchUpInside)
        return button
    }()

    @objc func tapChartsButton() {
        let host = UIHostingController(rootView: CartsSwiftUIView(dataMeasure: measure))
        navigationController?.pushViewController(host, animated: true)
    }

    private func setupConstraints() {
        view.addSubview(tableView)
        view.addSubview(chartsButton)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: chartsButton.topAnchor, constant: -10).isActive = true

        chartsButton.translatesAutoresizingMaskIntoConstraints = false
        chartsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        chartsButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
        chartsButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        chartsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

    private func makeErrorAlert(description: String) {
        let errorAlert = UIAlertController(title: "Error", message: description, preferredStyle: .alert)
        let errorAction = UIAlertAction(title: "OK", style: .default)
        errorAlert.addAction(errorAction)
        DispatchQueue.main.async {
            self.present(errorAlert, animated: true)
        }
    }

    private func getUserInfo() {
        dataServise.getData(identificator: currentUser) { dataModel, error in
            if let dataModel = dataModel {
                if let dataMeasure = dataModel.mesurement,
                   let foodInfo = dataModel.foodInfo {
                    self.measure = self.sortedMeasure(array: dataMeasure)
                    self.foodInfo = self.sortedFoodInfo(array: foodInfo)
                    print("\(self.measure)")
                    print("\(self.foodInfo)")
                }
            }
            if error != nil {
                self.makeErrorAlert(description: "Cannot get data!")
            }
        }
    }

    func sortedMeasure(array: [DataModel.Measurement]) -> [DataModel.Measurement] {
        let sortedArray = array.sorted(by: { x1, x2 in
            if x1.date < x2.date {
                return true
            } else {
                return false
            }
        })
        return sortedArray
    }
    
    func sortedFoodInfo(array: [DataModel.FoodInfo]) -> [DataModel.FoodInfo] {
        let sortedArray = array.sorted(by: { x1, x2 in
            if x1.date < x2.date {
                return true
            } else {
                return false
            }
        })
        return sortedArray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Table of measure"
        view.backgroundColor = .white
        getUserInfo()
        self.tableView.register(MeasureCell.self, forCellReuseIdentifier: measureCell)
        self.tableView.register(InfoFoodCell.self, forCellReuseIdentifier: foodCell)
        tableView.dataSource = self
        tableView.delegate = self
        setupConstraints()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension MeasureTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let row = self.items.count
        return row
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = items[indexPath.row]
        switch viewModel {
        case let .measurement(measurement):
            let cell = tableView.dequeueReusableCell(withIdentifier: measureCell) as! MeasureCell
            cell.configure(measurement)
            return cell
        case let .food(foodInfo):
            let cell = tableView.dequeueReusableCell(withIdentifier: foodCell) as! InfoFoodCell
            cell.configure(foodInfo)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")

            let deletedCell = items[indexPath.row]
            switch deletedCell {
            case let .measurement(measurement):
                measure.removeAll { element in
                    if element == measurement {
                        return true
                    } else {
                        return false
                    }
                }
            case let .food(food):
                foodInfo.removeAll { element in
                    if element == food {
                        return true
                    } else {
                        return false
                    }
                }
            }
            
            dataServise.getData(identificator: currentUser) { [weak self] dataModel, error in
                if let cloudDataModel = dataModel {
                    guard let self = self else { return }
                    cloudDataModel.mesurement = self.measure
                    cloudDataModel.foodInfo = self.foodInfo
                    self.dataServise.setData(data: cloudDataModel, identificator: self.currentUser) { error in
                        if error != nil {
                            self.makeErrorAlert(description: DataError.dataIsNotSend.localizedDescription)
                        }
                    }
                }
                
            }
        }
    }
}


extension MeasureTableViewController: UITableViewDelegate {}
