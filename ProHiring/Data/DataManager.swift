// DataManager.swift
// ProHiring
//
// Created by Paola Delgadillo on 12/17/24.
//

/*
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
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "\(attributeName) == %@", name)
        do {
            let result = try persistentContainer.viewContext.fetch(fetchRequest)
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

    func todasLasCategorias() -> [HomeCategory] {
        return fetchAllServices(entityName: "HomeCategory")
    }

    func buscaCategoriaConNombre(_ nombre: String) -> HomeCategory? {
        return fetchServiceByName(nombre, entityName: "HomeCategory", attributeName: "title")
    }

    func llenaBDCategorias() {
        llenaBD(urlString: "https://private-a68b0b-homecategory.apiary-mock.com/HomeCategory/listAllHomeCategories", entityName: "HomeCategory") { object, dict in
            (object as! HomeCategory).inicializaCon(dict)
        }
    }

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
                        print("Datos recibidos para \(entityName): \(jsonArray)")
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
        let container = NSPersistentContainer(name: "ProHiring")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
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
*/

import UIKit
import CoreData

// MARK: - DataManager

class DataManager: NSObject {

    // MARK: - Singleton
    static let shared = DataManager()
    private override init() {
        super.init()
    }

    // MARK: - Core Data Stack
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ProHiring")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

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

    func createBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }

    // MARK: - General Methods
    func fetchAll<T: NSManagedObject>(for entity: T.Type) -> [T] {
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: entity))
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching \(entity): \(error.localizedDescription)")
            return []
        }
    }

    func fetchByName<T: NSManagedObject>(_ name: String, for entity: T.Type, attributeName: String) -> T? {
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: entity))
        fetchRequest.predicate = NSPredicate(format: "\(attributeName) == %@", name)
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest).first
        } catch {
            print("Error fetching \(entity) by name: \(error.localizedDescription)")
            return nil
        }
    }

    func saveServices(_ jsonArray: [[String: Any]], for entityName: String, initializer: @escaping (NSManagedObject, [String: Any]) -> Void) {
        let context = createBackgroundContext()
        context.perform {
            guard let entityDesc = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
                print("Error: Entity \(entityName) not found.")
                return
            }
            for dict in jsonArray {
                let object = NSManagedObject(entity: entityDesc, insertInto: context)
                initializer(object, dict)
                print("\(entityName) saved: \(dict)")
            }
            do {
                try context.save()
            } catch {
                print("Error saving context for \(entityName): \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Network Methods
    func downloadData(from urlString: String, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(DataManagerError.networkError("Invalid URL: \(urlString)")))
            return
        }

        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            if let error = error {
                completion(.failure(DataManagerError.networkError("Network error: \(error.localizedDescription)")))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(DataManagerError.networkError("Invalid HTTP response.")))
                return
            }

            guard let data = data else {
                completion(.failure(DataManagerError.networkError("Empty data.")))
                return
            }

            do {
                let jsonArray = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]
                completion(.success(jsonArray))
            } catch {
                completion(.failure(DataManagerError.networkError("JSON parsing error: \(error.localizedDescription)")))
            }
        }.resume()
    }

    func llenaBD(from urlString: String, entityName: String, initializer: @escaping (NSManagedObject, [String: Any]) -> Void) {
        let ud = UserDefaults.standard
        if ud.integer(forKey: "BD-OK-\(entityName)") != 1 {
            downloadData(from: urlString) { [weak self] result in
                switch result {
                case .success(let jsonArray):
                    self?.saveServices(jsonArray, for: entityName, initializer: initializer)
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name("BD_LISTA_\(entityName)"), object: nil)
                    }
                    ud.set(1, forKey: "BD-OK-\(entityName)")
                    print("Data loaded successfully for \(entityName).")
                case .failure(let error):
                    print("Error loading data for \(entityName): \(error)")
                }
            }
        } else {
            print("Data already loaded for \(entityName).")
        }
    }


    // MARK: - TreeServices Methods
    func todosLosTreeServices() -> [TreeServices] {
        return fetchAll(for: TreeServices.self)
    }

    func buscaTreeServiceConNombre(_ nombre: String) -> TreeServices? {
        return fetchByName(nombre, for: TreeServices.self, attributeName: "title")
    }

    func llenaBDTreeServices() {
        llenaBD(
            from: "https://private-c0eaf-treeservices1.apiary-mock.com/treeServices/treeServices_list",
            entityName: "TreeServices"
        ) { object, dict in
            (object as! TreeServices).inicializaCon(dict)
        }
    }

    // MARK: - HandymanServices Methods
    func todosLosHandymanServices() -> [HandymanServices] {
        return fetchAll(for: HandymanServices.self)
    }

    func buscaHandymanServiceConNombre(_ nombre: String) -> HandymanServices? {
        return fetchByName(nombre, for: HandymanServices.self, attributeName: "title")
    }

    func llenaBDHandymanServices() {
        llenaBD(
            from: "https://private-138fcc-handymanservices.apiary-mock.com/handymanServices/service_list",
            entityName: "HandymanServices"
        ) { object, dict in
            (object as! HandymanServices).inicializaCon(dict)
        }
    }
    
    // MARK: - PopularProjects Methods
    func todosLosPopularProjects() -> [PopularProjects] {
        return fetchAll(for: PopularProjects.self)
    }

    func buscaPopularProjectsConNombre(_ nombre: String) -> PopularProjects? {
        return fetchByName(nombre, for: PopularProjects.self, attributeName: "title")
    }

    func llenaBDPopularProjects() {
        llenaBD(
            from: "https://private-3a90bc-popularprojects.apiary-mock.com/popularProjects/popularProjects_list",
            entityName: "PopularProjects"
        ) { object, dict in
            (object as! PopularProjects).inicializaCon(dict)
        }
    }

    // MARK: - Categories Methods
    func todasLasCategorias() -> [HomeCategory] {
        return fetchAll(for: HomeCategory.self)
    }

    func buscaCategoriaConNombre(_ nombre: String) -> HomeCategory? {
        return fetchByName(nombre, for: HomeCategory.self, attributeName: "title")
    }

    func llenaBDCategorias() {
        llenaBD(
            from: "https://private-a68b0b-homecategory.apiary-mock.com/HomeCategory/listAllHomeCategories",
            entityName: "HomeCategory"
        ) { object, dict in
            (object as! HomeCategory).inicializaCon(dict)
        }
    }
}

// MARK: - Error Definition
enum DataManagerError: Error {
    case fetchFailed(String)
    case saveFailed(String)
    case invalidEntity(String)
    case networkError(String)
}

