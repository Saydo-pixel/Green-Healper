//
//  StoreOrdersTableViewController.swift
//  EcoShop
//
//  Created by user244986 on 12/9/24.
//

import UIKit

class StoreOrdersTableViewController: UITableViewController, OrderedViewCellDelegate {
    var orders: [StoreOrder] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                orders = try await StoreOrder.fetchOrders(forOwner: "owner1")
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
            } catch {
                print("Error fetching orders: \(error)")
            }
        }

    }

    // MARK: - Table view data source
    
    func onStatusChanged(sender: OrderedViewCell, status: StoreOrder.OrderStatus) {
        if let indexPath = tableView.indexPath(for: sender) {
            sender.orderStatusButton.isEnabled.toggle()
            Task {
                do {
                    let order = orders[indexPath.row - 1]
                    try await StoreOrder.updateOrderStatus(orderId: order.id, newStatus: status)
                } catch {
                    print("Error updating status of order: \(error)")
                }
                DispatchQueue.main.async{
                    sender.orderStatusButton.isEnabled.toggle()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1 + orders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = indexPath.row == 0 ? "OrdersHeading" : "StoreOrder"
        
        guard indexPath.row > 0 else {
            return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! OrderedViewCell
        let order = orders[indexPath.row - 1]
        
        cell.orderIdLabel.text = "Order ID: \(String(order.id.prefix(5).uppercased()))"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let formattedDate = "Date: \(formatter.string(from: order.dateOrdered))"

        cell.orderDateLabel.text = formattedDate
        
        cell.orderStatusButton.titleLabel?.text = order.status.rawValue
        cell.orderTotalPriceLabel.text = "\(order.totalPrice) BD"
        
        cell.delegate = self
        
        Task {
            do {
                let orderedProducts = try await order.fetchOrderProducts()

                DispatchQueue.main.async{
                    cell.orderedProductsTable.orderedProducts = orderedProducts
                    cell.orderedProductsTable.reloadData()
                }
            } catch {
                print("Error fetching ordered products: \(error)")
            }
        }
 
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return UITableView.automaticDimension
        }
        
        return 460
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
