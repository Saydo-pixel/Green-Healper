//
//  DashboardViewController.swift
//  EcoShop
//
//  Created by Hussain Almakana on 08/12/2024.
//

import UIKit

class DashboardViewController: UITableViewController {
    
    var isLoading = true;
    var userMetrics: [Metrics] = []
    
    @IBOutlet weak var numberOfItems: UITextField!
    @IBOutlet weak var CO2Emission: UITextField!
    @IBOutlet weak var waterConserved: UITextField!
    @IBOutlet weak var plasticWaste: UITextField!
    @IBOutlet weak var energySaved: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .background
        // Do any additional setup after loading the view.
        fetchAndPrint(startDate: nil)
        
        
    }
    
    func fetchAndPrint(startDate: Date?) {
        let userId = "b89889f7-6593-48f5-987e-8b459f45fcf2"
        
        Order.fetchUserMetrics(userId: userId, startDate: startDate) { result in
            switch result {
            case .success(let data):
                let metrics = data.metrics
                let itemCount = data.itemCount
                
                self.numberOfItems.text = "\(itemCount) Items included"
               
                if let energySaved = metrics.first(where: { $0.name == "Energy Saved" }) {
                    self.energySaved.text = "\(energySaved.value) \(energySaved.unit) of \(energySaved.name)"
                } else {
                    self.energySaved.text = "No data for Energy Saved"
                }
                
                if let co2 = metrics.first(where: { $0.name == "CO2 Emissions Saved" }) {
                    self.CO2Emission.text = "\(co2.value) \(co2.unit) of \(co2.name)"
                } else {
                    self.CO2Emission.text = "No data for CO2 Emission"
                }
                
                if let waterCons = metrics.first(where: {$0.name == "Water Conserved"}) {
                    self.waterConserved.text = "\(waterCons.value) \(waterCons.unit) of \(waterCons.name)"
                } else {
                    self.waterConserved.text = "No data for Water Conserved"
                }
                
                if let plasticWaste = metrics.first(where: {$0.name
                    == "Plastic Waste Reduced"}) {
                    self.plasticWaste.text = "\(plasticWaste.value) \(plasticWaste.unit) of \(plasticWaste.name)"
                } else {
                    self.plasticWaste.text = "No data for Plastic Waste Reduction"
                }
                
            case .failure(let error):
                print("Error fetching metrics: \(error.localizedDescription)")
            }
            }
            
        }

    
    @IBAction func dateRangeChanged(_ sender: UISegmentedControl) {
        let calendar = Calendar.current
            let now = Date()
            var startDate: Date? = nil

            // Determine the date range based on the selected segment
            switch sender.selectedSegmentIndex {
            case 0: // All Time
                startDate = nil
            case 1: // Yearly
                startDate = calendar.date(byAdding: .year, value: -1, to: now)
            case 2: // Monthly
                startDate = calendar.date(byAdding: .month, value: -1, to: now)
            case 3: // Daily
                startDate = calendar.date(byAdding: .day, value: -1, to: now)
            default:
                startDate = nil
            }

            // Fetch metrics with the specified startDate
            fetchAndPrint(startDate: startDate)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

