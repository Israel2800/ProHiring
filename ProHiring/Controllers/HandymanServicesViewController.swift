//
//  HandymanServicesViewController.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 12/23/24.
//

import UIKit

class HandymanServicesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var HandymanServicesTable: UITableView!
    
    var servicios: [HandymanServices] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configurar la tabla
        HandymanServicesTable.delegate = self
        HandymanServicesTable.dataSource = self
        
        // Cargar servicios
        cargarServicios()
        
        // Escuchar notificaciones para recargar la tabla
        NotificationCenter.default.addObserver(self, selector: #selector(recargarTabla), name: NSNotification.Name("BD_LISTA_HandymanServices"), object: nil)
    }
    
    func cargarServicios() {
        servicios = DataManager.shared.todosLosHandymanServices()
        HandymanServicesTable.reloadData()
    }
    
    @objc func recargarTabla() {
        cargarServicios()
    }
    
    // MARK: - Métodos de UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servicios.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as? HandymanServiceTableViewCell else {
            return UITableViewCell()
        }
        
        let servicio = servicios[indexPath.row]
        cell.titleLabel.text = servicio.title
        cell.descriptionLabel.text = servicio.descrip
        
        if let thumbnailURL = servicio.thumbnail, let url = URL(string: thumbnailURL) {
            // Cargar la imagen desde la URL
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.thumbnailImageView.image = image
                    }
                }
            }
        } else {
            cell.thumbnailImageView.image = UIImage(named: "placeholder") // Imagen por defecto
        }
        
        return cell
    }
    
    // MARK: - Métodos de UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Manejar selección si es necesario
    }
}

// MARK: - Clase HandymanServiceTableViewCell

class HandymanServiceTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
}
