//
//  ServicesViewController.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 12/23/24.
//

import UIKit

class ServicesViewController: UIViewController {

    // Outlets
    @IBOutlet weak var treeServicesImageView: UIImageView!
    @IBOutlet weak var handymanImageView: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let treeServicesTap = UITapGestureRecognizer(target: self, action: #selector(navigateToLandscaping))
        treeServicesImageView.addGestureRecognizer(treeServicesTap)
        treeServicesImageView.isUserInteractionEnabled = true

        let handymanTap = UITapGestureRecognizer(target: self, action: #selector(navigateToHandyman))
        handymanImageView.addGestureRecognizer(handymanTap)
        handymanImageView.isUserInteractionEnabled = true
    }

    // Navigation Methods
    @objc func navigateToLandscaping() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let treeServicesVC = storyboard.instantiateViewController(withIdentifier: "TreeServicesViewController") as? TreeServicesViewController {
            navigationController?.pushViewController(treeServicesVC, animated: true)
        }
    }

    @objc func navigateToHandyman() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let handymanServicesVC = storyboard.instantiateViewController(withIdentifier: "HandymanServicesViewController") as? HandymanServicesViewController {
            navigationController?.pushViewController(handymanServicesVC, animated: true)
        }
    }
}
