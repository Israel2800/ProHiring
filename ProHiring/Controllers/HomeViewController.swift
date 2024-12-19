//
//  HomeViewController.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 12/17/24.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var HomeTableView: UITableView!

    var treeServices: [TreeServices] = []
    var cellTypes: [CellType] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        HomeTableView.delegate = self
        HomeTableView.dataSource = self

        // Registra las celdas
        HomeTableView.register(UINib(nibName: "Cell1", bundle: nil), forCellReuseIdentifier: "Cell1")
        HomeTableView.register(UINib(nibName: "Cell2", bundle: nil), forCellReuseIdentifier: "Cell2")
        HomeTableView.register(UINib(nibName: "Cell3", bundle: nil), forCellReuseIdentifier: "Cell3")

        // Cargar datos desde CoreData
        treeServices = DataManager.shared.todosLosServicios()
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1Home", for: indexPath) as! Cell1Home
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


class Cell1Home: UITableViewCell {
    
    @IBOutlet weak var TestNameCell1: UILabel!
    
    func configure(with service: TreeServices) {
        TestNameCell1.text = "Title: \(service.price ?? "N/A")"
    }
    
    /*@IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    func configure(with service: TreeServices) {
        titleLabel.text = service.title
        if let urlString = service.thumbnail, let url = URL(string: urlString) {
            // Cargar imagen usando una librería como SDWebImage o similar
            thumbnailImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        }
    }*/
}
 

class Cell2: UITableViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var HomePriceTreeService: UILabel!
    
    func configure(with service: TreeServices) {
        HomePriceTreeService.text = service.price
    }
}


class Cell3: UITableViewCell {
    @IBOutlet weak var durationLabel: UILabel!
    /*
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
     */
    func configure(with service: TreeServices) {
        durationLabel.text = "Duration: \(service.duration ?? "N/A")"
    }
}

