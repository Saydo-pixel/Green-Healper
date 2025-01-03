//
//  StoreProdcutsController.swift
//  EcoShop
//
//  Created by user244986 on 12/3/24.
//

import UIKit

class StoreProdcutsController: UITableViewController, StoreProductActionsDelegate {
    var storeProducts = [StoreProduct]()
    var searchTerm = ""
    
    func onSearch(sender: UITextField) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.searchTerm = sender.text ?? ""
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                sender.becomeFirstResponder()
            }
            self?.tableView.reloadData()
            CATransaction.commit()
        }
    }
    
    var filteredStoreProducts: [StoreProduct] {
        get {
            return storeProducts.filter({ searchTerm.isEmpty || $0.name.lowercased().contains(searchTerm.lowercased()) })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        Task {
            do {
                storeProducts = try await StoreProduct.fetchProducts(forOwnerId: "owner1")
 
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
            } catch {
                print("Error fetching products: \(error)")
            }
        }
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2 + filteredStoreProducts.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductsHeading", for: indexPath)
            return cell
        }
        
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchAndAdd", for: indexPath) as! StoreProductActionsCell
            cell.delegate = self
        
            return cell
        }
        
        let storeProduct = filteredStoreProducts[indexPath.row - 2]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Product", for: indexPath) as! StoreProductCell
        cell.productNameLabel.text = storeProduct.name
        cell.quantityLabel.text = "Stock: \(storeProduct.stockQuantity)"
        cell.priceLabel.text = "\(storeProduct.price) BD"
        setImageFromStringURL(imageURL: storeProduct.imageURL, sender: cell)
        
        return cell
    }
    
    func setImageFromStringURL(imageURL: String, sender: StoreProductCell) {
        if let url = URL(string: imageURL) {
            URLSession.shared.dataTask(with: url) { (data, respnose, error) in
                guard let imageData = data else { return }
                DispatchQueue.main.async {
                    sender.productImage.image = UIImage(data: imageData)
                }
            }.resume()
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return UITableView.automaticDimension
        }
        if indexPath.row == 1 {
            return 65
        }
        return 165
    }
    
    @IBAction func unwindToStoreProducts(segue: UIStoryboardSegue) {
        let sourceViewController = segue.source as! StoreProductDetailTableViewController
        
        if let storeProduct = sourceViewController.storeProduct {
            Task {
                do {
                    try await storeProduct.saveProduct()
                    
                    DispatchQueue.main.async {
                        if let indexStoreProductIndex = self.storeProducts.firstIndex(where: { $0.id == storeProduct.id }) {
                            self.storeProducts[indexStoreProductIndex] = storeProduct
                            if let indexFilteredStoreProductIndex = self.filteredStoreProducts.firstIndex(where: { $0.id == storeProduct.id }) {
                                self.tableView.reloadRows(at: [IndexPath(row: indexFilteredStoreProductIndex + 2, section: 0)], with: .automatic)
                            }
                        } else {
                            self.storeProducts.insert(storeProduct, at: 0)
                            self.tableView.reloadData()
                        }
                    }
                } catch {
                    print("Error saving product: \(error)")
                }
            }
        }
    }

    @IBSegueAction func editStoreProduct(_ coder: NSCoder, sender: Any?) -> StoreProductDetailTableViewController? {
        let detailController = StoreProductDetailTableViewController(coder: coder)
        
        guard let button = sender as? UIButton else {
            return detailController
        }
        
        guard button.titleLabel?.text == "EDIT" else {
            return detailController
        }
        
        if let indexPath = tableView.indexPath(for: button.superview?.superview?.superview as! UITableViewCell) {
            detailController?.storeProduct = filteredStoreProducts[indexPath.row - 2]
        }
        
        return detailController
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
