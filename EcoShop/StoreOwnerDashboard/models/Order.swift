//
//  StoreOrder.swift
//  EcoShop
//
//  Created by user244986 on 12/9/24.
//

import Foundation
import FirebaseFirestore

struct StoreOrder: Identifiable {
   let id: String
   let products: [OrderProduct]
   let storeOwnerId: String
   let userId: String
   let totalPrice: Double
   let status: OrderStatus
   let dateOrdered: Date
   
   struct OrderProduct {
       let id: String
       let quantity: Int
   }
   
   enum OrderStatus: String {
       case completed = "Completed"
       case pending = "Pending"
       case inFlight = "In Flight"
       case cancelled = "Cancelled"
   }
    
    init(id: String = UUID().uuidString,
         storeOwnerId: String,
         userId: String,
         totalPrice: Double,
         status: OrderStatus,
         dateOrdered: Date,
         products: [OrderProduct]
    ) {
        self.id = id
        self.userId = userId
        self.storeOwnerId = storeOwnerId
        self.totalPrice = totalPrice
        self.status = status
        self.dateOrdered = dateOrdered
        self.products = products
    }
   
   init?(document: QueryDocumentSnapshot) {
       guard
           let storeOwnerId = document.data()["storeOwnerId"] as? String,
           let userId = document.data()["userId"] as? String,
           let totalPrice = document.data()["totalPrice"] as? Double,
           let statusString = document.data()["status"] as? String,
           let timestamp = document.data()["dateOrdered"] as? Timestamp,
           let productsData = document.data()["products"] as? [[String: Any]] else {
               return nil
       }
       
       self.id = document.documentID
       self.storeOwnerId = storeOwnerId
       self.userId = userId
       self.totalPrice = totalPrice
       self.status = OrderStatus(rawValue: statusString) ?? .pending
       self.dateOrdered = timestamp.dateValue()
       self.products = productsData.compactMap { dict in
           guard
               let id = dict["id"] as? String,
               let quantity = dict["quantity"] as? Int else {
                   return nil
           }
           return OrderProduct(id: id, quantity: quantity)
       }
   }
    
    static func fetchProductsForOrder(productIds: [String]) async throws -> [StoreProduct] {
        let db = Firestore.firestore()
        var products: [StoreProduct] = []
        
        for id in productIds {
            let doc = try await db.collection("products").document(id).getDocument()
            if doc.exists, let data = doc.data() {
                
                let product = StoreProduct(
                    id: doc.documentID,
                    storeOwnerId: data["storeOwnerId"] as? String ?? "",
                    name: data["name"] as? String ?? "",
                    imageURL: data["imageURL"] as? String ?? "",
                    stockQuantity: data["stockQuantity"] as? Int ?? 0,
                    price: data["price"] as? Double ?? 0,
                    description: data["description"] as? String ?? "",
                    metrics: data["metrics"] as? [[String: Any]] ?? []
                )
                products.append(product)
            }
        }
        return products
    }
    
    func fetchOrderProducts() async throws -> [StoreProduct] {
          let productIds = self.products.map { $0.id }
          return try await StoreOrder.fetchProductsForOrder(productIds: productIds)
      }
   
   static func fetchOrders() async throws -> [StoreOrder] {
       let db = Firestore.firestore()
       let snapshot = try await db.collection("orders").getDocuments()
       return snapshot.documents.compactMap { StoreOrder(document: $0) }
   }
   
   static func fetchOrders(forOwner ownerId: String) async throws -> [StoreOrder] {
       let db = Firestore.firestore()
       let snapshot = try await db.collection("orders")
           .whereField("storeOwnerId", isEqualTo: ownerId)
           .getDocuments()
       return snapshot.documents.compactMap { StoreOrder(document: $0) }
   }
    
    static func fetchOrders(forUser userId: String, status: OrderStatus) async throws -> [StoreOrder] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: status.rawValue)
            .getDocuments()
        return snapshot.documents.compactMap { StoreOrder(document: $0) }
    }
    
    static func updateOrderStatus(orderId: String, newStatus: OrderStatus) async throws {
       let db = Firestore.firestore()
       try await db.collection("orders").document(orderId).updateData([
           "status": newStatus.rawValue
       ])
    }
    
    func saveOrder() async throws {
        let db = Firestore.firestore()
        // Convert to dictionary for Firestore
        let orderData: [String: Any] = [
            "id": id,
            "products": products.map { [
                "id": $0.id,
                "quantity": $0.quantity
            ]},
            "storeOwnerId": storeOwnerId,
            "userId": userId,
            "totalPrice": totalPrice,
            "status": status.rawValue,
            "dateOrdered": Timestamp(date: dateOrdered)
        ]
               
        try await db.collection("orders").document(id).setData(orderData)
    }
}
