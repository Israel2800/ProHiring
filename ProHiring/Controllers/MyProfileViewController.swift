//
//  MyProfileViewController.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 1/2/25.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class MyProfileViewController: UIViewController {

    
    @IBOutlet weak var logoutBtn: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var servicesLabel: UILabel!
    @IBOutlet weak var socialMediaLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!


    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCompanyData()

        // Do any additional setup after loading the view.
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
                self.nameLabel.text = data["name"] as? String
                self.companyNameLabel.text = data["companyName"] as? String
                self.servicesLabel.text = data["services"] as? String
                self.socialMediaLabel.text = data["socialMedia"] as? String
                self.contactLabel.text = data["contact"] as? String
                if let logoURL = data["logoURL"] as? String {
                    self.loadLogoImage(from: logoURL)
                }
            }
        
        
        
        
        }

        private func loadLogoImage(from url: String) {
            let storageRef = Storage.storage().reference(forURL: url)
            storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                if let data = data, let image = UIImage(data: data) {
                    self.logoImageView.image = image
                }
            }
        }

    
}
