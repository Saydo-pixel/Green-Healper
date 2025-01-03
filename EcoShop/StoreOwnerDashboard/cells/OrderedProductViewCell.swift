//
//  OrderedProductViewCell.swift
//  EcoShop
//
//  Created by user244986 on 12/9/24.
//

import UIKit

class OrderedProductViewCell: UITableViewCell {
    @IBOutlet var productQuantityLabel: UILabel!
    @IBOutlet var productPriceLabel: UILabel!
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var productNameLabel: UILabel!
    @IBOutlet var OrderedProductView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        OrderedProductView.layer.cornerRadius = 5
        OrderedProductView.layer.borderWidth = 1
        OrderedProductView.clipsToBounds = true
        
        productImageView.layer.cornerRadius = 5
        productImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
