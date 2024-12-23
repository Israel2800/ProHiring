//
//  LoginViewController.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 12/16/24.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var accountField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createNewAccount: UIButton!
    @IBOutlet weak var forgotPassword: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuración de botones (opcional)
        loginButton.layer.cornerRadius = 8
        createNewAccount.layer.cornerRadius = 8
    }

    // IBAction para crear una cuenta
    @IBAction func createAccountTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "CreateAccountSegue", sender: nil)
    }

    // IBAction para iniciar sesión
    @IBAction func loginTapped(_ sender: UIButton) {
        guard let email = accountField.text, isValidEmail(email),
              let password = passwordField.text, isValidPassword(password) else {
            showAlert(message: "Por favor, ingresa un correo y contraseña válidos.")
            return
        }
        
        // Iniciar sesión en Firebase Authentication
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(message: "Error al iniciar sesión: \(error.localizedDescription)")
                return
            }
            
            self.showAlert(message: "Inicio de sesión exitoso.")
        }
    }

    // IBAction para recuperación de contraseña
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        guard let email = accountField.text, isValidEmail(email) else {
            showAlert(message: "Por favor, ingresa un correo válido para recuperar la contraseña.")
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

    // MARK: - Validación de correo y contraseña
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)[A-Za-z\\d@$!%*?&#]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    // MARK: - Mostrar alertas
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Información", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
