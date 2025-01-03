//
//  ProductMetrics.swift
//  EcoShop
//
//  Created by Hussain Almakana on 22/12/2024.
//

import Foundation
import FirebaseFirestore

struct ProductMetric: Codable {
    let productName: String
    let metrics: [Metrics]
    let quantity: Int
    let userId: String
    var dateOrderd: Date = Date()
    
    static func SaveProductMetric(_ metric: ProductMetric, completion: @escaping (Result<Bool, Error>) -> Void) {
        // Get Firestore reference
        let db = Firestore.firestore()
        
        // Convert ProductMetric to a dictionary
        do {
            let metricData = try DictionaryEncoder().encode(metric)
            
            // convert `dateOrderd` to Firestore `Timestamp`
            var firestoreData = metricData
            if let date = metricData["dateOrderd"] as? Date {
                firestoreData["dateOrderd"] = Timestamp(date: date)
            }
            
            // Save to Firestore collection
            db.collection("outside_product_metrics").addDocument(data: firestoreData) { error in
                if let error = error {
                    // Call completion with failure
                    completion(.failure(error))
                } else {
                    // Call completion with success
                    completion(.success(true))
                }
            }
        } catch {
            // Call completion with encoding failure
            completion(.failure(error))
        }
    }
}


// Helper class to encode structs to dictionaries
class DictionaryEncoder {
    private let encoder = JSONEncoder()

    func encode<T>(_ value: T) throws -> [String: Any] where T: Encodable {
        let data = try encoder.encode(value)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dictionary = json as? [String: Any] else {
            throw NSError(domain: "EncodingError", code: -1, userInfo: nil)
        }
        return dictionary
    }
}
