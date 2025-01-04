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
        return 1 // Example, only one row for the UICollectionView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeDataTableViewCell", for: indexPath) as? HomeDataTableViewCell else {
            return UITableViewCell()
        }
        
        // Pass data to the UICollectionView inside the cell
        cell.configurePopularProjects(popularProjects: popularProjects)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class HomeDataTableViewCell: UITableViewCell, UICollectionViewDelegate {
    
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





/*
// Segundo intento
import UIKit
import SDWebImage
import GoogleSignIn
import FirebaseAuth

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var logoutBtn: UIImageView!  // IBOutlet for the logout image
    @IBOutlet weak var HomeViewTable: UITableView!
    
    var popularProjects: [PopularProjects] = []
    var inspirations: [Inspiration] = []  // Array to store Inspiration data
    var categories: [Categories] = []  // Array to store Category data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the table
        HomeViewTable.delegate = self
        HomeViewTable.dataSource = self
        
        // Load services from all APIs
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
        // Fetch data for all APIs
        popularProjects = DataManager.shared.todosLosPopularProjects()
        inspirations = DataManager.shared.todasLasInspirations()
        categories = DataManager.shared.todasLasCategories()
        HomeViewTable.reloadData()
    }
    
    @objc func reloadTable() {
        loadServices()
    }
        
    // MARK: - UITableViewDataSource Methods
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 3 // One for each data type (PopularProjects, Inspirations, Categories)
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1 // Each section will contain one row to hold the collection view
        }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // Popular Projects Section
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeDataTableViewCell", for: indexPath) as? HomeDataTableViewCell else {
                return UITableViewCell()
            }
            cell.configurePopularProjects(popularProjects: popularProjects)
            return cell
        } else if indexPath.section == 1 {
            // Categories Section
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriesTableViewCell", for: indexPath) as? CategoriesTableViewCell else {
                return UITableViewCell()
            }
            cell.configureCategories(categories: categories)
            return cell
        } else {
            // Inspirations Section
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InspirationsTableViewCell", for: indexPath) as? InspirationsTableViewCell else {
                return UITableViewCell()
            }
            cell.configureInspirations(inspirations: inspirations)
            return cell
        }
    }

    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

/*
////// DESDE AQUÍ
class HomeDataTableViewCell: UITableViewCell, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView! // The UICollectionView inside the cell
    
    var popularProjects: [PopularProjects] = [] // Data for the UICollectionView
    var inspirations: [Inspiration] = []  // Data for the Inspiration collection
    var categories: [Categories] = []  // Data for the Category collection
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure the collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func configureData(popularProjects: [PopularProjects], inspirations: [Inspiration], categories: [Categories]) {
        self.popularProjects = popularProjects
        self.inspirations = inspirations
        self.categories = categories
        collectionView.reloadData()
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


/////// HASTA AQUí
*/

class HomeDataTableViewCell: UITableViewCell, UICollectionViewDelegate {
    
    @IBOutlet weak var homeDataCollectionView: UICollectionView! // The UICollectionView inside the cell
    
    var popularProjects: [PopularProjects] = [] // Data for the UICollectionView
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure the collectionView
        homeDataCollectionView.delegate = self
        homeDataCollectionView.dataSource = self
        
        // Register the UICollectionView cell
        //collectionView.register(UINib(nibName: "HomeDataCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeDataTableViewCell")
    }
    
    func configurePopularProjects(popularProjects: [PopularProjects]) {
        self.popularProjects = popularProjects
        homeDataCollectionView.reloadData()
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

        // Usar SDWebImage para cargar la imagen desde la URL
        if let imageName = popularProject.thumbnail, let url = URL(string: imageName) {
            cell.imageNameView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        } else {
            cell.imageNameView.image = UIImage(named: "placeholder") // Imagen por defecto
        }
        
        return cell
    }
}



class CategoriesTableViewCell: UITableViewCell, UICollectionViewDelegate {
    
    @IBOutlet weak var CategoriesCollectionView: UICollectionView! // The UICollectionView inside the cell
    
    var categories: [Categories] = [] // Data for the UICollectionView
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure the collectionView
        CategoriesCollectionView.delegate = self
        CategoriesCollectionView.dataSource = self
        
        // Register the UICollectionView cell
        //collectionView.register(UINib(nibName: "HomeDataCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeDataTableViewCell")
    }
    
    func configureCategories(categories: [Categories]) {
        self.categories = categories
        CategoriesCollectionView.reloadData()
    }
}

class CategoriesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageNameView: UIImageView!  // This is the UIImageView of the UICollectionView cell
    @IBOutlet weak var titleLabel: UILabel!  // This is the UILabel of the UICollectionView cell
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Additional setup if necessary
    }
}

// MARK: - UICollectionViewDataSource
extension CategoriesTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesTableViewCell", for: indexPath) as? CategoriesCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let category = categories[indexPath.item]
        cell.titleLabel.text = category.title

        // Usar SDWebImage para cargar la imagen desde la URL
        if let imageName = category.imageName, let url = URL(string: imageName) {
            cell.imageNameView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        } else {
            cell.imageNameView.image = UIImage(named: "placeholder") // Imagen por defecto
        }
        
        return cell
    }
}



class InspirationsTableViewCell: UITableViewCell, UICollectionViewDelegate {
    
    @IBOutlet weak var InspirationsCollectionView: UICollectionView! // The UICollectionView inside the cell
    
    var inspirations: [Inspiration] = [] // Data for the UICollectionView
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure the collectionView
        InspirationsCollectionView.delegate = self
        InspirationsCollectionView.dataSource = self
        
        // Register the UICollectionView cell
        //collectionView.register(UINib(nibName: "HomeDataCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeDataTableViewCell")
    }
    
    func configureInspirations(inspirations: [Inspiration]) {
        self.inspirations = inspirations
        InspirationsCollectionView.reloadData()
    }
}

class InspirationsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageNameView: UIImageView!  // This is the UIImageView of the UICollectionView cell
    @IBOutlet weak var titleLabel: UILabel!  // This is the UILabel of the UICollectionView cell
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Additional setup if necessary
    }
}

// MARK: - UICollectionViewDataSource
extension InspirationsTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inspirations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InspirationsTableViewCell", for: indexPath) as? InspirationsCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let inspiration = inspirations[indexPath.item]
        cell.titleLabel.text = inspiration.title

        // Usar SDWebImage para cargar la imagen desde la URL
        if let imageName = inspiration.imageName, let url = URL(string: imageName) {
            cell.imageNameView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        } else {
            cell.imageNameView.image = UIImage(named: "placeholder") // Imagen por defecto
        }
        
        return cell
    }
}
*/
