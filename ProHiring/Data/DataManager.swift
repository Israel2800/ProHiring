// DataManager.swift
// ProHiring
//
// Created by Paola Delgadillo on 12/17/24.
//

import UIKit
import CoreData

class DataManager: NSObject {
    
    static let shared = DataManager()
    
    private override init() {
        super.init()
    }
    
    // MARK: - General Methods
    
    func fetchAllServices<T: NSManagedObject>(entityName: String) -> [T] {
        var result = [T]()
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        do {
            result = try persistentContainer.viewContext.fetch(fetchRequest)
            result.forEach { print("Servicio encontrado: \($0)") }
        } catch {
            print("¡Error al realizar el query para \(entityName)! Error: \(error)")
        }
        return result
    }
    
    func fetchServiceByName<T: NSManagedObject>(_ name: String, entityName: String, attributeName: String) -> T? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "\(attributeName) == %@", name)
        do {
            let result = try persistentContainer.viewContext.fetch(fetchRequest) as! [T]
            return result.first
        } catch {
            print("¡Error al realizar el query por nombre en \(entityName)! Error: \(error)")
        }
        return nil
    }
    
    func saveServices(_ jsonArray: [[String: Any]], entityName: String, initializer: @escaping (NSManagedObject, [String: Any]) -> Void) {
        guard let entityDesc = NSEntityDescription.entity(forEntityName: entityName, in: persistentContainer.viewContext) else {
            print("Error: No se pudo encontrar la entidad \(entityName) en el contexto.")
            return
        }
        for dict in jsonArray {
            let object = NSManagedObject(entity: entityDesc, insertInto: persistentContainer.viewContext)
            initializer(object, dict)
            print("\(entityName) guardado: \(dict)")
        }
        saveContext()
    }
    
    // MARK: - TreeServices Methods
    
    func todosLosTreeServices() -> [TreeServices] {
        return fetchAllServices(entityName: "TreeServices")
    }
    
    func buscaTreeServiceConNombre(_ nombre: String) -> TreeServices? {
        return fetchServiceByName(nombre, entityName: "TreeServices", attributeName: "title")
    }
    
    func llenaBDTreeServices() {
        llenaBD(urlString: "https://private-c0eaf-treeservices1.apiary-mock.com/treeServices/treeServices_list", entityName: "TreeServices") { object, dict in
            (object as! TreeServices).inicializaCon(dict)
        }
    }
    
    // MARK: - HandymanServices Methods
    
    func todosLosHandymanServices() -> [HandymanServices] {
        return fetchAllServices(entityName: "HandymanServices")
    }
    
    func buscaHandymanServiceConNombre(_ nombre: String) -> HandymanServices? {
        return fetchServiceByName(nombre, entityName: "HandymanServices", attributeName: "title")
    }
    
    func llenaBDHandymanServices() {
        llenaBD(urlString: "https://private-138fcc-handymanservices.apiary-mock.com/handymanServices/service_list", entityName: "HandymanServices") { object, dict in
            (object as! HandymanServices).inicializaCon(dict)
        }
    }
    
    // MARK: - Categories Methods

    func todasLasCategorias() -> [HomeData] {
        return fetchAllServices(entityName: "HomeData")
    }

    func buscaCategoriaConNombre(_ nombre: String) -> HomeData? {
        return fetchServiceByName(nombre, entityName: "HomeData", attributeName: "title")
    }

    func llenaBDCategorias() {
        /*llenaBD(urlString: "https://private-740e4f-homedata1.apiary-mock.com/homedata/categories", entityName: "Categories") { object, dict in
            guard let categories = object as? Categories else { return }
            categories.id = dict["id"] as? String
            categories.title = dict["title"] as? String
            categories.imageName = dict["imageName"] as? String
            categories.destinationView = dict["destinationView"] as? String
            print("Categoría guardada: \(categories)")
        }
         */
        
            llenaBD(urlString: "https://private-740e4f-homedata1.apiary-mock.com/homedata/categories", entityName: "HomeData") { object, dict in
                (object as! HomeData).inicializaCon(dict)
            }
        
        
    }

    /*
    // MARK: - Popular Projects Methods

    func todosLosProyectosPopulares() -> [PopularProject] {
        return fetchAllServices(entityName: "PopularProject")
    }

    func buscaProyectoPopularConNombre(_ nombre: String) -> PopularProject? {
        return fetchServiceByName(nombre, entityName: "PopularProject", attributeName: "title")
    }

    func llenaBDProyectosPopulares() {
        llenaBD(urlString: "https://handyman.apiblueprint.org/homedata/popular_projects", entityName: "PopularProject") { object, dict in
            guard let project = object as? PopularProject else { return }
            project.id = dict["id"] as? String
            project.title = dict["title"] as? String
            project.imageName = dict["imageName"] as? String
            project.price = dict["price"] as? String
            project.destinationView = dict["destinationView"] as? String
        }
    }

    // MARK: - Inspirations Methods

    func todasLasInspiraciones() -> [Inspiration] {
        return fetchAllServices(entityName: "Inspiration")
    }

    func buscaInspiracionConDescripcion(_ descripcion: String) -> Inspiration? {
        return fetchServiceByName(descripcion, entityName: "Inspiration", attributeName: "description")
    }

    func llenaBDInspiraciones() {
        llenaBD(urlString: "https://handyman.apiblueprint.org/homedata/inspirations", entityName: "Inspiration") { object, dict in
            guard let inspiration = object as? Inspiration else { return }
            inspiration.id = dict["id"] as? String
            inspiration.descriptionText = dict["description"] as? String
            inspiration.imageName = dict["imageName"] as? String
            inspiration.buttonTitle = dict["buttonTitle"] as? String
            inspiration.destinationView = dict["destinationView"] as? String
        }
    }
*/
    
    
    // MARK: - Helper Methods
    
    func llenaBD(urlString: String, entityName: String, initializer: @escaping (NSManagedObject, [String: Any]) -> Void) {
        let ud = UserDefaults.standard
        if ud.integer(forKey: "BD-OK-\(entityName)") != 1 {
            if InternetMonitor.shared.hayConexion {
                guard let url = URL(string: urlString) else { return }
                let session = URLSession(configuration: .default)
                let task = session.dataTask(with: URLRequest(url: url)) { data, response, error in
                    if let error = error {
                        print("Error al descargar \(entityName): \(error.localizedDescription)")
                        return
                    }
                    guard let data = data else {
                        print("No se recibió datos para \(entityName).")
                        return
                    }
                    do {
                        let jsonArray = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]
                        print("Datos recibidos para \(entityName): \(jsonArray)") // Imprimir los datos recibidos
                        self.saveServices(jsonArray, entityName: entityName, initializer: initializer)
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name("BD_LISTA_\(entityName)"), object: nil)
                        }
                        ud.set(1, forKey: "BD-OK-\(entityName)")
                    } catch {
                        print("Error al procesar JSON para \(entityName). Error: \(error)")
                    }
                }
                task.resume()
            }
        } else {
            print("Ya se descargaron los datos para \(entityName).")
        }
    }
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ProHiring") // Usando un contenedor único para ambos modelos
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // Función genérica para guardar en cualquier contenedor
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
