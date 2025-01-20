//
//  AppDelegate.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 12/15/24.
//

import UIKit
import Firebase
import FirebaseCore
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    //var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let _ = InternetMonitor.shared
        
        // Cargar servicios de TreeServices y HandymanServices
        cargarTreeServices()
        cargarHandymanServices()
        cargarPopularProjects()


        // Inicializar Firebase solo una vez
        if FirebaseApp.app() == nil { FirebaseApp.configure() }
        // Inicializar Google Sign-In
        let clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID ?? "")
    
        // Iniciar monitoreo de red NetworkReachability
        NetworkReachability.shared.startMonitoring()
        
        return true

    }
    
    func cargarTreeServices() {
        // URL del API de TreeServices
        let urlString = "https://private-c0eaf-treeservices1.apiary-mock.com/treeServices/treeServices_list"
        
        // Usar el método `llenaBD` para llenar la base de datos con los servicios de TreeServices
        DataManager.shared.llenaBD(from: urlString, entityName: "TreeServices") { object, dict in
            // Usar guard let para evitar el force cast y mejorar la seguridad
            guard let treeService = object as? TreeServices else {
                print("Error: Could not convert the object to TreeServices.")
                return
            }
            // Inicializar el objeto TreeServices con los datos recibidos
            treeService.inicializaCon(dict)
        }
    }

    func cargarHandymanServices() {
        // URL del API de HandymanServices
        let urlString = "https://private-138fcc-handymanservices.apiary-mock.com/handymanServices/service_list"
        
        // Usar el método `llenaBD` para llenar la base de datos con los servicios de HandymanServices
        DataManager.shared.llenaBD(from: urlString, entityName: "HandymanServices") { object, dict in
            // Usar guard let para evitar el force cast y mejorar la seguridad
            guard let handymanService = object as? HandymanServices else {
                print("Error: Could not convert the object to HandymanServices.")
                return
            }
            // Inicializar el objeto HandymanServices con los datos recibidos
            handymanService.inicializaCon(dict)
        }
    }
    
    func cargarPopularProjects() {
        // URL del API de HandymanServices
        let urlString = "https://private-3a90bc-popularprojects.apiary-mock.com/popularProjects/popularProjects_list"
        
        // Usar el método `llenaBD` para llenar la base de datos con los servicios de HandymanServices
        DataManager.shared.llenaBD(from: urlString, entityName: "PopularProjects") { object, dict in
            // Usar guard let para evitar el force cast y mejorar la seguridad
            guard let popularProject = object as? PopularProjects else {
                print("Error: Could not convert the object to PopularProjects.")
                return
            }
            // Inicializar el objeto HandymanServices con los datos recibidos
            popularProject.inicializaCon(dict)
        }
    }
    
    func cargarCategories() {
        // URL del API de Categories
        let urlString = "https://private-a68b0b-homecategory.apiary-mock.com/Categories/listAllCategories"
        
        // Usar el método `llenaBD` para llenar la base de datos con las categorías
        DataManager.shared.llenaBD(from: urlString, entityName: "Categories") { object, dict in
            // Usar guard let para evitar el force cast y mejorar la seguridad
            guard let category = object as? Categories else {
                print("Error: Could not convert the object to Categories.")
                return
            }
            // Inicializar el objeto Categories con los datos recibidos
            category.inicializaCon(dict)
        }
    }

    func cargarInspiration() {
        // URL del API de Inspiration
        let urlString = "https://private-0e2a9f-inspiration1.apiary-mock.com/Inspirations/getAllInspirations"
        
        // Usar el método `llenaBD` para llenar la base de datos con la inspiración
        DataManager.shared.llenaBD(from: urlString, entityName: "Inspiration") { object, dict in
            // Usar guard let para evitar el force cast y mejorar la seguridad
            guard let inspiration = object as? Inspiration else {
                print("Error: Could not convert the object to Inspiration.")
                return
            }
            // Inicializar el objeto Inspiration con los datos recibidos
            inspiration.inicializaCon(dict)
        }
    }


    @available(iOS 9.0, *) 
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool { return GIDSignIn.sharedInstance.handle(url)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool { return GIDSignIn.sharedInstance.handle(url)
    }
    
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

