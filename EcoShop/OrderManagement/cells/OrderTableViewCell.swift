//
//  OrderTableViewCell.swift
//  EcoShop
//
//  Created by user244986 on 12/22/24.
//

import UIKit

protocol OrderTableViewCellDelegate {
    func onCancelOrder(sender: OrderTableViewCell)
}

class OrderTableViewCell: UITableViewCell {
    var delegate: OrderTableViewCellDelegate?

    @IBOutlet var cancelOrderButton: UIButton!
    @IBOutlet var orderTotalPriceLabel: UILabel!
    @IBOutlet var orderProductsTable: OrderedProductsTableView!
    @IBOutlet var orderStatusLabel: UILabel!
    @IBOutlet var orderDateLabel: UILabel!
    @IBOutlet var orderIDLabel: UILabel!
    @IBOutlet var orderView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        orderView.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func cancelOrder(_ sender: UIButton) {
        delegate?.onCancelOrder(sender: self)
    }
    
}
