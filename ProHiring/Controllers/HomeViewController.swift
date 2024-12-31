//
//  HomeViewController.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 12/17/24.
//

/*
import UIKit
import FirebaseAuth
import GoogleSignIn

class HomeViewController: UIViewController {
    
    @IBOutlet weak var HomeTableView: UITableView!
    @IBOutlet weak var logoutBtn: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Habilitar interacción con el UIImageView
        logoutBtn.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(logout))
        logoutBtn.addGestureRecognizer(tapGesture)
        
        HomeTableView.delegate = self
        HomeTableView.dataSource = self
        
        /*
        HomeTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell1")
        HomeTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell2")
        HomeTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell3")
        */
         
  
        print("Categories: \(HomeData.categories.count)")
        print("Popular Projects: \(HomeData.popularProjects.count)")
        print("Inspirations: \(HomeData.inspirations)")
        
        // Recargar la tabla
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



}


// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as? Cell1 else {
                return UITableViewCell()
            }
            cell.categoryCollectionView.delegate = self
            cell.categoryCollectionView.dataSource = self
            cell.categoryCollectionView.reloadData()
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as? Cell2 else {
                return UITableViewCell()
            }
            cell.projectCollectionView.delegate = self
            cell.projectCollectionView.dataSource = self
            cell.projectCollectionView.reloadData()
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell3", for: indexPath) as? Cell3 else {
                return UITableViewCell()
            }
            cell.inspirationCollectionView.delegate = self
            cell.inspirationCollectionView.dataSource = self
            cell.inspirationCollectionView.reloadData()
            return cell
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Este método se puede dejar vacío si no se necesita manejar la selección de filas en la tabla
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case let view where view == (view.superview as? Cell1)?.categoryCollectionView:
            return HomeData.categories.count
        case let view where view == (view.superview as? Cell2)?.projectCollectionView:
            return HomeData.popularProjects.count
        case let view where view == (view.superview as? Cell3)?.inspirationCollectionView:
            return HomeData.inspirations.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case let view where view == (view.superview as? Cell1)?.categoryCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell1", for: indexPath) as! CategoryCell
            let category = HomeData.categories[indexPath.row]
            
            // Verificar si están cargando los datos:
            print("Configurando celda para categoría: \(category.title), imagen: \(category.imageName)")
            print("No se pasan los datos ):")

            cell.configure(with: category)
            return cell
        case let view where view == (view.superview as? Cell2)?.projectCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell2", for: indexPath) as! ProjectCell
            let project = HomeData.popularProjects[indexPath.row]
            cell.configure(with: project)
            return cell
        case let view where view == (view.superview as? Cell3)?.inspirationCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell3", for: indexPath) as! InspirationCell
            let inspiration = HomeData.inspirations[indexPath.row]
            cell.configure(with: inspiration)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var destinationVC: UIViewController?
        switch collectionView {
        case let view where view == (view.superview as? Cell1)?.categoryCollectionView:
            let category = HomeData.categories[indexPath.row]
            destinationVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: category.destinationView)
        case let view where view == (view.superview as? Cell2)?.projectCollectionView:
            let project = HomeData.popularProjects[indexPath.row]
            destinationVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: project.destinationView)
        case let view where view == (view.superview as? Cell3)?.inspirationCollectionView:
            let inspiration = HomeData.inspirations[indexPath.row]
            destinationVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: inspiration.destinationView)
        default:
            break
        }
        
        if let vc = destinationVC {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case let view where view == (view.superview as? Cell1)?.categoryCollectionView:
            return CGSize(width: 120, height: 150) // Ajusta según tu diseño
        case let view where view == (view.superview as? Cell2)?.projectCollectionView:
            return CGSize(width: 150, height: 200) // Ajusta según tu diseño
        case let view where view == (view.superview as? Cell3)?.inspirationCollectionView:
            return CGSize(width: 180, height: 250) // Ajusta según tu diseño
        default:
            return CGSize.zero
        }
    }

}


// Clases para las celdas personalizadas

class Cell1: UITableViewCell {
    @IBOutlet weak var categoryCollectionView: UICollectionView!
}

