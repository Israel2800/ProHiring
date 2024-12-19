//
//  TreeServices+CoreDataProperties.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 12/19/24.
//
//

import Foundation
import CoreData


extension TreeServices {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TreeServices> {
        return NSFetchRequest<TreeServices>(entityName: "TreeServices")
    }

    @NSManaged public var id: String?
    @NSManaged public var thumbnail: String?
    @NSManaged public var title: String?
    @NSManaged public var descrip: String?
    @NSManaged public var price: String?
    @NSManaged public var duration: String?

}

extension TreeServices : Identifiable {

}
