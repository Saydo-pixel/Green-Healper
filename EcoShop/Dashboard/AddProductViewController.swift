//
//  AddProductToDashboardForm.swift
//  EcoShop
//
//  Created by Hussain Almakana on 09/12/2024.
//

import UIKit

class AddProductViewController: UITableViewController {

    @IBOutlet weak var productNameInput: UITextField!
    @IBOutlet weak var CO2EmissionInput: UITextField!
    @IBOutlet weak var WaterConservedInput: UITextField!
    @IBOutlet weak var PlasticWasteInput: UITextField!
    @IBOutlet weak var EnergySavedInput: UITextField!
    @IBOutlet weak var AmountBroughtInput: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = .background
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func onProductSubmission(_ sender: Any) {
        
        // get the product name, if it's not empty proceed else display alert message
        guard let productName = productNameInput.text, !productName.isEmpty else {
            showAlertMessageBox(title: "Error", message: "Product name is required" )
            return
        }
        
        // get the CO2 Emission and convert it into Int if it fails show error message
        guard let CO2EmissionText = CO2EmissionInput.text, let CO2Emission = Int(CO2EmissionText) else {
            showAlertMessageBox(title: "Error", message: "Invalid CO2 Emission value")
            return
        }
        
        guard let waterConservedText = WaterConservedInput.text,
                  let waterConserved = Int(waterConservedText) else {
                showAlertMessageBox(title: "Error", message: "Invalid water conserved value")
                return
            }
        
        guard let plasticWasteText = PlasticWasteInput.text,
              let plasticWaste = Int(plasticWasteText) else {
            showAlertMessageBox(title: "Error", message: "Invalid plastic waste value")
            return
        }
        
        guard let energySavedText = EnergySavedInput.text,
                  let energySaved = Int(energySavedText) else {
                showAlertMessageBox(title: "Error", message: "Invalid energy saved value")
                return
            }
        
        guard let amountBroughtText = AmountBroughtInput.text,
              let amountBrought = Int(amountBroughtText) else {
            showAlertMessageBox(title: "Error", message: "Invalid Number of amounts brought")
            return
        }
        
        let metrics = [
               Metrics(name: "CO2 Emissions Saved", unit: "kg", value: CO2Emission),
               Metrics(name: "Water Conserved", unit: "liters", value: waterConserved),
               Metrics(name: "Plastic Waste Reduced", unit: "kg", value: plasticWaste),
               Metrics(name: "Energy Saved", unit: "kWh", value: energySaved)
           ]
        
            let productMetric = ProductMetric(
                productName: productName,
                metrics: metrics,
                quantity: amountBrought,
                userId: "b89889f7-6593-48f5-987e-8b459f45fcf2"
            )
        
        // Save the product metric
            ProductMetric.SaveProductMetric(productMetric) { result in
                switch result {
                case .success:
                    self.showAlertMessageBox(title: "Success", message: "Product added successfully!")
                case .failure(let error):
                    self.showAlertMessageBox(title: "Error", message: "Failed to save product: \(error.localizedDescription)")
                }
            }
}
    
    func showAlertMessageBox(title: String, message: String) {
        // Create the alert controller
           let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
           
           // Add a default "OK" action
           let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
           alertController.addAction(okAction)
           
           // Present the alert controller
           self.present(alertController, animated: true, completion: nil)
    }
}
