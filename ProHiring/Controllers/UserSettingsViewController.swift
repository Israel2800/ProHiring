//
//  UserSettingsViewController.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 2/16/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class UserSettingsViewController: UIViewController {

    @IBOutlet weak var deleteAccountBtn: UIButton!
    @IBOutlet weak var userLabel: UILabel!
    var currentUserID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deleteAccountBtn.layer.cornerRadius = 8
        deleteAccountBtn.clipsToBounds = true
        
        currentUserID = Auth.auth().currentUser?.uid
        
        // Mostrar el correo electrónico del usuario en el label
        if let user = Auth.auth().currentUser?.email {
            userLabel.text = user
        }
    }
    
    @IBAction func deleteAccountTapped(_ sender: UIButton) {
        let user = Auth.auth().currentUser
        guard let email = user?.email else { return }
        let alertMessage = "Are you sure you want to delete your account (\(email))? This action cannot be undone."
        
        let alert = UIAlertController(title: "Delete Account",
                                      message: alertMessage,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteUserDataAndAccount(user: user)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func deleteUserDataAndAccount(user: User?) {
        guard let userID = user?.uid else { return }
        
        // Obtener la referencia a Firestore
        let db = Firestore.firestore()
        
        // Eliminar servicios asociados con el usuario
        db.collection("users").document(userID).collection("services").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching services: \(error.localizedDescription)")
                return
            }
            
            // Eliminar cada servicio asociado con el usuario
            for document in snapshot!.documents {
                document.reference.delete { error in
                    if let error = error {
                        print("Error deleting service: \(error.localizedDescription)")
                    } else {
                        print("Service deleted successfully")
                    }
                }
            }
            
            // Eliminar usuario y collection de usuario
            self.deleteUserAdditionalData(user: user)
        }
        
    }
    
    // Función para eliminar otros datos del usuario (si existen)
    private func deleteUserAdditionalData(user: User?) {
        guard let userID = user?.uid else { return }
         
         // Eliminar los datos del usuario en Firestore
         let db = Firestore.firestore()
         db.collection("users").document(userID).delete { error in
             if let error = error {
                 print("Error deleting user data from Firestore: \(error.localizedDescription)")
                 self.showErrorAlert(message: error.localizedDescription)
             } else {
                 print("User data successfully deleted from Firestore.")
                 
                 // Ahora eliminamos la cuenta de Firebase Authentication
                 user?.delete(completion: { error in
                     if let error = error {
                         print("Error trying to delete account: \(error.localizedDescription)")
                         self.showErrorAlert(message: error.localizedDescription)
                     } else {
                         print("Account has been successfully deleted.")
                         self.logoutAndRedirect()
                     }
                 })
             }
         }
    }
    
    func logoutAndRedirect() {
        do {
            try Auth.auth().signOut()
            if let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
                loginVC.modalPresentationStyle = .fullScreen
                present(loginVC, animated: true, completion: nil)
            }
        } catch let signOutError {
            print("Error trying to log out: \(signOutError.localizedDescription)")
        }
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
