//
//  CheckoutProductsTableView.swift
//  EcoShop
//
//  Created by user244986 on 12/24/24.
//

import UIKit

class CheckoutProductsTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    var checkoutProducts: [StoreProduct] = []
    var cartItems: [CartItem] = []
    
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkoutProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckoutProductIdentifier", for: indexPath) as! CheckoutProductTableViewCell
        
        let product = checkoutProducts[indexPath.row]
        let cartItem = cartItems[indexPath.row]
        
        cell.productName.text = product.name
        cell.priceLabel.text = "\(product.price) BHD"
        cell.quantityLabel.text = "Qty: \(cartItem.quantity)"
        
        if let url = URL(string: product.imageURL) {
            URLSession.shared.dataTask(with: url) { (data, respnose, error) in
                guard let imageData = data else { return }
                DispatchQueue.main.async {
                    cell.productIamge.image = UIImage(data: imageData)
                }
            }.resume()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 121
    }
}
