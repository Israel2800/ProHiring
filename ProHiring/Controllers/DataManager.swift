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
    
    func todosLosServicios() -> [TreeServices] {
        var arreglo = [TreeServices]()
        let elQuery = TreeServices.fetchRequest()
        do {
            arreglo = try persistentContainer.viewContext.fetch(elQuery)
            // Forzar que las propiedades se carguen
            for servicio in arreglo {
                print("Servicio encontrado: \(servicio.title ?? "Sin título")")
            }
            //print("Servicios encontrados: \(arreglo)")

        } catch { print ("¡Error en el Query 1!") }
        return arreglo
    }
    
    // Función para llenar la base de datos
    func llenaBD() {
        let ud = UserDefaults.standard
        if ud.integer(forKey: "BD-OK") != 1 { // La base de datos no se ha descargado
            if InternetMonitor.shared.hayConexion {
                if let laURL = URL(string: "https://private-c0eaf-treeservices1.apiary-mock.com/treeServices/treeServices_list") {
                    let sesion = URLSession(configuration: .default)
                    let tarea = sesion.dataTask(with: URLRequest(url: laURL)) { data, response, error in
                        if error != nil {
                            print("No se pudo descargar el feed de servicios: \(error?.localizedDescription ?? "")")
                            return
                        }
                        // Llenar la base de datos
                        do {
                            let tmp = try JSONSerialization.jsonObject(with: data!) as! [[String: Any]]
                            self.saveTreeServices(tmp)
                            
                            // Enviar notificación para recargar la tabla
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: NSNotification.Name("BD_LISTA"), object: nil)
                            }
                            
                        } catch { print ("No se obtuvo un JSON en la respuesta.") }
                        ud.set(1, forKey: "BD-OK")
                    }
                    tarea.resume()
                }
            }
        }
    }
    
    // Función para buscar servicio por nombre
    func buscaServicioConNombre(_ nombre: String) -> TreeServices? {
        let elQuery = NSFetchRequest<NSFetchRequestResult>(entityName: "TreeServices")
        let elFiltro = NSPredicate(format: "title == %@", nombre)
        elQuery.predicate = elFiltro
        do {
            let tmp = try persistentContainer.viewContext.fetch(elQuery) as! [TreeServices]
            return tmp.first
        } catch { print("¡Error en el query 2!") }
        return nil
    }
    
    func saveTreeServices(_ arregloJSON: [[String: Any]]) {
        guard let entidadDesc = NSEntityDescription.entity(forEntityName: "TreeServices", in: persistentContainer.viewContext)
        else { return }
        for dict in arregloJSON {
            // 1. Crear un objeto TreeServices
            let ts = NSManagedObject(entity: entidadDesc, insertInto: persistentContainer.viewContext) as! TreeServices
            // 2. Setear las properties del objeto, con los datos del dict
            ts.inicializaCon(dict)
            print("Servicio guardado: \(ts.title ?? "Sin título")")

        }
        // 3. Guardar el objeto
        saveContext()
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TreeServices")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
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
