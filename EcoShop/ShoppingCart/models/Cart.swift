//
//  Cart.swift
//  EcoShop
//
//  Created by user244986 on 12/23/24.
//

import Foundation
import FirebaseFirestore

struct CartItem {
   let id: String
   var quantity: Int
}

struct Cart: Identifiable {
   let id: String
   let userId: String
   var productIds: [CartItem]
   private(set) var totalPrice: Double = 0
   
   init?(document: DocumentSnapshot) {
       guard
           let data = document.data(),
           let userId = data["userId"] as? String,
           let productIdsData = data["productIds"] as? [[String: Any]] else {
               return nil
       }
       
       self.id = document.documentID
       self.userId = userId
       self.productIds = productIdsData.compactMap { dict in
           guard
               let id = dict["id"] as? String,
               let quantity = dict["quantity"] as? Int else {
                   return nil
           }
           return CartItem(id: id, quantity: quantity)
       }
   }
   
    // Fetch cart for specific user
    static func fetchCart(forUser userId: String) async throws -> Cart? {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("carts")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        return snapshot.documents.first.flatMap { Cart(document: $0) }
    }
    
    // Add new cart for user
    static func createCart(userId: String) async throws -> Cart {
        let db = Firestore.firestore()
        let newCart = [
            "userId": userId,
            "productIds": []
        ] as [String : Any]
        
        let docRef = try await db.collection("carts").addDocument(data: newCart)
        let doc = try await docRef.getDocument()
        
        guard let cart = Cart(document: doc) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create cart"])
        }
        
        return cart
    }
    
    mutating func emptyCart() async throws {
        let db = Firestore.firestore()
        
        // Update Firestore document with empty cart
        try await db.collection("carts").document(id).updateData([
            "productIds": []
        ])
        
        // Update local properties
        self.productIds = []
        self.updateTotalPrice(0)
    }
    
   mutating func updateTotalPrice(_ price: Double) {
       self.totalPrice = price
   }
   
   func recalculateTotalPrice(withProducts products: [StoreProduct]) -> Double {
       var total: Double = 0
       for cartItem in productIds {
           if let product = products.first(where: { $0.id == cartItem.id }) {
               total += product.price * Double(cartItem.quantity)
           }
       }
       return total
   }
   
    mutating func updateProductQuantity(productId: String, quantity: Int) async throws {
        let db = Firestore.firestore()
        
        // First fetch the product to check stock
        let productDoc = try await db.collection("products").document(productId).getDocument()
        
        guard let productData = productDoc.data(),
              let stockQuantity = productData["stockQuantity"] as? Int else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid product data"])
        }
        
        if quantity > stockQuantity {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Requested quantity exceeds available stock"])
        }
        
        var updatedProductIds = self.productIds
        let productPrice = productData["price"] as? Double ?? 0
        
        if quantity <= 0 {
            // If removing product, subtract its total contribution to price
            if let existingItem = productIds.first(where: { $0.id == productId }) {
                let priceReduction = productPrice * Double(existingItem.quantity)
                updateTotalPrice(totalPrice - priceReduction)
            }
            updatedProductIds.removeAll { $0.id == productId }
        } else {
            if let index = updatedProductIds.firstIndex(where: { $0.id == productId }) {
                // Update existing item
                let oldQuantity = updatedProductIds[index].quantity
                let quantityDiff = quantity - oldQuantity
                let priceDiff = productPrice * Double(quantityDiff)
                updateTotalPrice(totalPrice + priceDiff)
                updatedProductIds[index].quantity = quantity
            } else {
                // Add new item
                updatedProductIds.append(CartItem(id: productId, quantity: quantity))
                let priceIncrease = productPrice * Double(quantity)
                updateTotalPrice(totalPrice + priceIncrease)
            }
        }
        
        // Update Firestore
        try await db.collection("carts").document(id).updateData([
            "productIds": updatedProductIds.map { [
                "id": $0.id,
                "quantity": $0.quantity
            ]}
        ])
        
        productIds = updatedProductIds
    }
    mutating func fetchCartProducts() async throws -> [StoreProduct] {
       let db = Firestore.firestore()
       var products: [StoreProduct] = []
       
       for cartItem in self.productIds {
           let doc = try await db.collection("products").document(cartItem.id).getDocument()
           if doc.exists, let data = doc.data() {
               let product = StoreProduct(
                   id: doc.documentID,
                   storeOwnerId: data["storeOwnerId"] as? String ?? "",
                   name: data["name"] as? String ?? "",
                   imageURL: data["imageURL"] as? String ?? "",
                   stockQuantity: data["stockQuantity"] as? Int ?? 0,
                   price: data["price"] as? Double ?? 0,
                   description: data["description"] as? String ?? "",
                   metrics: data["metrics"] as? [[String : Any]] ?? []
               )
               products.append(product)
           }
       }
       
       // Calculate initial total price
       let initialTotal = recalculateTotalPrice(withProducts: products)
       updateTotalPrice(initialTotal)
       
       return products
   }
    
    static func addProductToCart(userId: String, productId: String, quantity: Int) async throws {
           let db = Firestore.firestore()
           
           // First check if user has a cart
           let cartSnapshot = try await db.collection("carts")
               .whereField("userId", isEqualTo: userId)
               .getDocuments()
           
           if let existingCart = cartSnapshot.documents.first {
               // Get existing product IDs
               var productIds = existingCart.data()["productIds"] as? [[String: Any]] ?? []
               
               // Check if product already exists in cart
               if let index = productIds.firstIndex(where: { ($0["id"] as? String) == productId }) {
                   // Update quantity
                   productIds[index]["quantity"] = quantity
               } else {
                   // Add new product
                   productIds.append([
                       "id": productId,
                       "quantity": quantity
                   ])
               }
               
               // Update cart
               try await db.collection("carts").document(existingCart.documentID).updateData([
                   "productIds": productIds
               ])
               
           } else {
               // Create new cart for user
               try await db.collection("carts").addDocument(data: [
                   "userId": userId,
                   "productIds": [[
                       "id": productId,
                       "quantity": quantity
                   ]]
               ])
           }
    }
}
