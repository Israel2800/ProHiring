//
//  HomeViewController.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 12/17/24.
//

import UIKit
import SDWebImage
import GoogleSignIn
import FirebaseAuth

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var logoutBtn: UIImageView!  // IBOutlet para la imagen de cierre de sesión
    @IBOutlet weak var HomeViewTable: UITableView!
    
    var categories: [TreeServices] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configurar la tabla
        HomeViewTable.delegate = self
        HomeViewTable.dataSource = self
        
        // Cargar servicios
        cargarServicios()
        
        // Escuchar notificaciones para recargar la tabla
        NotificationCenter.default.addObserver(self, selector: #selector(recargarTabla), name: NSNotification.Name("BD_LISTA_HomeData"), object: nil)
        
        // Habilitar interacción con el UIImageView
        logoutBtn.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(logout))
        logoutBtn.addGestureRecognizer(tapGesture)
    }
    
    @objc func logout() {
        let alert = UIAlertController(title: "Cerrar Sesión", message: "¿Está seguro de que desea cerrar sesión?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Cerrar Sesión", style: .destructive) { _ in
            let ud = UserDefaults.standard
            ud.removeObject(forKey: "customLogin")
            ud.removeObject(forKey: "userEmail")
            ud.synchronize()

            GIDSignIn.sharedInstance.signOut()

            do {
                try Auth.auth().signOut()
            } catch {
                print("Error al cerrar sesión en Firebase: \(error.localizedDescription)")
            }

            if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true)
            }
        })

        present(alert, animated: true)
    }
    
    func cargarServicios() {
        categories = DataManager.shared.todosLosTreeServices()
        HomeViewTable.reloadData()
    }
    
    @objc func recargarTabla() {
        cargarServicios()
    }
    
    // MARK: - Métodos de UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // Ejemplo, solo una fila para el UICollectionView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeDataTableViewCell", for: indexPath) as? HomeDataTableViewCell else {
            return UITableViewCell()
        }
        
        // Pasar los datos al UICollectionView dentro de la celda
        cell.configurarCategorias(categories: categories)
        
        return cell
    }
    
    // MARK: - Métodos de UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class HomeDataTableViewCell: UITableViewCell, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView! // El UICollectionView dentro de la celda
    
    var categories: [TreeServices] = [] // Datos para el UICollectionView
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configurar el collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Registrar la celda del UICollectionView
        //collectionView.register(UINib(nibName: "HomeDataCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeDataTableViewCell")
    }
    
    func configurarCategorias(categories: [TreeServices]) {
        self.categories = categories
        collectionView.reloadData()
    }
}

class HomeDataCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageNameView: UIImageView!  // Este es el UIImageView de la celda del UICollectionView
    @IBOutlet weak var titleLabel: UILabel!  // Este es el UILabel de la celda del UICollectionView
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Configuración adicional si es necesario
    }
}

// MARK: - UICollectionViewDataSource
extension HomeDataTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeDataTableViewCell", for: indexPath) as? HomeDataCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let category = categories[indexPath.item]
        cell.titleLabel.text = category.title

        // Usar SDWebImage para cargar la imagen desde la URL
        if let imageName = category.thumbnail, let url = URL(string: imageName) {
            cell.imageNameView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        } else {
            cell.imageNameView.image = UIImage(named: "placeholder") // Imagen por defecto
        }
        
        return cell
    }
}
