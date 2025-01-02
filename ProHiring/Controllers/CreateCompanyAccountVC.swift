//
//  CreateCompanyAccountVC.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 1/2/25.
//
/*
import Foundation
import UIKit
import AuthenticationServices
import GoogleSignIn
import FirebaseAuth
import FirebaseCore

class CreateCompanyAccountVC: UIViewController, ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var createAccountBtn: UIButton!
    @IBOutlet weak var createAccountiOSBtn: UIButton!
    @IBOutlet weak var createAccountGoogleBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    
    let actInd = UIActivityIndicatorView(style: .large)
    private var googleSignInConfig: GIDConfiguration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.placeholder = "Email"
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

    @IBAction func signInBtnTapped(_ sender: UIButton) {
        hideKeyboard()

        performSegue(withIdentifier: "SignInCompany", sender: self)
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
    
    // IBAction para crear una cuenta con correo y contraseña
    @IBAction func createAccountTapped(_ sender: UIButton) {
        hideKeyboard()

        guard let email = emailField.text, isValidEmail(email),
              let password = passwordField.text, isValidPassword(password) else {
            showMessage("Por favor, ingresa un correo y contraseña válidos.")
            return
        }

        // Crear cuenta en Firebase Authentication
        showActivityIndicator()
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            self.hideActivityIndicator()
            if let error = error {
                self.showMessage("Error al crear la cuenta: \(error.localizedDescription)")
                return
            }
            self.showMessage("Cuenta creada exitosamente.")
            
            // Limpiar los campos de texto
            self.emailField.text = ""
            self.passwordField.text = ""
            
            // Presentar LoginViewController
            self.presentLoginViewController()
        }
    }
    
    // Presentar LoginViewController
    private func presentLoginViewController() {
        DispatchQueue.main.async {
            if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true, completion: nil)
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
                self.presentLoginViewController()
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
    
    // Validación de correo
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    // Validación de contraseña
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)[A-Za-z\\d@$!%*?&#]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }

    // Mostrar mensajes
    private func showMessage(_ message: String) {
        let alert = UIAlertController(title: "Información", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
*/

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import GoogleSignIn

class CreateCompanyAccountVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var logoImageView: UIImageView! // Para mostrar el logo
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var servicesField: UITextField! // Campo de servicios
    @IBOutlet weak var socialMediaField: UITextField! // Campo de redes sociales
    @IBOutlet weak var contactField: UITextField! // Campo de contacto
    
    let actInd = UIActivityIndicatorView(style: .large)
    private var googleSignInConfig: GIDConfiguration!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuración de placeholders
        emailField.placeholder = "Email"
        passwordField.placeholder = "Password"
        servicesField.placeholder = "Services offered"
        socialMediaField.placeholder = "Social Media"
        contactField.placeholder = "Contact information"
        
        // Configurar el campo de contraseña para usar asteriscos
        passwordField.isSecureTextEntry = true
        
        // Agregar gesture recognizer para ocultar el teclado al tocar fuera
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func hideKeyboard() {
        view.endEditing(true) // Oculta el teclado para todos los campos
    }

    // Función para seleccionar logo
    @IBAction func selectLogoTapped(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }

    // Delegate method for image picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            logoImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }

    // IBAction para crear una cuenta con correo y contraseña
    @IBAction func createAccountTapped(_ sender: UIButton) {
        hideKeyboard()

        guard let email = emailField.text, isValidEmail(email),
              let password = passwordField.text, isValidPassword(password),
              let services = servicesField.text, !services.isEmpty,
              let socialMedia = socialMediaField.text, !socialMedia.isEmpty,
              let contact = contactField.text, !contact.isEmpty else {
            showMessage("Please fill out all the boxes.")
            return
        }

        // Crear cuenta en Firebase Authentication
        showActivityIndicator()
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            self.hideActivityIndicator()
            if let error = error {
                self.showMessage("Error trying to create account: \(error.localizedDescription)")
                return
            }
            self.showMessage("Account successfully created.")
            
            // Guardar los datos adicionales en Firestore (o en cualquier otro servicio que utilices)
            self.saveCompanyData(logo: self.logoImageView.image, services: services, socialMedia: socialMedia, contact: contact)
        }
    }

    func saveCompanyData(logo: UIImage?, services: String, socialMedia: String, contact: String) {
        // Aquí puedes guardar la información de la compañía en Firestore o en tu base de datos de preferencia.
        // Si la compañía sube un logo, debes subir la imagen a un almacenamiento y luego guardar la URL.
        // Suponiendo que estás utilizando Firebase Firestore:
        
        if let logo = logo {
            // Subir logo a Firebase Storage y obtener la URL
            uploadLogoToFirebaseStorage(logo: logo) { logoURL in
                // Guardar los datos de la compañía en Firestore
                let companyData: [String: Any] = [
                    "services": services,
                    "socialMedia": socialMedia,
                    "contact": contact,
                    "logoURL": logoURL
                ]
                
                let db = Firestore.firestore()
                db.collection("companies").addDocument(data: companyData) { error in
                    if let error = error {
                        self.showMessage("Error al guardar los datos de la compañía: \(error.localizedDescription)")
                    } else {
                        self.showMessage("Datos de la compañía guardados exitosamente.")
                    }
                }
            }
        }
    }

    // Método para subir logo a Firebase Storage (esto es solo un ejemplo)
    func uploadLogoToFirebaseStorage(logo: UIImage, completion: @escaping (String) -> Void) {
        let storageRef = Storage.storage().reference().child("company_logos/\(UUID().uuidString).jpg")
        if let imageData = logo.jpegData(compressionQuality: 0.75) {
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    self.showMessage("Error al subir el logo: \(error.localizedDescription)")
                    return
                }
                storageRef.downloadURL { url, error in
                    if let error = error {
                        self.showMessage("Error al obtener la URL del logo: \(error.localizedDescription)")
                        return
                    }
                    guard let logoURL = url?.absoluteString else { return }
                    completion(logoURL)
                }
            }
        }
    }

    // Función para mostrar mensajes de alerta
    func showMessage(_ message: String) {
        let alert = UIAlertController(title: "Información", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // Función para mostrar el indicador de carga
    func showActivityIndicator() {
        actInd.startAnimating()
        actInd.center = view.center
        view.addSubview(actInd)
    }

    // Función para ocultar el indicador de carga
    func hideActivityIndicator() {
        actInd.stopAnimating()
        actInd.removeFromSuperview()
    }

    // Métodos para validación de email y contraseña
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }

    // Validación de contraseña
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)[A-Za-z\\d@$!%*?&#]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
}
