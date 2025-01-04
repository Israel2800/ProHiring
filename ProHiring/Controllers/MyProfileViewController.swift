//
//  MyProfileTableViewController.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 1/2/25.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class MyProfileViewController: UITableViewController {
    
    @IBOutlet weak var logoutBtn: UIImageView! // IBOutlet para el botón de logout en la vista del storyboard
    
    var profileData: [String: Any] = [:] // Diccionario para almacenar los datos del perfil
    var logoImage: UIImage? // Imagen del logo cargada desde Firebase Storage

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCompanyData()

        // Habilitar interacción con el UIImageView
        logoutBtn.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(logout))
        logoutBtn.addGestureRecognizer(tapGesture)
    }

    @objc func logout() {
        let alert = UIAlertController(title: "Cerrar Sesión", message: "¿Está seguro de que desea cerrar sesión?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Cerrar Sesión", style: .destructive) { _ in
            // Limpiar UserDefaults
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "loggedInUserUID")
            defaults.removeObject(forKey: "loggedInUserType")
            defaults.synchronize()

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

    private func loadCompanyData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("companies").document(userID).getDocument { document, error in
            if let error = error {
                print("Error al cargar datos: \(error.localizedDescription)")
                return
            }
            guard let data = document?.data() else { return }
            self.profileData = data
            if let logoURL = data["logoURL"] as? String {
                self.loadLogoImage(from: logoURL)
            }
            self.tableView.reloadData()
        }
    }

    private func loadLogoImage(from url: String) {
        let storageRef = Storage.storage().reference(forURL: url)
        storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let data = data, let image = UIImage(data: data) {
                self.logoImage = image
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // Solo una celda (Cell1) para mostrar todos los elementos
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! ProfileCell
        
        // Configurar los elementos de la celda
        cell.nameLabel.text = profileData["name"] as? String
        cell.servicesLabel.text = profileData["services"] as? String
        cell.socialMediaLabel.text = profileData["socialMedia"] as? String
        cell.contactLabel.text = profileData["contact"] as? String
        if let logoImage = self.logoImage {
            cell.logoImageView.image = logoImage
        }

        return cell
    }
}

// MARK: - Clase para la celda personalizada
class ProfileCell: UITableViewCell {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var servicesLabel: UILabel!
    @IBOutlet weak var socialMediaLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
}
