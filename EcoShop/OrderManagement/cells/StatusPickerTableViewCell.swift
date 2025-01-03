//
//  StatusPickerTableViewCell.swift
//  EcoShop
//
//  Created by user244986 on 12/21/24.
//

import UIKit

protocol StatusPickerTableViewCellDelegate {
    func onStatusChanged(status: StoreOrder.OrderStatus)
}

class StatusPickerTableViewCell: UITableViewCell {
    var delegate: StatusPickerTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onStatusChange(_ sender: UISegmentedControl) {
        if let title = sender.titleForSegment(at: sender.selectedSegmentIndex),
           let status = StoreOrder.OrderStatus(rawValue: title) {
            delegate?.onStatusChanged(status: status)
        }
    }
}
