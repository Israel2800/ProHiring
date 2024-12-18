//
//  DataManager.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 12/17/24.
//

import UIKit
import CoreData

class DataManager: NSObject {
    
    static let shared = DataManager()
    
    private override init() {
        super.init()
    }
    
    func todosLosServicios() -> [Servicios] {
        var arreglo = [Drinks]()
        let elQuery = Drinks.fetchRequest()
        do {
            arreglo = try persistentContainer.viewContext.fetch(elQuery)
        } catch { print ("¡Error en el Query 1!") }
        return arreglo
    }
    
    
}
