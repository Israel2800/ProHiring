//
//  CompanySettingsViewController.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 2/16/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class CompanySettingsViewController: UIViewController {
    
    @IBOutlet weak var deleteAccountButton: UIButton!
    @IBOutlet weak var userLabel: UILabel!
    
    var currentUserID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deleteAccountButton.layer.cornerRadius = 8
        deleteAccountButton.clipsToBounds = true
        
        currentUserID = Auth.auth().currentUser?.uid
        
        if let userID = currentUserID {
            let db = Firestore.firestore()
            db.collection("companies").document(userID)
                .getDocument { document, error in
                    if let error = error {
                        print("Error fetching company data: \(error.localizedDescription)")
                    } else if let document = document, document.exists {
                        let companyName = document.data()?["companyName"] as? String ?? "Company Name Not Found"
                        self.userLabel.text = companyName
                    } else {
                        self.userLabel.text = "Company Not Found"
                    }
                }
        }
    }
    
    @IBAction func deleteAccountTapped(_ sender: UIButton) {
        guard let user = Auth.auth().currentUser else {
            showMessage("The account has been already deleted.")
            return
        }
        guard let email = user.email else { return }
        
        let alertMessage = "Are you sure you want to delete your account (\(email))? This action cannot be undone."
        
        let alert = UIAlertController(title: "Delete Account", message: alertMessage, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteAccount(user: user)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func deleteAccount(user: User) {
        let userID = user.uid
        let db = Firestore.firestore()
        let storageRef = Storage.storage().reference().child("logos/\(userID).jpg")
        let companyDocRef = db.collection("companies").document(userID)
        
        // Eliminar el documento de Firestore
        companyDocRef.delete { error in
            if let error = error {
                self.showMessage("Error deleting company data: \(error.localizedDescription)")
                return
            }
            
            // Eliminar la imagen de Firebase Storage
            storageRef.delete { error in
                if let error = error {
                    print("Error deleting logo from Storage: \(error.localizedDescription)")
                }
                
                // Eliminar el usuario de Firebase Authentication
                user.delete { error in
                    if let error = error {
                        self.showMessage("Error deleting user account: \(error.localizedDescription)")
                        return
                    }
                    
                    self.showMessage("Account has been successfully deleted.")
                    self.navigateToLoginScreen()
                }
            }
        }
    }
    
    func navigateToLoginScreen() {
        do {
            try Auth.auth().signOut()
            
            // Desaparecer el controlador actual
            self.dismiss(animated: false, completion: {
                if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
                    loginVC.modalPresentationStyle = .fullScreen
                    self.present(loginVC, animated: true, completion: nil)
                }
            })
        } catch let signOutError {
            print("Error trying to log out: \(signOutError.localizedDescription)")
        }
    }

    
    func showMessage(_ message: String) {
        let alert = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
