//
//  HomeData+CoreDataClass.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 12/30/24.
//
//

import Foundation
import CoreData

@objc(HomeData)
public class HomeData: NSManagedObject {
    func inicializaCon(_ dict: Dictionary<String, Any>) {
        let id = (dict["id"] as? String) ?? ""
        let title = (dict["title"] as? String) ?? ""
        let imageName = (dict["imageName"] as? String) ?? ""
        let destinationView = (dict["destinationView"] as? String) ?? ""
        
        self.id = id
        self.title = title
        self.imageName = imageName
        self.destinationView = destinationView
        
    }
}
