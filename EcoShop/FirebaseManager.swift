//
//  FirebaseManager.swift
//  EcoShop
//
//  Created by Ahmed Mohammed on 04/12/2024.
//

import Foundation
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func fetchProducts() async throws -> [Product] {
        let snapshot = try await db.collection("products").getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: Product.self)
        }
    }
    
    func fetchReviews(for productId: String) async throws -> [Review] {
        let snapshot = try await db.collection("reviews")
            .whereField("productId", isEqualTo: productId)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Review.self)
        }
    }
}