class Cell2: UITableViewCell {
    @IBOutlet weak var projectCollectionView: UICollectionView!
}

class Cell3: UITableViewCell {
    @IBOutlet weak var inspirationCollectionView: UICollectionView!
}

class CategoryCell: UICollectionViewCell {
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    
    func configure(with category: Category) {
        categoryImageView.image = UIImage(named: category.imageName)
        categoryTitleLabel.text = category.title
    }
}

class ProjectCell: UICollectionViewCell {
    @IBOutlet weak var projectImageView: UIImageView!
    @IBOutlet weak var projectTitleLabel: UILabel!
    @IBOutlet weak var projectPriceLabel: UILabel!
    
    func configure(with project: Project) {
        projectImageView.image = UIImage(named: project.imageName)
        projectTitleLabel.text = project.title
        projectPriceLabel.text = project.price
    }
}

class InspirationCell: UICollectionViewCell {
    @IBOutlet weak var inspirationImageView: UIImageView!
    @IBOutlet weak var inspirationDescriptionLabel: UILabel!
    @IBOutlet weak var inspirationButton: UIButton!

    private var destinationView: String?

    func configure(with inspiration: Inspiration) {
        inspirationImageView.image = UIImage(named: inspiration.imageName)
        inspirationDescriptionLabel.text = inspiration.description
        inspirationButton.setTitle(inspiration.buttonTitle, for: .normal)
        destinationView = inspiration.destinationView
    }

    @IBAction func inspirationButtonTapped(_ sender: UIButton) {
        if let destination = destinationView {
            NotificationCenter.default.post(name: Notification.Name("NavigateToView"), object: destination)
        }
    }
}
*/



/*
 INTENTO FINAL 2
 
import UIKit
import FirebaseAuth
import GoogleSignIn

class HomeViewController: UIViewController {
    
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var logoutBtn: UIImageView!  // IBOutlet para la imagen de cierre de sesión
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Habilitar interacción con el UIImageView
        logoutBtn.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(logout))
        logoutBtn.addGestureRecognizer(tapGesture)
        
        homeTableView.delegate = self
        homeTableView.dataSource = self
        
        // Recargar la tabla
        homeTableView.reloadData()
        
       
        
        
        // Verificar datos cargados
        print("Categories: \(HomeData.categories.count)")
        print("Popular Projects: \(HomeData.popularProjects.count)")
        print("Inspirations: \(HomeData.inspirations.count)")
    }
    
    @objc func logout() {
        let alert = UIAlertController(title: "Cerrar Sesión", message: "¿Está seguro de que desea cerrar sesión?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Cerrar Sesión", style: .destructive) { _ in
            // Eliminar valores de UserDefaults
            let ud = UserDefaults.standard
            ud.removeObject(forKey: "customLogin")
            ud.removeObject(forKey: "userEmail")
            ud.synchronize()
            
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
}



extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 // Cell1, Cell2, Cell3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! Cell1
            cell.collectionView.dataSource = self
            cell.collectionView.delegate = self
            cell.collectionView.tag = 0
            cell.collectionView.reloadData()
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! Cell2
            cell.collectionView.dataSource = self
            cell.collectionView.delegate = self
            cell.collectionView.tag = 1
            cell.collectionView.reloadData()
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell3", for: indexPath) as! Cell3
            cell.collectionView.dataSource = self
            cell.collectionView.delegate = self
            cell.collectionView.tag = 2
            cell.collectionView.reloadData()
            return cell
        default:
            fatalError("Unexpected row")
        }
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    /*func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 0:
            return HomeData.categories.count
        case 1:
            return HomeData.popularProjects.count
        case 2:
            return HomeData.inspirations.count
        default:
            return 0
        }
    }*/
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 0:
            return HomeData.categories.isEmpty ? 0 : HomeData.categories.count
        case 1:
            return HomeData.popularProjects.isEmpty ? 0 : HomeData.popularProjects.count
        case 2:
            return HomeData.inspirations.isEmpty ? 0 : HomeData.inspirations.count
        default:
            return 0
        }
    }

    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
            let data = HomeData.categories[indexPath.row]
            cell.titleLabel.text = data.title
            cell.imageView.image = UIImage(named: data.imageName)
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProjectCollectionViewCell", for: indexPath) as! ProjectCollectionViewCell
            let data = HomeData.popularProjects[indexPath.row]
            cell.titleLabel.text = data.title
            cell.priceLabel.text = data.price
            cell.imageView.image = UIImage(named: data.imageName)
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InspirationCollectionViewCell", for: indexPath) as! InspirationCollectionViewCell
            let data = HomeData.inspirations[indexPath.row]
            cell.descriptionLabel.text = data.description
            cell.imageView.image = UIImage(named: data.imageName)
            cell.actionButton.setTitle(data.buttonTitle, for: .normal)
            return cell
        default:
            fatalError("Unexpected tag")
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var destinationVC: UIViewController?
        switch collectionView.tag {
        case 0:
            let data = HomeData.categories[indexPath.row]
            destinationVC = storyboard?.instantiateViewController(withIdentifier: data.destinationView)
        case 1:
            let data = HomeData.popularProjects[indexPath.row]
            destinationVC = storyboard?.instantiateViewController(withIdentifier: data.destinationView)
        case 2:
            let data = HomeData.inspirations[indexPath.row]
            destinationVC = storyboard?.instantiateViewController(withIdentifier: data.destinationView)
        default:
            break
        }
        if let destinationVC = destinationVC {
            navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
}


