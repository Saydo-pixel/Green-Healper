//
//  OrderedProductsTableView.swift
//  EcoShop
//
//  Created by user244986 on 12/9/24.
//

import UIKit

class OrderedProductsTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    var orderedProducts: [StoreProduct] = []
    
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
        return orderedProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderedProduct", for: indexPath) as! OrderedProductViewCell
        let orderedProduct = orderedProducts[indexPath.row]
        
        cell.productNameLabel.text = orderedProduct.name
        cell.productPriceLabel.text = "\(orderedProduct.price) BD"
        cell.productQuantityLabel.text = "Qty: \(orderedProduct.stockQuantity)"
        
        if let url = URL(string: orderedProduct.imageURL) {
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
        return 157
    }

}
