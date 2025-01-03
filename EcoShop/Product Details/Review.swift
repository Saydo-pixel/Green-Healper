//
//  Review.swift
//  EcoShop
//
//  Created by Ahmed Mohammed on 04/12/2024.
//

import Foundation
import FirebaseFirestore

struct Review: Codable {
    let id: String
    let content: String
    let productId: String
    let rating: Int
    let username: String
    
    static func fetchReviews(for productId: String) async throws -> [Review] {
        print("Review - Fetching reviews for productId: \(productId)")
        let db = Firestore.firestore()
        
        // Add retry logic
        var attempts = 0
        let maxAttempts = 3
        
        while attempts < maxAttempts {
            do {
                let snapshot = try await db.collection("reviews")
                    .whereField("productId", isEqualTo: productId)
                    .getDocuments()
                
                let reviews = snapshot.documents.compactMap { document in
                    Review(
                        id: document.documentID,
                        content: document["content"] as? String ?? "",
                        productId: document["productId"] as? String ?? "",
                        rating: document["rating"] as? Int ?? 0,
                        username: document["username"] as? String ?? "Anonymous"
                    )
                }
                print("Review - Found \(reviews.count) reviews")
                return reviews
            } catch {
                attempts += 1
                print("Review - Attempt \(attempts) failed: \(error.localizedDescription)")
                if attempts == maxAttempts { throw error }
                try await Task.sleep(nanoseconds: 1_000_000_000) // Wait 1 second before retry
            }
        }
        throw NSError(domain: "Review", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed after \(maxAttempts) attempts"])
    }
    
    static func submitReview(content: String, productId: String, rating: Int, username: String) async throws -> Review {
        print("Review - Submitting new review")
        let db = Firestore.firestore()
        
        // Add retry logic
        var attempts = 0
        let maxAttempts = 3
        
        while attempts < maxAttempts {
            do {
                // Create the review data
                let reviewData: [String: Any] = [
                    "content": content,
                    "productId": productId,
                    "rating": rating,
                    "username": username,
                    "timestamp": FieldValue.serverTimestamp()
                ]
                
                // Add the document and get the reference
                let documentRef = try await db.collection("reviews").addDocument(data: reviewData)
                
                // Create and return the Review object
                let review = Review(
                    id: documentRef.documentID,
                    content: content,
                    productId: productId,
                    rating: rating,
                    username: username
                )
                
                print("Review - Successfully submitted review with id: \(review.id)")
                return review
            } catch {
                attempts += 1
                print("Review - Attempt \(attempts) failed: \(error.localizedDescription)")
                if attempts == maxAttempts { throw error }
                try await Task.sleep(nanoseconds: 1_000_000_000) // Wait 1 second before retry
            }
        }
        throw NSError(domain: "Review", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed after \(maxAttempts) attempts"])
    }
}
