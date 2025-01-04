//
//  Inspiration+CoreDataProperties.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 1/4/25.
//
//

import Foundation
import CoreData


extension Inspiration {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Inspiration> {
        return NSFetchRequest<Inspiration>(entityName: "Inspiration")
    }

    @NSManaged public var destinationView: String?
    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var imageName: String?

}

extension Inspiration : Identifiable {

}
