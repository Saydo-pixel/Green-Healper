//
//  CheckoutProductTableViewCell.swift
//  EcoShop
//
//  Created by user244986 on 12/24/24.
//

import UIKit

class CheckoutProductTableViewCell: UITableViewCell {

    @IBOutlet var productIamge: UIImageView!
    @IBOutlet var quantityLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var productName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
