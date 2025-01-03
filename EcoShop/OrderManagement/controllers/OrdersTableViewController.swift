//
//  OrdersTableViewController.swift
//  EcoShop
//
//  Created by user244986 on 12/21/24.
//

import UIKit

class OrdersTableViewController: UITableViewController, StatusPickerTableViewCellDelegate, OrderTableViewCellDelegate {
    
    var orders: [StoreOrder] = []
    let userId = "b89889f7-6593-48f5-987e-8b459f45fcf2"

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchOrders(status: StoreOrder.OrderStatus.pending)
    }
    
    func onStatusChanged(status: StoreOrder.OrderStatus) {
        fetchOrders(status: status)
    }
    
    func onCancelOrder(sender: OrderTableViewCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            // Create and present alert
            let alert = UIAlertController(
                title: "Cancel Order",
                message: "Are you sure you want to cancel this order?",
                preferredStyle: .alert
            )
            
            // Cancel action
            alert.addAction(UIAlertAction(title: "No", style: .cancel))
            
            // Confirm action
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
                // Your existing logic here
                sender.cancelOrderButton.isEnabled.toggle()
                Task {
                    do {
                        let order = self?.orders[indexPath.row - 2]
                        try await StoreOrder.updateOrderStatus(orderId: order?.id ?? "", newStatus: StoreOrder.OrderStatus.cancelled)
                    } catch {
                        print("Error updating status of order: \(error)")
                    }
                    
                    DispatchQueue.main.async {
                        sender.cancelOrderButton.isEnabled.toggle()
                        self?.orders.remove(at: indexPath.row - 2)
                        self?.tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            })
            
            // Present alert
            present(alert, animated: true)
        }
    }
    
    func fetchOrders(status: StoreOrder.OrderStatus) {
        Task {
            do {
                orders = try await StoreOrder.fetchOrders(forUser: userId, status: status)
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
            } catch {
                print("Error fetching orders: \(error)")
            }
        }
    }
 
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + orders.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0 || indexPath.row == 1) {
            let identifier = indexPath.row == 0 ? "OrdersHeading" : "SegmentedControl";
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(identifier)Identifier", for: indexPath)
            
            if let cell = cell as? StatusPickerTableViewCell {
                cell.delegate = self
            }
            
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderIdentifier", for: indexPath) as? OrderTableViewCell else {
            return UITableViewCell()
        }
        
        let order = orders[indexPath.row - 2]
        
        cell.orderIDLabel.text = "Order ID: \(String(order.id.prefix(5).uppercased()))"

        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let formattedDate = "Date: \(formatter.string(from: order.dateOrdered))"

       cell.orderDateLabel.text = formattedDate

        cell.orderStatusLabel.text = order.status.rawValue.uppercased(with: .autoupdatingCurrent)
        cell.orderTotalPriceLabel.text = "\(round(order.totalPrice)) BD"
        cell.delegate = self
        
        cell.cancelOrderButton.isHidden = (order.status == StoreOrder.OrderStatus.cancelled || order.status == StoreOrder.OrderStatus.completed)
        
        switch order.status {
        case .inFlight:
            cell.orderStatusLabel.textColor = .systemBlue  // IN FLIGHT - Blue color
        case .pending:
            cell.orderStatusLabel.textColor = .yellow      // PENDING - Orange/Yellow color
        case .completed:
            cell.orderStatusLabel.textColor = .systemGreen // COMPLETED - Green color
        case .cancelled:
            cell.orderStatusLabel.textColor = .red         // CANCELLED - Red color
        }
        
        Task {
            do {
                let orderedProducts = try await order.fetchOrderProducts()

                DispatchQueue.main.async{
                    cell.orderProductsTable.orderedProducts = orderedProducts
                    cell.orderProductsTable.reloadData()
                }
            } catch {
                print("Error fetching ordered products: \(error)")
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0 || indexPath.row == 1) {
            return indexPath.row == 0 ? 50 : 65
        }

        return 435
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
