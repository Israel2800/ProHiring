//
//  FirebaseAuth.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 12/22/24.
//

import FirebaseAuth
import GoogleSignIn
import AuthenticationServices

class FirebaseAuthManager {
    
    // Método para manejar la autenticación en Firebase
    static func authenticateUser(email: String?, password: String?, provider: AuthProvider, viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        if provider == .email {
            guard let email = email, let password = password else {
                //viewController.showMessage("Por favor ingresa un correo y contraseña válidos.")
                return
            }
            // Autenticación por correo
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if error != nil {
                    //viewController.showMessage("Error al iniciar sesión: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                // Iniciar sesión exitoso
                viewController.performSegue(withIdentifier: "loginOK", sender: nil)
                completion(true)
            }
        } else if provider == .google {
            // Autenticación por Google
            GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
                if error != nil {
                    //viewController.showMessage("Error al iniciar sesión con Google: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                guard let user = result?.user, let idToken = user.idToken?.tokenString else { return }
                let accessToken = user.accessToken.tokenString
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                
                Auth.auth().signIn(with: credential) { authResult, error in
                    if error != nil {
                        //viewController.showMessage("Error al autenticar con Firebase: \(error.localizedDescription)")
                        completion(false)
                        return
                    }
                    // Iniciar sesión exitoso
                    viewController.performSegue(withIdentifier: "loginOK", sender: nil)
                    completion(true)
                }
            }
        } else if provider == .apple {
            // Autenticación por Apple
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authController = ASAuthorizationController(authorizationRequests: [request])
            authController.presentationContextProvider = viewController as? ASAuthorizationControllerPresentationContextProviding
            authController.delegate = viewController as? ASAuthorizationControllerDelegate
            authController.performRequests()
        }
    }
    
    enum AuthProvider {
        case email, google, apple
    }
}
