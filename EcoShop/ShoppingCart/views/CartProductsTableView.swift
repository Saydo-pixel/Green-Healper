//
//  CartProductsTableView.swift
//  EcoShop
//
//  Created by user244986 on 12/23/24.
//

import UIKit

protocol CartProductsTableViewDelegate {
    func onQuantityChange(sender: CartProductsTableView, newPrice: Double, newCartProducts: [CartItem])
}

class CartProductsTableView: UITableView, UITableViewDataSource, UITableViewDelegate, CartProductTableViewCellDelegate  {
    var cart: Cart?
    var cartItems: [CartItem] = []
    var cartProducts: [StoreProduct] = []
    
    var parentDelegate: CartProductsTableViewDelegate?
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTableView()
    }
    
    private func setupTableView() {
        self.delegate = self
        self.dataSource = self
        
        tableFooterView = nil
        tableHeaderView = nil
        
        contentInset = .zero
        scrollIndicatorInsets = .zero
        estimatedRowHeight = 0
        estimatedSectionHeaderHeight = 0
        estimatedSectionFooterHeight = 0
        
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        } else {
            
        }
        
    }
    
    func changeQuantity(sender: CartProductTableViewCell, newQuantity: Int) {
        if let indexPath = indexPath(for: sender), var cart = self.cart {
            // Get the product and cart item
            let product = cartProducts[indexPath.row]
                
            if (newQuantity == 0) {
                // Remove items from arrays
                cartProducts.remove(at: indexPath.row)
                cartItems.remove(at: indexPath.row)
                // Reload table
                reloadData()
            }
            
            // Call cart's update quantity method
            Task {
                do {
                    try await cart.updateProductQuantity(
                        productId: product.id,
                        quantity: newQuantity
                    )
                    DispatchQueue.main.async{
                        self.parentDelegate?.onQuantityChange(sender: self, newPrice: cart.totalPrice, newCartProducts: cart.productIds)
                    }
                } catch {
                    print("Error updating quantity: \(error)")
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartProductIdentifier", for: indexPath) as! CartProductTableViewCell
        
        let cartItem = cartItems[indexPath.row]
        let product = cartProducts[indexPath.row]
        
        cell.productNameLabel.text = product.name
        cell.priceLabel.text = "\(product.price) BHD"
        cell.quantityLabel.text = String(cartItem.quantity)
        
        cell.product = product
        cell.delegate = self
        
        if let url = URL(string: product.imageURL) {
            URLSession.shared.dataTask(with: url) { (data, respnose, error) in
                guard let imageData = data else { return }
                DispatchQueue.main.async {
                    cell.productImageView.image = UIImage(data: imageData)
                }
            }.resume()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 178
    }
}
