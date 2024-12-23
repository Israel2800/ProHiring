//
//  TreeServices+CoreDataClass.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 12/23/24.
//
//

import Foundation
import CoreData

@objc(TreeServices)
public class TreeServices: NSManagedObject {
    func inicializaCon(_ dict: Dictionary<String, Any>) {
        let id = (dict["id"] as? String) ?? ""
        let thumbnail = (dict["thumbnail"] as? String) ?? ""
        let title = (dict["title"] as? String) ?? ""
        let descrip = (dict["descrip"] as? String) ?? ""
        let price = (dict["price"] as? String) ?? ""
        let duration = (dict["duration"] as? String) ?? ""
        
        self.id = id
        self.thumbnail = thumbnail
        self.title = title
        self.descrip = descrip
        self.price = price
        self.duration = duration
    }
}
