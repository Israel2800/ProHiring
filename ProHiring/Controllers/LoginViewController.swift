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
import FirebaseCore
import FirebaseFirestore

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
        
        // Configuración de Google Sign-In
        if let clientID = FirebaseApp.app()?.options.clientID {
            googleSignInConfig = GIDConfiguration(clientID: clientID)
        } else {
            showMessage("No se encontró el clientID de Google.")
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
            print("Sí hay conexión a internet")
        } else {
            showMessage("No hay conexión a Internet.")
        }
        
        // Verificar si el usuario ya está autenticado
        /*
        if let currentUser = Auth.auth().currentUser {
                let db = Firestore.firestore()
                
                // Verificar si el usuario es una compañía
                let companyDocRef = db.collection("companies").document(currentUser.uid)
                companyDocRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        // Es una compañía, realizar segue correspondiente
                        self.performSegue(withIdentifier: "loginOK", sender: nil)
                    } else {
                        // Es un usuario normal
                        self.performSegue(withIdentifier: "loginOK", sender: nil)
                    }
                }
            
            
            }*/
        
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "loginOK", sender: nil)
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
    
    /*
    @IBAction func loginTapped(_ sender: UIButton) {
        
        // Ocultar teclado al presionar el botón de inicio de sesión
        hideKeyboard()
        
        guard let email = accountField.text, isValidEmail(email),
              let password = passwordField.text, isValidPassword(password) else {
            showAlert(message: "Por favor, ingresa un correo y contraseña válidos.")
            return
        }
        
        showActivityIndicator()
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            self.hideActivityIndicator()
            if let error = error {
                self.showAlert(message: "Error al iniciar sesión: \(error.localizedDescription)")
                return
            }
            self.storeUserDetails(email: email)
            self.performSegue(withIdentifier: "loginOK", sender: nil)
        }
    }
    */
    
    
    @IBAction func loginTapped(_ sender: UIButton) {
           hideKeyboard()
           
           guard let email = accountField.text, isValidEmail(email),
                 let password = passwordField.text, isValidPassword(password) else {
               showAlert(message: "Por favor, ingresa un correo y contraseña válidos.")
               return
           }
           
           showActivityIndicator()
           Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
               self.hideActivityIndicator()
               if let error = error {
                   self.showAlert(message: "Error al iniciar sesión: \(error.localizedDescription)")
                   return
               }
               if let user = authResult?.user {
                   self.checkUserTypeAndNavigate(user: user)
               }
           }
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
                if let user = authResult?.user {
                    self.checkUserTypeAndNavigate(user: user)
                }
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
    
    // Verificar la collection en Firestore
    func checkUserTypeAndNavigate(user: User) {
            let db = Firestore.firestore()
            let docRef = db.collection("users").document(user.uid)
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    // Si es un usuario normal, navegar a su perfil
                    self.performSegue(withIdentifier: "loginOK", sender: nil)
                } else {
                    // Si no es un usuario, verificar si es una compañía
                    let companyDocRef = db.collection("companies").document(user.uid)
                    companyDocRef.getDocument { (companyDocument, error) in
                        if let companyDocument = companyDocument, companyDocument.exists {
                            self.performSegue(withIdentifier: "loginCompanyOK", sender: nil)
                        } else {
                            self.showAlert(message: "No se pudo identificar al usuario.")
                        }
                    }
                }
            }
        }

    
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        hideKeyboard()

        guard let email = accountField.text, isValidEmail(email) else {
            showAlert(message: "Por favor, ingresa un correo válido para recuperar la contraseña.")
            return
        }
        
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
    

    
    @IBAction func createAccountTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "CreateAccountSegue", sender: self)
    }
    
    /*
    @IBAction func registerCompanyTapped(_ sender: UIButton) {
        if let presentingVC = self.presentingViewController {
            presentingVC.dismiss(animated: true) {
                self.performSegue(withIdentifier: "registerCompanySegue", sender: nil)
            }
        } else {
            self.performSegue(withIdentifier: "registerCompanySegue", sender: nil)
        }
    }
     */

    
    private func storeUserDetails(email: String) {
        let ud = UserDefaults.standard
        ud.set(true, forKey: "customLogin")
        ud.set(email, forKey: "userEmail")
        ud.synchronize()
    }
    
    // Mostrar mensajes
    private func showMessage(_ message: String) {
        let alert = UIAlertController(title: "Información", message: message, preferredStyle: .alert)
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
