//
//  UserSettingsViewController.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 2/16/25.
//

import UIKit
import FirebaseAuth

class CompanySettingsViewController: UIViewController {

    @IBOutlet weak var deleteAccountBtn: UIButton!
    @IBOutlet weak var userLabel: UILabel!
    var currentUserID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deleteAccountBtn.layer.cornerRadius = 10
        deleteAccountBtn.clipsToBounds = true
        
        currentUserID = Auth.auth().currentUser?.uid
        
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
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            user?.delete(completion: { error in
                if let error = error {
                    print("Error trying to delete account: \(error.localizedDescription)")
                    self.showErrorAlert(message: error.localizedDescription)
                } else {
                    print("Account has been successfully deleted.")
                    self.logoutAndRedirect()
                }
            })
        }))
        
        present(alert, animated: true, completion: nil)
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
