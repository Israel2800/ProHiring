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


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HomeDataTableViewCellDelegate {
    
    func didSelectPopularProject(withId id: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let detailVC = storyboard.instantiateViewController(withIdentifier: "PopularProjectsDetailsViewController") as? PopularProjectsDetailsViewController {
                detailVC.serviceId = id
                navigationController?.pushViewController(detailVC, animated: true)
            }
    }
    

    
    @IBOutlet weak var logoutBtn: UIImageView!  // IBOutlet for the logout image
    @IBOutlet weak var HomeViewTable: UITableView!
    
    var popularProjects: [PopularProjects] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the table
        HomeViewTable.delegate = self
        HomeViewTable.dataSource = self
        
        // Load services
        loadServices()
        
        // Listen for notifications to reload the table
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name("BD_LISTA_PopularProjects"), object: nil)
        
        // Enable interaction with the UIImageView
        logoutBtn.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(logout))
        logoutBtn.addGestureRecognizer(tapGesture)
    }
    
    @objc func logout() {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            let ud = UserDefaults.standard
            ud.removeObject(forKey: "customLogin")
            ud.removeObject(forKey: "userEmail")
            ud.synchronize()

            GIDSignIn.sharedInstance.signOut()

            do {
                try Auth.auth().signOut()
            } catch {
                print("Error logging out of Firebase: \(error.localizedDescription)")
            }

            if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true)
            }
        })

        present(alert, animated: true)
    }
    
    func loadServices() {
        popularProjects = DataManager.shared.todosLosPopularProjects()
        HomeViewTable.reloadData()
    }
    
    @objc func reloadTable() {
        loadServices()
    }
    
    // MARK: - UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeDataTableViewCell", for: indexPath) as? HomeDataTableViewCell else {
            return UITableViewCell()
        }
        
        cell.delegate = self // Set the delegate

        // Pass data to the UICollectionView inside the cell
        cell.configurePopularProjects(popularProjects: popularProjects)
        
        //cell.delegate = self // Set the delegate

        
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
            
        /*
            // Obtener el servicio seleccionado
            let selectedService = popularProjects[indexPath.row]
            
            // Cargar el storyboard y crear el controlador
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let detailVC = storyboard.instantiateViewController(withIdentifier: "PopularProjectsDetailsViewController") as? PopularProjectsDetailsViewController else { return }
            
            // Pasar el ID al controlador de detalle
            detailVC.serviceId = selectedService.id
            
            // Navegar al controlador de detalle
            navigationController?.pushViewController(detailVC, animated: true)
         */
    }
}

class HomeDataTableViewCell: UITableViewCell, UICollectionViewDelegate {
    
    weak var delegate: HomeDataTableViewCellDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView! // The UICollectionView inside the cell
    
    var popularProjects: [PopularProjects] = [] // Data for the UICollectionView
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure the collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register the UICollectionView cell
        //collectionView.register(UINib(nibName: "HomeDataCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeDataTableViewCell")
    }
    
    func configurePopularProjects(popularProjects: [PopularProjects]) {
        self.popularProjects = popularProjects
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedProject = popularProjects[indexPath.item]
        // Validar que el ID no sea nulo o vacío
         if let id = selectedProject.id, !id.isEmpty {
             delegate?.didSelectPopularProject(withId: id)
         } else {
             print("Error: El ID del proyecto es nulo o vacío.")
         }
        print("Selected item at index: \(indexPath.item), ID: \(selectedProject.id ?? "No ID")")

    }
}

class HomeDataCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageNameView: UIImageView!  // This is the UIImageView of the UICollectionView cell
    @IBOutlet weak var titleLabel: UILabel!  // This is the UILabel of the UICollectionView cell
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Additional setup if necessary
    }
}


// MARK: - UICollectionViewDataSource
extension HomeDataTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularProjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeDataTableViewCell", for: indexPath) as? HomeDataCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let popularProject = popularProjects[indexPath.item]
        cell.titleLabel.text = popularProject.title

        // Use SDWebImage to load the image from the URL
        if let imageName = popularProject.thumbnail, let url = URL(string: imageName) {
            cell.imageNameView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        } else {
            cell.imageNameView.image = UIImage(named: "placeholder") // Default image
        }
        
        return cell
    }
}


protocol HomeDataTableViewCellDelegate: AnyObject {
    func didSelectPopularProject(withId id: String)
}


