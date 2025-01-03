//
//  StoreProduct.swift
//  EcoShop
//
//  Created by user244986 on 12/3/24.
//

import Foundation
import FirebaseFirestore

struct StoreProduct: Identifiable {
   let id: String
   let storeOwnerId: String
   var name: String
   var imageURL: String
   var stockQuantity: Int
   var description: String
   var price: Double
   var metrics: [[String: Any]]
   
   // Initializer
   init(id: String = UUID().uuidString,
        storeOwnerId: String,
        name: String,
        imageURL: String,
        stockQuantity: Int,
        price: Double,
        description: String,
        co2Saved: Int,
        waterConserved: Int,
        plasticReduced: Int,
        enerygySaved: Int
   ) {
       self.id = id
       self.name = name
       self.imageURL = imageURL
       self.stockQuantity = stockQuantity
       self.description = description
       self.price = price
       self.storeOwnerId = storeOwnerId
       self.metrics = [
        ["name": "CO2 Emissions Saved", "value": co2Saved, "unit": "kg"],
        ["name": "Water Conserved", "value": waterConserved, "unit": "liters"],
        ["name": "Plastic Waste Reduced", "value": plasticReduced, "unit": "kg"],
        ["name": "Energy Saved", "value": enerygySaved, "unit": "kWh"]
       ]
   }
    
    init(id: String = UUID().uuidString,
         storeOwnerId: String,
         name: String,
         imageURL: String,
         stockQuantity: Int,
         price: Double,
         description: String,
         metrics: [[String: Any]]
    ) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.stockQuantity = stockQuantity
        self.description = description
        self.price = price
        self.storeOwnerId = storeOwnerId
        self.metrics = metrics
    }
   
   // Firestore document to StoreProduct
   init?(document: QueryDocumentSnapshot) {
       guard let name = document.data()["name"] as? String,
             let imageURL = document.data()["imageURL"] as? String,
             let storeOwnerId = document.data()["storeOwnerId"] as? String,
             let stockQuantity = document.data()["stockQuantity"] as? Int else {
           return nil
       }
       
       self.id = document.documentID
       self.name = name
       self.imageURL = imageURL
       self.stockQuantity = stockQuantity
       self.storeOwnerId = storeOwnerId
       self.description = document.data()["description"] as! String
       self.price = document.data()["price"] as! Double
       self.metrics = document.data()["metrics"] as? [[String: Any]] ?? []
   }
    
    func getMetricValue(name: String) -> Int {
        let metric = metrics.first { dict in
            if let dictName = dict["name"] as? String {
                return dictName == name
            }
            return false
        }
        return metric != nil ? metric!["value"] as! Int : 0
    }
    
    mutating func setMetricValue(name: String, newValue: Int) {
        if let index = metrics.firstIndex(where: { ($0["name"] as? String) == name }) {
            metrics[index]["value"] = newValue
        }
    }
   
   // Static methods for Firestore operations
   static func fetchProducts() async throws -> [StoreProduct] {
       let db = Firestore.firestore()
       let snapshot = try await db.collection("products").getDocuments()
       
       return snapshot.documents.compactMap { document in
           return StoreProduct(document: document)
       }
   }
   
    static func fetchProducts(forOwnerId ownerId: String) async throws -> [StoreProduct] {
           let db = Firestore.firestore()
           let snapshot = try await db.collection("products")
               .whereField("storeOwnerId", isEqualTo: ownerId)
               .getDocuments()
           
           return snapshot.documents.compactMap { document in
               return StoreProduct(document: document)
           }
       }
    
   static func fetchProduct(withId id: String) async throws -> StoreProduct? {
       let db = Firestore.firestore()
       let document = try await db.collection("products").document(id).getDocument()
       
       guard document.exists else {
           return nil
       }
       
       return StoreProduct(document: document as! QueryDocumentSnapshot)
   }
   
   // Method to update stock quantity
   func updateStockQuantity(newQuantity: Int) async throws {
       let db = Firestore.firestore()
       try await db.collection("products").document(id).updateData([
           "stockQuantity": newQuantity
       ])
   }
   
   // Method to delete product
   func deleteProduct() async throws {
       let db = Firestore.firestore()
       try await db.collection("products").document(id).delete()
   }
   
   // Method to save/update product
   func saveProduct() async throws {
       let db = Firestore.firestore()
       let productData: [String: Any] = [
           "name": name,
           "storeOwnerId": storeOwnerId,
           "imageURL": imageURL,
           "stockQuantity": stockQuantity,
           "description": description as Any,
           "price": price as Any,
           "metrics": metrics as Any,
           "averageRating": 0,
           "RatingNumber": 0,
           "RatingTotal": 0,
           "isCertified": true
       ]
              
       try await db.collection("products").document(id).setData(productData)
   }
}
