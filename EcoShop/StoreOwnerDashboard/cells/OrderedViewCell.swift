//
//  OrderedViewCell.swift
//  EcoShop
//
//  Created by user244986 on 12/9/24.
//

import UIKit

protocol OrderedViewCellDelegate: AnyObject {
    func onStatusChanged(sender: OrderedViewCell, status: StoreOrder.OrderStatus)
}

class OrderedViewCell: UITableViewCell {
    var delegate: OrderedViewCellDelegate?

    @IBOutlet var orderView: UIView!
    @IBOutlet var orderStatusButton: UIButton!
    @IBOutlet var orderDateLabel: UILabel!
    @IBOutlet var orderIdLabel: UILabel!
    @IBOutlet var orderTotalPriceLabel: UILabel!
    @IBOutlet var orderedProductsTable: OrderedProductsTableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        orderView.layer.cornerRadius = 8
        setupStatusMenu()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func onStatusChange(_ status: String) {
        orderStatusButton.setTitle(status, for: .normal)
        if let newStatus = StoreOrder.OrderStatus(rawValue: status) {
              delegate?.onStatusChanged(sender: self, status: newStatus)
          }
    }
    
    func setupStatusMenu(){
        let actions = [
            UIAction(title: "Dispatched", handler: { [weak self] _ in
                self?.onStatusChange("Dispatched")
            }),
            UIAction(title: "In Flight", handler: { [weak self] _ in
                self?.onStatusChange("In Flight")
            }),
            UIAction(title: "Completed", handler: { [weak self] _ in
                self?.onStatusChange("Completed")
            }),
            UIAction(title: "Cancelled", handler: { [weak self] _ in
                self?.onStatusChange("Cancelled")
            })
        ]
        
        orderStatusButton.menu = UIMenu(children: actions)
        orderStatusButton.showsMenuAsPrimaryAction = true
    }

}