class Cell1: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
}

class Cell2: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
}

class Cell3: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
}


class CategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}

class ProjectCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
}

class InspirationCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
}
*/




/*
// WITH API
import UIKit
import FirebaseAuth
import GoogleSignIn
import SDWebImage


class HomeViewController: UIViewController {

    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var logoutBtn: UIImageView!  // IBOutlet para la imagen de cierre de sesión
    
    var categories: [HomeData] = []
    //var popularProjects: [PopularProject] = []
    //var inspirations: [Inspiration] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        homeTableView.delegate = self
        homeTableView.dataSource = self

        
        //homeTableView.register(UINib(nibName: "CategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryTableViewCell")
        //homeTableView.register(UINib(nibName: "PopularProjectTableViewCell", bundle: nil), forCellReuseIdentifier: "PopularProjectTableViewCell")
        //homeTableView.register(UINib(nibName: "InspirationTableViewCell", bundle: nil), forCellReuseIdentifier: "InspirationTableViewCell")

        // Habilitar interacción con el UIImageView
        logoutBtn.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(logout))
        logoutBtn.addGestureRecognizer(tapGesture)

        // Cargar datos desde DataManager
        loadData()
        print(categories)

    }

    func loadData() {
        categories = DataManager.shared.todasLasCategorias()
        //popularProjects = DataManager.shared.todosLosProyectosPopulares()
        //inspirations = DataManager.shared.todasLasInspiraciones()
        homeTableView.reloadData()
        print(categories)

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
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 // Una sección para cada tipo de datos
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // Cada sección tiene una sola fila
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell", for: indexPath) as! CategoryTableViewCell
            cell.configure(with: categories)
            return cell
        /*case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PopularProjectTableViewCell", for: indexPath) as! PopularProjectTableViewCell
            cell.configure(with: popularProjects)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InspirationTableViewCell", for: indexPath) as! InspirationTableViewCell
            cell.configure(with: inspirations)
            return cell*/
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200 // Altura personalizada para cada fila
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Categories"
        case 1: return "Popular Projects"
        case 2: return "Inspirations"
        default: return nil
        }
    }
}


class CategoryTableViewCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!

    private var categories: [HomeData] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        }
    
    func configure(with categories: [HomeData]) {
        self.categories = categories
        collectionView.reloadData()
    }
}

extension CategoryTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
        cell.configure(with: categories[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 200) // Tamaño de cada celda
    }
}

class CategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    func configure(with category: HomeData) {
            titleLabel.text = category.title
            
            // Usar SDWebImage para cargar la imagen
            if let imageName = category.imageName, let url = URL(string: imageName) {
                imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
            } else {
                imageView.image = UIImage(named: "placeholder") // Imagen por defecto si no hay URL válida
            }
        }
}
*/



import UIKit
import SDWebImage

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
