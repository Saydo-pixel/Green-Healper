//
//  CartProductTableViewCell.swift
//  EcoShop
//
//  Created by user244986 on 12/23/24.
//

import UIKit

protocol CartProductTableViewCellDelegate {
    func changeQuantity(sender: CartProductTableViewCell, newQuantity: Int)
}

class CartProductTableViewCell: UITableViewCell {
    var delegate: CartProductTableViewCellDelegate?
    
    var product: StoreProduct?
    
    
    @IBOutlet var productCardView: UIView!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var quantityLabel: UILabel!
    @IBOutlet var productNameLabel: UILabel!
    @IBOutlet var productImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        productCardView.layer.cornerRadius = 10
        productCardView.clipsToBounds = true
        
        productImageView.layer.cornerRadius = 10
        productImageView.clipsToBounds = true
   }

    @IBAction func decrementQuantity(_ sender: UIButton) {
        if let int = Int(quantityLabel.text ?? "") {
            if int <= 1 {
                let alert = UIAlertController(
                    title: "Remove Product",
                    message: "Are you sure you want to remove this product from cart?",
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
                    self?.quantityLabel.text = "\(int - 1)"
                    // Call delegate with new quantity 0
                    self?.delegate?.changeQuantity(sender: self!, newQuantity: 0)
                })
                
                if let viewController = self.findViewController() {
                    viewController.present(alert, animated: true)
                }
            } else {
                quantityLabel.text = "\(int - 1)"
                // Call delegate with decremented quantity
                delegate?.changeQuantity(sender: self, newQuantity: int - 1)
            }
        }
    }
    
    private func findViewController() -> UIViewController? {
            var responder: UIResponder? = self
            while let nextResponder = responder?.next {
                if let viewController = nextResponder as? UIViewController {
                    return viewController
                }
                responder = nextResponder
            }
            return nil
    }
    
    @IBAction func incrementQuantity(_ sender: UIButton) {
        if let int = Int(quantityLabel.text ?? "") {
            if int + 1 > product?.stockQuantity ?? 0 {
                let alert = UIAlertController(
                    title: "Insufficient Stock",
                    message: "Sorry, there are only \(product?.stockQuantity ?? 0) items available in stock.",
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                if let viewController = self.findViewController() {
                    viewController.present(alert, animated: true)
                }
            } else {
                quantityLabel.text = "\(int + 1)"
                // Call delegate with incremented quantity
                delegate?.changeQuantity(sender: self, newQuantity: int + 1)
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
