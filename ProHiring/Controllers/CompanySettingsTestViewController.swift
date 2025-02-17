//
//  CompanySettingsViewController.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 2/16/25.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class CompanySettingsTestViewController: UIViewController {
    
    @IBOutlet weak var deleteAccountBtn: UIButton!
    @IBOutlet weak var userLabel: UILabel!
    var currentUserID: String?
    var logoImageURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deleteAccountBtn.layer.cornerRadius = 10
        deleteAccountBtn.clipsToBounds = true
        
        currentUserID = Auth.auth().currentUser?.uid
        
        // Fetch and display the company name from Firestore
        if let userID = currentUserID {
            let db = Firestore.firestore()
            db.collection("companies").document(userID).getDocument { document, error in
                if let error = error {
                    print("Error fetching company data: \(error.localizedDescription)")
                } else if let document = document, document.exists {
                    let companyName = document.data()?["companyName"] as? String ?? "Company Name Not Found"
                    self.userLabel.text = companyName
                    
                    // Supongamos que la URL de la imagen del logo está en el campo "logoImageURL"
                    self.logoImageURL = document.data()?["logoImageURL"] as? String
                } else {
                    self.userLabel.text = "Company Not Found"
                }
            }
        }
    }
    
    @IBAction func deleteAccountTapped(_ sender: UIButton) {
        let user = Auth.auth().currentUser
        guard let email = user?.email else { return }
        let alertMessage = "Are you sure you want to delete your account (\(email))? This action cannot be undone."
        
        let alert = UIAlertController(title: "Delete Account", message: alertMessage, preferredStyle: .alert)
        
        // Botón de confirmación
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteCompanyData()
        }))
        
        // Botón de cancelación
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }

    func deleteCompanyData() {
        guard let currentUserID = currentUserID else { return }
        
        // Primero, eliminamos el logo de Firebase Storage
        if let logoURL = logoImageURL, !logoURL.isEmpty {
            let storageRef = Storage.storage().reference(forURL: logoURL)
            storageRef.delete { error in
                if let error = error {
                    print("Error deleting logo from storage: \(error.localizedDescription)")
                } else {
                    print("Logo deleted successfully.")
                }
            }
        } else {
            print("Logo URL is empty or invalid.")
        }

        
        // Luego, eliminamos los datos de la empresa en Firestore
        let db = Firestore.firestore()
        db.collection("companies").document(currentUserID).delete { error in
            if let error = error {
                print("Error deleting company data from Firestore: \(error.localizedDescription)")
            } else {
                print("Company data deleted successfully.")
            }
        }
        
        // Finalmente, eliminamos la cuenta de usuario de Firebase Authentication
        Auth.auth().currentUser?.delete { error in
            if let error = error {
                print("Error deleting user account: \(error.localizedDescription)")
            } else {
                print("User account deleted successfully.")
                // Redirigir al usuario a una pantalla de confirmación o cerrar sesión
                self.navigateToLoginScreen()
            }
        }
    }

    func navigateToLoginScreen() {
        // Redirigir al usuario a la pantalla de inicio de sesión después de eliminar la cuenta
        DispatchQueue.main.async {
            if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true, completion: nil)
            }
        }
    }

}
