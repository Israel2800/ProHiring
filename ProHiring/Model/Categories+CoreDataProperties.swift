//
//  Categories+CoreDataProperties.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 1/4/25.
//
//

import Foundation
import CoreData


extension Categories {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Categories> {
        return NSFetchRequest<Categories>(entityName: "Categories")
    }

    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var imageName: String?
    @NSManaged public var destinationView: String?

}

extension Categories : Identifiable {

}
