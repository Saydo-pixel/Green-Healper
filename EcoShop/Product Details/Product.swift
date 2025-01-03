//
//  Product.swift
//  EcoShop
//
//  Created by Ahmed Mohammed on 04/12/2024.
//

import Foundation
import FirebaseFirestore

struct Metric: Codable {
    let name: String
    let unit: String
    let value: Double
    
    var formattedString: String {
        return "\(name): \(String(format: "%.1f", value)) \(unit)"
    }
}

struct Product: Codable {
    let id: String
    let name: String
    let price: Double
    let description: String
    let imageURL: String
    let stockQuantity: Int
    let storeOwnerId: String
    let metrics: [Metric]
    let isCertified: Bool
    let category: String
    
    var environmentalImpactSummary: String {
        return metrics.map { $0.formattedString }.joined(separator: "\n")
    }
    
    // Computed property for average rating
    var averageRating: Double {
        get async throws {
            print("📊 Calculating average rating for product: \(id)")
            let reviews = try await Review.fetchReviews(for: id)
            print("Found \(reviews.count) reviews")
            
            if reviews.isEmpty {
                print("No reviews found, returning 0.0")
                return 0.0
            }
            
            // Print individual ratings
            reviews.forEach { review in
                print("Review by \(review.username): \(review.rating) stars")
            }
            
            let totalRating = reviews.reduce(0) { $0 + $1.rating }
            let average = Double(totalRating) / Double(reviews.count)
            print("Total rating: \(totalRating)")
            print("Average rating: \(average)")
            
            return average
        }
    }
    
    static func fetchProduct(withId id: String) async throws -> Product? {
        let db = Firestore.firestore()
        let docRef = db.collection("products").document(id)
        let snapshot = try await docRef.getDocument()
        
        guard let data = snapshot.data() else { return nil }
        
        print("Fetched data: \(data)")
        
        return Product(
            id: snapshot.documentID,
            name: data["name"] as? String ?? "",
            price: data["price"] as? Double ?? 0.0,
            description: data["description"] as? String ?? "",
            imageURL: data["imageURL"] as? String ?? "",
            stockQuantity: data["stockQuantity"] as? Int ?? 0,
            storeOwnerId: data["storeOwnerId"] as? String ?? "",
            
            metrics: (data["metrics"] as? [[String: Any]])?.compactMap { metricData in
                guard let name = metricData["name"] as? String,
                      let unit = metricData["unit"] as? String,
                      let value = metricData["value"] as? Double else { return nil }
                return Metric(name: name, unit: unit, value: value)
            } ?? [],
            isCertified: data["isCertified"] as? Bool ?? false,
            category: data["category"] as? String ?? "Uncategorized"
        )
    }
    static func fetchTopRatedProducts(limit: Int = 3) async throws -> [Product] {
        print("Fetching top \(limit) rated products")
        let db = Firestore.firestore()
        let productsRef = db.collection("products")
        
        // First, fetch all products
        let snapshot = try await productsRef.getDocuments()
        
        // Create array to hold products with their ratings
        var productsWithRatings: [(Product, Double)] = []
        
        // Process each product sequentially
        for document in snapshot.documents {
            do {
            let metrics = (document["metrics"] as? [[String: Any]])?.compactMap { metricData -> Metric? in
    if let name = metricData["name"] as? String,
       let value = metricData["value"] as? Double,
       let unit = metricData["unit"] as? String {
        return Metric(name: name, unit: unit, value: value)
    }
    return nil
} ?? []
                
                let product = Product(
                    id: document.documentID,
                    name: document["name"] as? String ?? "",
                    price: document["price"] as? Double ?? 0.0,
                    description: document["description"] as? String ?? "",
                    imageURL: document["imageURL"] as? String ?? "",
                    stockQuantity: document["stockQuantity"] as? Int ?? 0,
                    storeOwnerId: document["storeOwnerId"] as? String ?? "",
                    metrics: metrics,
                    isCertified: document["isCertified"] as? Bool ?? false,
                    category: document["category"] as? String ?? "Uncategorized"
                )
                
                // Calculate average rating for each product
                let reviews = try await Review.fetchReviews(for: product.id)
                let avgRating = reviews.isEmpty ? 0.0 : Double(reviews.reduce(0) { $0 + $1.rating }) / Double(reviews.count)
                print("📊 Product: \(product.name) - Average Rating: \(avgRating)")
                
                productsWithRatings.append((product, avgRating))
            } catch {
                print("Error processing product document: \(error)")
                continue
            }
        }
        
        // Sort products by average rating and get top N
        productsWithRatings.sort { $0.1 > $1.1 }
        let topProducts = productsWithRatings.prefix(limit).map { $0.0 }
        
        print("Found top \(topProducts.count) rated products:")
        topProducts.forEach { product in
            print("\(product.name)")
        }
        
        return Array(topProducts)
    }

    
}
