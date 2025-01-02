//
//  PopularProjects+CoreDataProperties.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 1/1/25.
//
//

import Foundation
import CoreData


extension PopularProjects {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PopularProjects> {
        return NSFetchRequest<PopularProjects>(entityName: "PopularProjects")
    }

    @NSManaged public var descrip: String?
    @NSManaged public var duration: String?
    @NSManaged public var thumbnail: String?
    @NSManaged public var title: String?
    @NSManaged public var price: String?
    @NSManaged public var id: String?

}

extension PopularProjects : Identifiable {

}
