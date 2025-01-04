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
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var serviceColorPicker: UIPickerView!
    
    var serviceList = [Service]()
    var db: Firestore!
    var currentUserID: String?
    var colors = ["Searching a Pro", "Currently working", "Job done"] // Colores disponibles para PickerView
    var selectedServiceToEdit: Service?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        currentUserID = Auth.auth().currentUser?.uid
        
        // Obtener el correo electrónico del usuario actual y asignarlo al UILabel
        if let userEmail = Auth.auth().currentUser?.email {
            emailLabel.text = userEmail
        }
        
        // Configurar PickerView y TableView
        setupPickerView()
        setupTableView()
        loadServices()
        
        // Añadir gesto de tap para ocultar teclado al tocar fuera del TextField
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Agregar el placeholder al TextField
        serviceNameTextField.placeholder = "Insert a project"
    }
    
    @objc func dismissKeyboard() {
        serviceNameTextField.resignFirstResponder()
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

    @IBAction func addServiceButtonTapped(_ sender: UIButton) {
        guard let serviceName = serviceNameTextField.text, !serviceName.isEmpty else {
            let alert = UIAlertController(title: "No Project Inserted", message: "Please insert a project before adding a service.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
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
                print("Error deleting service: \(error.localizedDescription)")
            } else {
                print("Service deleted successfully")
            }
        }
    }

    @IBAction func deleteServiceButtonTapped(_ sender: UIButton) {
        // Verificar si hay un servicio seleccionado
        guard let selectedService = selectedServiceToEdit else {
            let alert = UIAlertController(title: "No Service Selected", message: "Please select a service before trying to delete.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        // Confirmar la eliminación
        let alert = UIAlertController(title: "Are you sure?", message: "Are you sure you want to delete this service?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteService(selectedService)
            self?.clearFields()
        }))
        present(alert, animated: true)
    }

    private func clearFields() {
        serviceNameTextField.text = ""
        serviceColorPicker.selectRow(0, inComponent: 0, animated: false)
        selectedServiceToEdit = nil
    }

    private func getServiceStatus(color: String) -> String {
        switch color {
        case "Searching a Pro": return "Searching"
        case "Currently working": return "Working"
        case "Job done": return "Done"
        default: return "Unknown"
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
        case "Searching a Pro": return .green
        case "Currently working": return .yellow
        case "Job done": return .red
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
