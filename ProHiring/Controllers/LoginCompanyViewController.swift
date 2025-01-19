//
//  LoginCompanyViewController.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 1/2/25.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import FirebaseCore
import FirebaseFirestore

class LoginCompanyViewController: UIViewController, ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
    
    @IBOutlet weak var accountField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPassword: UIButton!
    @IBOutlet weak var createNewAccount: UIButton!
    
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
        
        // Configuración de Google Sign-In
        if let clientID = FirebaseApp.app()?.options.clientID {
            googleSignInConfig = GIDConfiguration(clientID: clientID)
        } else {
            showMessage("The Google clientID was not found.")
        }
        
        // Agregar gesture recognizer para ocultar el teclado al tocar fuera
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard() {
       view.endEditing(true) // Oculta el teclado para todos los campos
    }
    
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
            print("There is an internet connection.")
        } else {
            showMessage("There is no internet connection.")
        }
        
        // Verificar si el usuario ya está autenticado
        /*if let user = Auth.auth().currentUser {
            self.checkUserTypeAndNavigate(user: user)
        }
        */
        if let userUID = UserDefaults.standard.string(forKey: "loggedInUserUID"),
               let userType = UserDefaults.standard.string(forKey: "loggedInUserType") {
                if userType == "company" {
                    self.performSegue(withIdentifier: "loginCompanyOK", sender: nil)
                } else if userType == "user" {
                    self.performSegue(withIdentifier: "loginCompanyOK", sender: nil)
                }
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
        hideKeyboard()
        
        guard let email = accountField.text, isValidEmail(email),
              let password = passwordField.text, isValidPassword(password) else {
            showAlert(message: "Please enter a valid email and password.")
            return
        }
        
        showActivityIndicator()
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            self.hideActivityIndicator()
            if let error = error {
                self.showAlert(message: "Error logging in: \(error.localizedDescription)")
                return
            }
            if let user = authResult?.user {
                self.checkUserTypeAndNavigate(user: user)
            }
        }
    }

    
    func checkUserTypeAndNavigate(user: User) {
        let db = Firestore.firestore()
        
        // Verificar si es una compañía
        db.collection("companies").document(user.uid).getDocument { (document, error) in
            if let document = document, document.exists {
                // Si es una compañía
                self.storeSession(userUID: user.uid, userType: "company")
                self.performSegue(withIdentifier: "loginCompanyOK", sender: nil)
            } else {
                // Verificar si es un usuario normal
                db.collection("users").document(user.uid).getDocument { (document, error) in
                    if let document = document, document.exists {
                        // Si es un usuario normal
                        self.storeSession(userUID: user.uid, userType: "user")
                        self.performSegue(withIdentifier: "loginOK", sender: nil)
                    } else {
                        // Si no se encuentra, mostrar error
                        self.showAlert(message: "User not found. Please verify your account.")
                    }
                }
            }
        }
    }

    private func storeSession(userUID: String, userType: String) {
        let defaults = UserDefaults.standard
        defaults.set(userUID, forKey: "loggedInUserUID")
        defaults.set(userType, forKey: "loggedInUserType")
        defaults.synchronize()
    }


    // IBAction para iniciar sesión con Google
    @IBAction func signInWithGoogleTapped(_ sender: UIButton) {
        if !isInternetAvailable() {
            showMessage("There is no internet connection.")
            return
        }
        showActivityIndicator()
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            self.hideActivityIndicator()
            if let error = error {
                self.showMessage("Error logging in with Google: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user, let idToken = user.idToken?.tokenString else { return }
            let accessToken = user.accessToken.tokenString
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.showMessage("Error authenticating with Firebase: \(error.localizedDescription)")
                    return
                }
                if let user = authResult?.user {
                    self.checkUserTypeAndNavigate(user: user)
                }
            }
        }
    }

    


    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        hideKeyboard()

        guard let email = accountField.text, isValidEmail(email) else {
            showAlert(message: "Please enter a valid email to recover the password.")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.showAlert(message: "Error sending the recovery email: \(error.localizedDescription)")
                return
            }
            self.showAlert(message: "Recovery email sent. Check your inbox.")
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func createAccountTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "CreateCompanyAccountSegue", sender: self)
    }
    
    private func storeUserDetails(email: String) {
        let ud = UserDefaults.standard
        ud.set(true, forKey: "customCompanyLogin")
        ud.set(email, forKey: "userCompanyEmail")
        ud.synchronize()
    }
    
    // Mostrar mensajes
    private func showMessage(_ message: String) {
        let alert = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Validación de correo y contraseña
    
    // Extensión para validar el email y ocultar el teclado
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)[A-Za-z\\d@$!%*?&#]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
}
