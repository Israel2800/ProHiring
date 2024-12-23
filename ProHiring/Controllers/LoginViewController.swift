//
//  LoginViewController.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 12/16/24.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices

class LoginViewController: UIViewController, ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
  
    
    @IBOutlet weak var accountField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createNewAccount: UIButton!
    @IBOutlet weak var forgotPassword: UIButton!

    let actInd = UIActivityIndicatorView(style: .large)
    private var googleSignInConfig: GIDConfiguration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configuración de botones (opcional)
        loginButton.layer.cornerRadius = 8
        createNewAccount.layer.cornerRadius = 8
        
        accountField.placeholder = "Email"
        passwordField.placeholder = "Password"
        
        // Configurar el campo de contraseña para usar asteriscos
        passwordField.isSecureTextEntry = true
        
        // Añadir el botón del ojito al campo de contraseña
        let eyeButton = UIButton(type: .custom)
        eyeButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        eyeButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .selected)
        eyeButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        eyeButton.tintColor = .gray
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        passwordField.rightView = eyeButton
        passwordField.rightViewMode = .always
    }
    
    // Función para alternar la visibilidad del texto de la contraseña
    @objc func togglePasswordVisibility(_ sender: UIButton) {
        sender.isSelected.toggle() // Cambia el estado seleccionado del botón
        passwordField.isSecureTextEntry.toggle() // Alterna la visibilidad del texto
        
        // Evita que el cursor salte al final al alternar
        if let existingText = passwordField.text, passwordField.isSecureTextEntry {
            passwordField.deleteBackward() // Borra el último carácter
            passwordField.insertText(existingText) // Restaura el texto
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Detectar la conexión a internet
        if isInternetAvailable() {
            print("Sí hay conexión a internet")
        } else {
            showMessage("No hay conexión a Internet.")
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    
    func showActivityIndicator() {
        actInd.center = self.view.center
        self.view.addSubview(actInd)
        actInd.startAnimating()
    }
    
    func hideActivityIndicator() {
        actInd.stopAnimating()
        actInd.removeFromSuperview()
    }
    
    func isInternetAvailable() -> Bool {
        return NetworkReachability.shared.isConnected
    }
    
    
    
    
    
    @IBAction func loginTapped(_ sender: UIButton) {
        guard let email = accountField.text, isValidEmail(email),
              let password = passwordField.text, isValidPassword(password) else {
            showAlert(message: "Por favor, ingresa un correo y contraseña válidos.")
            return
        }
        
        FirebaseAuthManager.authenticateUser(email: email, password: password, provider: .email, viewController: self) { success in
            if success {
                // Sesión iniciada con éxito
                //self.performSegue(withIdentifier: "loginOK", sender: nil)
            }
        }
        

    }
    
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

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Información", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // IBAction para iniciar sesión con Google
    @IBAction func signInWithGoogleTapped(_ sender: UIButton) {
        if !isInternetAvailable() {
            showMessage("No hay conexión a Internet.")
            return
        }
        showActivityIndicator()
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            self.hideActivityIndicator()
            if let error = error {
                self.showMessage("Error al iniciar sesión con Google: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user, let idToken = user.idToken?.tokenString else { return }
            let accessToken = user.accessToken.tokenString
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.showMessage("Error al autenticar con Firebase: \(error.localizedDescription)")
                    return
                }
                self.performSegue(withIdentifier: "loginOK", sender: nil)
            }
        }
    }
    
    // IBAction para iniciar sesión con Apple ID
    @IBAction func signInWithAppleTapped(_ sender: UIButton) {
        if !isInternetAvailable() {
            showMessage("No hay conexión a Internet.")
            return
        }
        
        showActivityIndicator()
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.presentationContextProvider = self
        authController.delegate = self
        authController.performRequests()
    }
    
    // Mostrar mensajes
    private func showMessage(_ message: String) {
        let alert = UIAlertController(title: "Información", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
    
    

