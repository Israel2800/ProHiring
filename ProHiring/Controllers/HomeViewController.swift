//
//  HomeViewController.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 12/17/24.
//
/*
import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var HomeTableView: UITableView!

    var treeServices: [TreeServices] = []
    var cellTypes: [CellType] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        HomeTableView.delegate = self
        HomeTableView.dataSource = self

        // Registra las celdas personalizadas utilizando clases
        HomeTableView.register(Cell1.self, forCellReuseIdentifier: "Cell1")
        HomeTableView.register(Cell2.self, forCellReuseIdentifier: "Cell2")
        HomeTableView.register(Cell3.self, forCellReuseIdentifier: "Cell3")

        // Cargar datos desde CoreData
        let allServices = DataManager.shared.todosLosServicios()

        // Filtrar los datos según el criterio necesario
        treeServices = allServices.filter { service in
            // Ejemplo de filtro: mostrar solo servicios con precio mayor a 100
            if let priceString = service.price, let price = Double(priceString) {
                return price > 10
            }
            return false
        }

        cellTypes = generateCellTypes(for: treeServices)
        
        // Recargar la tabla
        HomeTableView.reloadData()
    }

    private func generateCellTypes(for services: [TreeServices]) -> [CellType] {
        // Genera un arreglo alternado para las celdas según el índice
        return services.enumerated().map { index, _ in
            if index % 3 == 0 {
                return .cell1
            } else if index % 3 == 1 {
                return .cell2
            } else {
                return .cell3
            }
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return treeServices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = cellTypes[indexPath.row]
        let service = treeServices[indexPath.row]

        switch cellType {
        case .cell1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! Cell1
            cell.configure(with: service)
            return cell
        case .cell2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! Cell2
            cell.configure(with: service)
            return cell
        case .cell3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell3", for: indexPath) as! Cell3
            cell.configure(with: service)
            return cell
        }
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

// MARK: - Enumeración para las celdas
enum CellType {
    case cell1
    case cell2
    case cell3
}

// Clases para las celdas personalizadas
class Cell1: UITableViewCell {
    let TestNameCell1: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(TestNameCell1)
        NSLayoutConstraint.activate([
            TestNameCell1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            TestNameCell1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            TestNameCell1.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            TestNameCell1.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with service: TreeServices) {
        TestNameCell1.text = service.title
    }
}

class Cell2: UITableViewCell {
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let HomePriceTreeService: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(HomePriceTreeService)
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            HomePriceTreeService.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            HomePriceTreeService.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            HomePriceTreeService.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            HomePriceTreeService.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with service: TreeServices) {
        descriptionLabel.text = service.descrip
        HomePriceTreeService.text = service.price
    }
}

class Cell3: UITableViewCell {
    let durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(durationLabel)
        NSLayoutConstraint.activate([
            durationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            durationLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            durationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with service: TreeServices) {
        durationLabel.text = "Duration: \(service.duration ?? "N/A")"
    }
}
*/

/////////
///
///
///
import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var HomeTableView: UITableView!

    var treeServices: [TreeServices] = []
    var cellTypes: [CellType] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        HomeTableView.delegate = self
        HomeTableView.dataSource = self

        // Registra las celdas personalizadas utilizando clases
        HomeTableView.register(Cell1.self, forCellReuseIdentifier: "Cell1")
        HomeTableView.register(Cell2.self, forCellReuseIdentifier: "Cell2")
        HomeTableView.register(Cell3.self, forCellReuseIdentifier: "Cell3")

        // Cargar datos desde CoreData
        let allServices = DataManager.shared.todosLosServicios()

        // Filtrar los datos según el criterio necesario
        treeServices = allServices.filter { service in
            if let priceString = service.price, let price = Double(priceString) {
                return price > 10
            }
            return false
        }

        cellTypes = generateCellTypes(for: treeServices)
        
        // Recargar la tabla
        print(treeServices)  // Verifica si hay datos cargados
        print("Servicios cargados: \(treeServices.count)")

        HomeTableView.reloadData()
    }

    private func generateCellTypes(for services: [TreeServices]) -> [CellType] {
        return services.enumerated().map { index, _ in
            if index % 3 == 0 {
                return .cell1
            } else if index % 3 == 1 {
                return .cell2
            } else {
                return .cell3
            }
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return treeServices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Cargando celda en la fila \(indexPath.row)")

        let cellType = cellTypes[indexPath.row]
        let service = treeServices[indexPath.row]

        switch cellType {
        case .cell1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! Cell1
            cell.configure(with: service)
            return cell
        case .cell2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! Cell2
            cell.configure(with: service)
            return cell
        case .cell3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell3", for: indexPath) as! Cell3
            cell.configure(with: service)
            return cell
        }
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

// MARK: - Enumeración para las celdas
enum CellType {
    case cell1
    case cell2
    case cell3
}

// Clases para las celdas personalizadas

class Cell1: UITableViewCell {
    
    @IBOutlet weak var TestNameCell1: UILabel!
    
    func configure(with service: TreeServices) {
        TestNameCell1.text = service.title
    }
}

class Cell2: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var HomePriceTreeService: UILabel!
    
    func configure(with service: TreeServices) {
        descriptionLabel.text = service.descrip
        HomePriceTreeService.text = service.price
    }
}

class Cell3: UITableViewCell {
    
    @IBOutlet weak var durationLabel: UILabel!
    
    func configure(with service: TreeServices) {
        durationLabel.text = "Duration: \(service.duration ?? "N/A")"
    }
}

