//
//  HandymanServices+CoreDataProperties.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 12/26/24.
//
//

import Foundation
import CoreData


extension HandymanServices {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HandymanServices> {
        return NSFetchRequest<HandymanServices>(entityName: "HandymanServices")
    }

    @NSManaged public var descrip: String?
    @NSManaged public var duration: String?
    @NSManaged public var id: String?
    @NSManaged public var price: String?
    @NSManaged public var thumbnail: String?
    @NSManaged public var title: String?

}

extension HandymanServices : Identifiable {

}
