//
//  HomeCategory+CoreDataProperties.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 1/1/25.
//
//

import Foundation
import CoreData


extension HomeCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HomeCategory> {
        return NSFetchRequest<HomeCategory>(entityName: "HomeCategory")
    }

    @NSManaged public var id: String?
    @NSManaged public var imageName: String?
    @NSManaged public var title: String?
    @NSManaged public var destinationView: String?

}

extension HomeCategory : Identifiable {

}
