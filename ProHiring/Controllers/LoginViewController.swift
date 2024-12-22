//
//  LoginViewController.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 12/16/24.
//

import Foundation
import UIKit

class LoginViewController : UIViewController{
    
    // IBOutlets para los elementos del Storyboard
        @IBOutlet weak var accountField: UITextField!
        @IBOutlet weak var passwordField: UITextField!
        @IBOutlet weak var loginButton: UIButton!
        @IBOutlet weak var createNewAccount: UIButton!
        @IBOutlet weak var forgotPassword: UIButton!

        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Opcional: Configurar apariencia de los botones
            loginButton.layer.cornerRadius = 8
            createNewAccount.layer.cornerRadius = 8
        }

        // IBAction para el botón de registro
        @IBAction func createAccountTapped(_ sender: UIButton) {
            guard let email = accountField.text, !email.isEmpty,
                  let password = passwordField.text, !password.isEmpty else {
                showAlert(message: "Por favor, ingresa un correo y una contraseña.")
                return
            }
            
            // Crear cuenta en Firebase Authentication
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    self.showAlert(message: "Error al crear la cuenta: \(error.localizedDescription)")
                    return
                }
                
                self.showAlert(message: "Cuenta creada exitosamente. Ahora puedes iniciar sesión.")
            }
        }

        // IBAction para el botón de iniciar sesión
        @IBAction func loginTapped(_ sender: UIButton) {
            guard let email = accountField.text, !email.isEmpty,
                  let password = passwordField.text, !password.isEmpty else {
                showAlert(message: "Por favor, ingresa un correo y una contraseña.")
                return
            }
            
            // Iniciar sesión con Firebase Authentication
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    self.showAlert(message: "Error al iniciar sesión: \(error.localizedDescription)")
                    return
                }
                
                self.showAlert(message: "Inicio de sesión exitoso.")
                // Aquí podrías navegar a la siguiente vista
            }
        }

        // IBAction para el botón de recuperación de contraseña
        @IBAction func forgotPasswordTapped(_ sender: UIButton) {
            guard let email = accountField.text, !email.isEmpty else {
                showAlert(message: "Por favor, ingresa tu correo para recuperar la contraseña.")
                return
            }
            
            // Recuperar contraseña con Firebase Authentication
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    self.showAlert(message: "Error al enviar el correo de recuperación: \(error.localizedDescription)")
                    return
                }
                
                self.showAlert(message: "Correo de recuperación enviado. Revisa tu bandeja de entrada.")
            }
        }

        // Método para mostrar alertas
        private func showAlert(message: String) {
            let alert = UIAlertController(title: "Información", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    
}
