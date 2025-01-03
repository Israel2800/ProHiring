//
//  MyProfileViewController.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 1/2/25.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

class MyProfileViewController: UIViewController {

    @IBOutlet weak var logoutBtn: UIImageView!  // IBOutlet para la imagen de cierre de sesión
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
    


}
