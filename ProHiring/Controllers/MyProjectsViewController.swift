//
//  MyProjectsViewController.swift
//  ProHiring
//
//  Created by Paola Delgadillo on 12/20/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class MyProjectsViewController: UIViewController {

    @IBOutlet weak var serviceTableView: UITableView!
    @IBOutlet weak var serviceNameTextField: UITextField!
    @IBOutlet weak var serviceColorPicker: UIPickerView!
    
    var serviceList = [Service]()
    var db: Firestore!
    var currentUserID: String?
    var colors = ["Verde", "Amarillo", "Rojo"] // Colores disponibles para PickerView
    var selectedServiceToEdit: Service?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        currentUserID = Auth.auth().currentUser?.uid
        
        setupPickerView()
        setupTableView()
        loadServices()
    }

    private func setupPickerView() {
        serviceColorPicker.delegate = self
        serviceColorPicker.dataSource = self
    }

    private func setupTableView() {
        serviceTableView.delegate = self
        serviceTableView.dataSource = self
        serviceTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ServiceCell")
    }

    // Cargar los servicios desde Firestore
    private func loadServices() {
        guard let currentUserID = currentUserID else { return }
        
        db.collection("users").document(currentUserID).collection("services").addSnapshotListener { [weak self] (snapshot, error) in
            if let error = error {
                print("Error al cargar los servicios: \(error.localizedDescription)")
            } else {
                self?.serviceList.removeAll()
                for document in snapshot!.documents {
                    let service = Service(
                        name: document["name"] as? String ?? "",
                        color: document["color"] as? String ?? "",
                        status: document["status"] as? String ?? "",
                        id: document.documentID
                    )
                    self?.serviceList.append(service)
                }
                self?.serviceTableView.reloadData()
            }
        }
    }

    // Agregar un nuevo servicio
    @IBAction func addServiceButtonTapped(_ sender: UIButton) {
        guard let serviceName = serviceNameTextField.text, !serviceName.isEmpty else {
            print("El campo de nombre del servicio está vacío.")
            return
        }
        
        let selectedColor = colors[serviceColorPicker.selectedRow(inComponent: 0)]
        let serviceData: [String: Any] = [
            "name": serviceName,
            "color": selectedColor,
            "status": getServiceStatus(color: selectedColor)
        ]
        
        if let serviceToEdit = selectedServiceToEdit {
            updateService(serviceToEdit, withData: serviceData)
        } else {
            addService(serviceData)
        }
    }

    private func addService(_ serviceData: [String: Any]) {
        guard let currentUserID = currentUserID else { return }
        
        db.collection("users").document(currentUserID).collection("services").addDocument(data: serviceData) { [weak self] error in
            if let error = error {
                print("Error al agregar servicio: \(error.localizedDescription)")
            } else {
                self?.clearFields()
            }
        }
    }

    private func updateService(_ service: Service, withData data: [String: Any]) {
        guard let currentUserID = currentUserID else { return }
        
        db.collection("users").document(currentUserID).collection("services").document(service.id).updateData(data) { [weak self] error in
            if let error = error {
                print("Error al actualizar servicio: \(error.localizedDescription)")
            } else {
                self?.clearFields()
                self?.selectedServiceToEdit = nil
            }
        }
    }

    private func deleteService(_ service: Service) {
        guard let currentUserID = currentUserID else { return }
        
        db.collection("users").document(currentUserID).collection("services").document(service.id).delete { error in
            if let error = error {
                print("Error al eliminar servicio: \(error.localizedDescription)")
            }
        }
    }

    private func clearFields() {
        serviceNameTextField.text = ""
        serviceColorPicker.selectRow(0, inComponent: 0, animated: false)
        selectedServiceToEdit = nil
    }

    private func getServiceStatus(color: String) -> String {
        switch color {
        case "Verde": return "En proceso"
        case "Amarillo": return "Pensando"
        case "Rojo": return "Terminado"
        default: return "Desconocido"
        }
    }
}

// MARK: - UITableView DataSource & Delegate
extension MyProjectsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath)
        let service = serviceList[indexPath.row]
        cell.textLabel?.text = service.name
        cell.detailTextLabel?.text = service.status
        cell.backgroundColor = getColorForStatus(color: service.color)
        return cell
    }

    private func getColorForStatus(color: String) -> UIColor {
        switch color {
        case "Verde": return .green
        case "Amarillo": return .yellow
        case "Rojo": return .red
        default: return .white
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedService = serviceList[indexPath.row]
        serviceNameTextField.text = selectedService.name
        if let selectedIndex = colors.firstIndex(of: selectedService.color) {
            serviceColorPicker.selectRow(selectedIndex, inComponent: 0, animated: false)
        }
        selectedServiceToEdit = selectedService
    }
}

// MARK: - UIPickerView DataSource & Delegate
extension MyProjectsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return colors.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return colors[row]
    }
}

// MARK: - Service Model
class Service {
    var name: String
    var color: String
    var status: String
    var id: String
    
    init(name: String, color: String, status: String, id: String) {
        self.name = name
        self.color = color
        self.status = status
        self.id = id
    }
}
