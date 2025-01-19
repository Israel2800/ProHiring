//
//  CompanyProfileViewController.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 1/4/25.
//

import UIKit
import FirebaseStorage

class CompanyProfileViewController: UIViewController {

    // Outlets para mostrar los datos
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var servicesLabel: UILabel!
    @IBOutlet weak var socialMediaLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var company: Company? // Recibirá la compañía seleccionada

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupGestureRecognizers() // Configurar los gestos
    }

    private func configureUI() {
        guard let company = company else { return }
        companyNameLabel.text = company.companyName
        servicesLabel.text = company.services
        socialMediaLabel.text = company.socialMedia
        contactLabel.text = company.contact
        emailLabel.text = company.name
        
        // Cargar el logo
        if !company.logoURL.isEmpty {
            let storageRef = Storage.storage().reference(forURL: company.logoURL)
            storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                if let data = data, let image = UIImage(data: data) {
                    self.logoImageView.image = image
                }
            }
        }
    }
    
    // Configura los gestos para las etiquetas
    private func setupGestureRecognizers() {
        let contactTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleContactTap))
        contactLabel.isUserInteractionEnabled = true
        contactLabel.addGestureRecognizer(contactTapGesture)
        
        let emailTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleEmailTap))
        emailLabel.isUserInteractionEnabled = true
        emailLabel.addGestureRecognizer(emailTapGesture)
    }

    // Acción para intentar realizar una llamada
    @objc private func handleContactTap() {
        guard let phoneNumber = company?.contact, let phoneURL = URL(string: "tel://\(phoneNumber)") else {
            return
        }
        if UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL)
        } else {
            // Mostrar alerta si no se puede realizar la llamada
            showAlert(message: "It is not possible to make the call.")
        }
    }
    
    // Acción para intentar enviar un correo
    @objc private func handleEmailTap() {
        guard let email = company?.name, let emailURL = URL(string: "mailto:\(email)") else {
            return
        }
        if UIApplication.shared.canOpenURL(emailURL) {
            UIApplication.shared.open(emailURL)
        } else {
            // Mostrar alerta si no se puede enviar el correo
            showAlert(message: "It is not possible to send the email.")
        }
    }
    
    // Función para mostrar alertas
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
