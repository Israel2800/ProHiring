//
//  PopularProjectsDetailsViewController.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 1/14/25.
//

import UIKit

class PopularProjectsDetailsViewController: UIViewController {
    
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
        let urlString = "https://private-3a90bc-popularprojects.apiary-mock.com/popularProjects/service_detail/\(id)"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error obtaining details: \(error)")
                return
            }
            guard let data = data else {
                print("The data was not received.")
                return
            }
            do {
                let decoder = JSONDecoder()
                let detail = try decoder.decode(PopularProjectDetail.self, from: data)
                
                DispatchQueue.main.async {
                    self?.updateUI(with: detail)
                }
            } catch {
                print("Error decoding data: \(error)")
            }
        }
        task.resume()
    }
    
    func updateUI(with detail: PopularProjectDetail) {
        titleLabel.text = detail.title
        descriptionLabel.text = detail.long_desc
        
        // Carga la imagen usando SDWebImage
        if let url = URL(string: detail.image) {
            treeImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        }
    }
}

// MARK: - Modelo para PopularProjectDetail

struct PopularProjectDetail: Codable {
    let title: String
    let image: String
    let long_desc: String
}
