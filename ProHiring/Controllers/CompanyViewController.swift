//
//  CompanyViewController.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 12/20/24.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class CompanyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var CompaniesTable: UITableView!

    var companies: [Company] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configurar el TableView
        CompaniesTable.delegate = self
        CompaniesTable.dataSource = self

        // Cargar datos de las compañías
        loadCompaniesData()
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CompanyCell", for: indexPath) as! CompanyCell
        
        let company = companies[indexPath.row]
        cell.companyNameLabel.text = company.companyName
        cell.servicesLabel.text = company.services
        loadLogoImage(from: company.logoURL, for: cell.logoImageView)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedCompany = companies[indexPath.row]
            performSegue(withIdentifier: "ShowCompanyProfile", sender: selectedCompany)
        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "ShowCompanyProfile",
               let destinationVC = segue.destination as? CompanyProfileViewController,
               let selectedCompany = sender as? Company {
                destinationVC.company = selectedCompany
            }
        }
    

    // MARK: - Cargar datos de Firebase
    private func loadCompaniesData() {
        let db = Firestore.firestore()
        db.collection("companies").getDocuments { snapshot, error in
            if let error = error {
                print("Error loading the companies: \(error.localizedDescription)")
                return
            }

            self.companies = snapshot?.documents.compactMap { document in
                let data = document.data()
                print("Document data: \(data)") // Verifica los datos aquí

                // Verifica si los datos esenciales existen, si no, retorna un objeto predeterminado
                let companyName = data["companyName"] as? String ?? "Unknown"
                let services = data["services"] as? String ?? "No services"
                let logoURL = data["logoURL"] as? String ?? ""
                let socialMedia = data["socialMedia"] as? String ?? "No social media"
                let contact = data["contact"] as? String ?? "No contact info"
                let email = data["name"] as? String ?? "No email"

                // Retorna el objeto Company con los valores (incluyendo predeterminados si faltan datos)
                return Company(
                    companyName: companyName,
                    services: services,
                    logoURL: logoURL,
                    socialMedia: socialMedia,
                    contact: contact,
                    name: email
                )
            } ?? []

            print("Number of companies loaded: \(self.companies.count)")

            // Recarga la tabla para reflejar los datos cargados
            self.CompaniesTable.reloadData()
        }
    }


    // MARK: - Cargar logo
    private func loadLogoImage(from url: String, for imageView: UIImageView) {
        let storageRef = Storage.storage().reference(forURL: url)
        storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let data = data, let image = UIImage(data: data) {
                imageView.image = image
            }
        }
    }
}

// CompanyCell.swift
import UIKit

class CompanyCell: UITableViewCell {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var servicesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
