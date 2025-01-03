//
//  CartTableViewController.swift
//  EcoShop
//
//  Created by user244986 on 12/23/24.
//

import UIKit

class CartTableViewController: UITableViewController, CartProductsTableViewDelegate {
    let userId = "b89889f7-6593-48f5-987e-8b459f45fcf2"

    var cart: Cart?
    @IBOutlet var cartProductsTable: CartProductsTableView!
    @IBOutlet var totalPriceLabel: UILabel!
    
    @IBOutlet var checkoutBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cartProductsTable.parentDelegate = self
        checkoutBtn.isEnabled.toggle()

        Task {
            do {
                var cart = try await Cart.fetchCart(forUser: self.userId)

                let products = try await cart?.fetchCartProducts()
                
                self.cart = cart
                cartProductsTable.cart = cart
                cartProductsTable.cartItems = self.cart?.productIds ?? []
                cartProductsTable.cartProducts = products ?? []
                
                DispatchQueue.main.async{
                    self.totalPriceLabel.text = "\(round(self.cart?.totalPrice ?? 0)) BD"
                    self.checkoutBtn.isEnabled.toggle()
                    self.cartProductsTable.reloadData()
                }
            } catch {
                print("Error fetching cart: \(error)")
            }
        }
    }
    
    func onQuantityChange(sender: CartProductsTableView, newPrice: Double, newCartProducts: [CartItem]) {
        cart?.updateTotalPrice(newPrice)
        cart?.productIds = newCartProducts
        
        self.totalPriceLabel.text = "\(round(newPrice)) BD"
    }

    
    @IBSegueAction func checkout(_ coder: NSCoder, sender: Any?) -> CheckoutTableViewController? {
        let checkoutController = CheckoutTableViewController(coder: coder)

        checkoutController?.cart = cart
        checkoutController?.checkoutProducts = cartProductsTable.cartProducts
        
        return checkoutController
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections*
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    @IBAction func checkout(_ sender: UIButton) {
        if let checkoutVC = storyboard?.instantiateViewController(withIdentifier: "CheckoutViewController") as? CheckoutTableViewController{
            checkoutVC.cart = cart
            checkoutVC.checkoutProducts = cartProductsTable.cartProducts
            
            print("Price: \(checkoutVC.cart?.totalPrice ?? 0)")
            
            navigationController?.pushViewController(checkoutVC, animated: true)
            tableView.reloadData()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
