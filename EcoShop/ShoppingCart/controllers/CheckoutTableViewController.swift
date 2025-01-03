//
//  CheckoutTableViewController.swift
//  EcoShop
//
//  Created by user244986 on 12/24/24.
//

import UIKit

class CheckoutTableViewController: UITableViewController {
    var cart: Cart?
    var checkoutProducts: [StoreProduct] = []
    
    @IBOutlet var subtotalAmountLabel: UILabel!
    @IBOutlet var deliveryAmountLabel: UILabel!
    @IBOutlet var totalCheckoutLabel: UILabel!
    @IBOutlet var deliveryNotesTextView: UITextView!
    @IBOutlet var cashRadio: UIButton!
    @IBOutlet var benefitPayRadio: UIButton!
    @IBOutlet var applyPayRadio: UIButton!
    @IBOutlet var cardRadio: UIButton!
    @IBOutlet var checkoutProductsTable: CheckoutProductsTableView!
    
    var shouldHideCell: Bool = false
    let cardDetailsIndexPath = IndexPath(row: 3, section: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = nil
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        
        checkoutProductsTable.cartItems = cart?.productIds ?? []
        checkoutProductsTable.checkoutProducts = checkoutProducts
        
        deliveryNotesTextView.layer.cornerRadius = 10
        deliveryNotesTextView.layer.borderWidth = 1
        deliveryNotesTextView.layer.borderColor = UIColor.gray.cgColor
        deliveryNotesTextView.clipsToBounds = true
        
        cardRadio.isSelected.toggle()
        
        if let price = cart?.totalPrice {
            subtotalAmountLabel.text = "\(round(price)) BD"
            deliveryAmountLabel.text = "5 BD"
            totalCheckoutLabel.text = "\(round(price) + 5) BD"
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func onConfirmCheckout(_ sender: UIButton) {
        sender.isEnabled = false
        
        Task<Void, Never> {
            do {
                
                let orderedProducts = cart?.productIds.map({ StoreOrder.OrderProduct(id: $0.id, quantity: $0.quantity) }) ?? []
                let userId = "b89889f7-6593-48f5-987e-8b459f45fcf2"

                guard var cart = self.cart else { return }
                
                // Create and save order
                let order = StoreOrder(
                    id: UUID().uuidString,
                    storeOwnerId: "storeOwnerId",
                    userId: userId,
                    totalPrice: cart.totalPrice,
                    status: .pending,
                    dateOrdered: Date(),
                    products: orderedProducts
                )
                
                try await order.saveOrder() // Your save method
                try await cart.emptyCart()
                                
                 // Navigate on main thread after successful save
                await MainActor.run {
                    if let orderConfirmationVC = storyboard?.instantiateViewController(withIdentifier: "OrderConfirmationViewController") {
                        navigationController?.pushViewController(orderConfirmationVC, animated: true)
                    }
                }
                
            } catch {
                // Handle error and show alert
                await MainActor.run {
                    sender.isEnabled = true
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Failed to save order: \(error.localizedDescription)",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    present(alert, animated: true)
                }
            }
        }

    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
    }

    @IBAction func cashOnDeliveryToogle(_ sender: UIButton) {
        sender.isSelected = true
        benefitPayRadio.isSelected = false
        applyPayRadio.isSelected = false
        cardRadio.isSelected = false
        
        shouldHideCell = true
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func benefitPayToggle(_ sender: UIButton) {
        sender.isSelected = true
        cashRadio.isSelected = false
        applyPayRadio.isSelected = false
        cardRadio.isSelected = false
        
        shouldHideCell = true
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func radioSelected(_ sender: UIButton) {
        sender.isSelected = true
        benefitPayRadio.isSelected = false
        cashRadio.isSelected = false
        cardRadio.isSelected = false
        
        shouldHideCell = true
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func cardSelected(_ sender: UIButton) {
        sender.isSelected = true
        benefitPayRadio.isSelected = false
        applyPayRadio.isSelected = false
        cashRadio.isSelected = false
        
        shouldHideCell = false
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 320
        case 1:
            return 338
        case 2:
            return 332
        case 3 where shouldHideCell == false:
            return 332
        case 3 where shouldHideCell == true:
            return 0
        case 4:
            return 252
        case 5:
            return 203
        case 6:
            return 53
        default:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
