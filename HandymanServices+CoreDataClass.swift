//
//  HandymanServices+CoreDataClass.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 12/26/24.
//
//

import Foundation
import CoreData

@objc(HandymanServices)
public class HandymanServices: NSManagedObject {
    func inicializaCon(_ dict: Dictionary<String, Any>) {
        let id = (dict["id"] as? String) ?? ""
        let title = (dict["title"] as? String) ?? ""
        let descrip = (dict["descrip"] as? String) ?? ""
        let price = (dict["price"] as? String) ?? ""
        let thumbnail = (dict["thumbnail"] as? String) ?? ""
        let duration = (dict["duration"] as? String) ?? ""
        
        self.id = id
        self.title = title
        self.descrip = descrip
        self.price = price
        self.thumbnail = thumbnail
        self.duration = duration
        
    }
}
