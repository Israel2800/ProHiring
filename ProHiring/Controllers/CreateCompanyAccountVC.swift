//
//  CreateCompanyAccountVC.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 1/2/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import GoogleSignIn
import Photos

class CreateCompanyAccountVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var logoImageView: UIImageView! // Para mostrar el logo
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var companyNameField: UITextField! // Campo de nombre de la compañía
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
        companyNameField.placeholder = "Company Name"
        servicesField.placeholder = "Services offered"
        socialMediaField.placeholder = "Social Media"
        contactField.placeholder = "Contact information"
        
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
        
        
        // Agregar gesture recognizer para ocultar el teclado al tocar fuera
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
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
    }

    func isInternetAvailable() -> Bool {
        return NetworkReachability.shared.isConnected
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true) // Oculta el teclado para todos los campos
    }

    // Función para seleccionar logo
    @IBAction func selectLogoTapped(_ sender: UIButton) {
        // Verificar permisos antes de abrir el selector de imágenes
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                // Permiso concedido, abrir la galería
                DispatchQueue.main.async {
                    let imagePickerController = UIImagePickerController()
                    imagePickerController.delegate = self
                    imagePickerController.sourceType = .photoLibrary
                    self.present(imagePickerController, animated: true, completion: nil)
                }
            case .denied, .restricted:
                // El usuario denegó el acceso, muestra un mensaje o toma otra acción
                DispatchQueue.main.async {
                    self.showMessage("You do not have access to the photo gallery. Go to Settings to enable it.")
                }
            case .notDetermined:
                // El usuario aún no ha respondido a la solicitud, solicita permiso
                PHPhotoLibrary.requestAuthorization { _ in
                    // Volver a intentar abrir la galería después de la respuesta
                    self.selectLogoTapped(sender)
                }
            @unknown default:
                break
            }
        }
    }


    // Delegate method for image picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            logoImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }

    private func saveCompanyDataToFirestore(userID: String, logoURL: String, companyName: String, services: String, socialMedia: String, contact: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let companyData: [String: Any] = [
            "logoURL": logoURL,
            "companyName": companyName,
            "name": emailField.text ?? "",
            "services": services,
            "socialMedia": socialMedia,
            "contact": contact
        ]
        db.collection("companies").document(userID).setData(companyData) { error in
            if let error = error {
                self.showMessage("Error saving data to Firestore: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }


    @IBAction func createAccountTapped(_ sender: UIButton) {
        guard let email = emailField.text, isValidEmail(email),
              let password = passwordField.text, isValidPassword(password),
              let companyName = companyNameField.text, !companyName.isEmpty,
              let services = servicesField.text, !services.isEmpty,
              let socialMedia = socialMediaField.text, !socialMedia.isEmpty,
              let contact = contactField.text, !contact.isEmpty,
              let logoImage = logoImageView.image else {
            showMessage("Please complete all the fields and select a logo.")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                self.showMessage("Error creating the account: \(error.localizedDescription)")
                return
            }
            guard let userID = authResult?.user.uid else { return }
            self.uploadLogoToStorage(userID: userID, logoImage: logoImage) { logoURL in
                guard let logoURL = logoURL else { return }
                self.saveCompanyDataToFirestore(userID: userID, logoURL: logoURL, companyName: companyName, services: services, socialMedia: socialMedia, contact: contact) { success in
                    if success {
                        // Iniciar sesión con el usuario recién creado
                        Auth.auth().signIn(withEmail: email, password: password) { _, error in
                            if let error = error {
                                self.showMessage("Error authenticating after account creation: \(error.localizedDescription)")
                                return
                            }
                        
                            self.emailField.text = ""
                            self.passwordField.text = ""
                            self.companyNameField.text = ""
                            self.servicesField.text = ""
                            self.socialMediaField.text = ""
                            self.contactField.text = ""
                            self.logoImageView.image = nil
                            
                            self.showMessage("Account created successfully!")
                        }
                    }
                }
                self.navigateToTabBarProfile()
            }
        }

    }



    private func uploadLogoToStorage(userID: String, logoImage: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = logoImage.jpegData(compressionQuality: 0.8) else {
            showMessage("Error processing the selected image.")
            completion(nil)
            return
        }
        let storageRef = Storage.storage().reference().child("logos/\(userID).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                self.showMessage("Error uploading the logo: \(error.localizedDescription)")
                completion(nil)
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    self.showMessage("Error obtaining logo URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                completion(url?.absoluteString)
            }
        }
    }


    private func navigateToTabBarProfile() {
        DispatchQueue.main.async {
            if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "CompanyProfileTabBar") {
                print("Instanciado CompanyProfileTabBar")
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true, completion: nil)
            } else {
                print("No se pudo instanciar el view controller CompanyProfileTabBar")
            }
        }

    }

    

    // Función para mostrar mensajes de alerta
    func showMessage(_ message: String) {
        let alert = UIAlertController(title: "Information", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
                self.navigateToTabBarProfile()
            }
        }
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
