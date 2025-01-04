//
//  Inspiration+CoreDataClass.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 1/4/25.
//
//

import Foundation
import CoreData

@objc(Inspiration)
public class Inspiration: NSManagedObject {
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
