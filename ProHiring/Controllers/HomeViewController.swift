//
//  HomeViewController.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 12/17/24.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var HomeTableView: UITableView!
    @IBOutlet weak var logoutBtn: UIImageView!  // IBOutlet para la imagen de cierre de sesión
    
    var treeServices: [TreeServices] = []
    var cellTypes: [CellType] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Habilitar interacción con el UIImageView
        logoutBtn.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(logout))
        logoutBtn.addGestureRecognizer(tapGesture)
        
        HomeTableView.delegate = self
        HomeTableView.dataSource = self

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

    @objc func logout() {
        let alert = UIAlertController(title: "Cerrar Sesión", message: "¿Está seguro de que desea cerrar sesión?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Cerrar Sesión", style: .destructive) { _ in
            // Eliminar valores de UserDefaults
            let ud = UserDefaults.standard
            ud.removeObject(forKey: "customLogin") // Elimina flag de login
            ud.removeObject(forKey: "userEmail")  // Elimina correo guardado
            ud.synchronize() // Asegurar la escritura inmediata

            // Cerrar sesión en Google
            GIDSignIn.sharedInstance.signOut()

            // Cerrar sesión en Firebase
            do {
                try Auth.auth().signOut()
            } catch {
                print("Error al cerrar sesión en Firebase: \(error.localizedDescription)")
            }

            // Navegar a la pantalla de inicio de sesión
            if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true)
            }
        })
        
        present(alert, animated: true)
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
    @IBOutlet weak var HomePriceTreeService: UILabel!
    func configure(with service: TreeServices) {
        HomePriceTreeService.text = service.price
    }
}

class Cell3: UITableViewCell {
    @IBOutlet weak var durationLabel: UILabel!
    func configure(with service: TreeServices) {
        durationLabel.text = "Duration: \(service.duration ?? "N/A")"
    }
}
