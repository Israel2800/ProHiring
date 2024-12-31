//
//  HomeData+CoreDataProperties.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 12/30/24.
//
//

import Foundation
import CoreData


extension HomeData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HomeData> {
        return NSFetchRequest<HomeData>(entityName: "HomeData")
    }

    @NSManaged public var id: String?
    @NSManaged public var imageName: String?
    @NSManaged public var title: String?
    @NSManaged public var destinationView: String?

}

extension HomeData : Identifiable {

}
