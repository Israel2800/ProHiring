//
//  HandymanServicesDetailViewController.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 1/12/25.
//

import UIKit

class HandymanServicesDetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var additionalDetailsLabel: UILabel!
    @IBOutlet weak var treeImageView: UIImageView!
    
    var serviceId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let id = serviceId else { return }
        
        // Llama a la API para obtener los detalles del servicio
        fetchServiceDetail(id: id)
    }
    
    func fetchServiceDetail(id: String) {
        let urlString = "https://private-138fcc-handymanservices.apiary-mock.com/handymanServices/service_detail/\(id)"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error getting details: \(error)")
                return
            }
            guard let data = data else {
                print("The data was not received.")
                return
            }
            do {
                let decoder = JSONDecoder()
                let detail = try decoder.decode(HandymanServiceDetail.self, from: data)
                
                DispatchQueue.main.async {
                    self?.updateUI(with: detail)
                }
            } catch {
                print("Error decoding data: \(error)")
            }
        }
        task.resume()
    }
    
    func updateUI(with detail: HandymanServiceDetail) {
        titleLabel.text = detail.title
        descriptionLabel.text = detail.long_desc
        
        // Carga la imagen usando SDWebImage
        if let url = URL(string: detail.image) {
            treeImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        }
    }
}

// MARK: - Modelo para HandymanServiceDetail

struct HandymanServiceDetail: Codable {
    let title: String
    let image: String
    let long_desc: String
    let additional_detail_1: String
    let additional_detail_2: String
}
