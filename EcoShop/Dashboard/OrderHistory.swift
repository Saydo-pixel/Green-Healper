//
//  OrderHistory.swift
//  EcoShop
//
//  Created by Hussain Almakana on 12/12/2024.
//

import Foundation
import FirebaseFirestore

struct Metrics: Codable, AdditiveArithmetic {
    let name: String
    let unit: String
    let value: Int
    
    // Conform to AdditiveArithmetic
    static var zero: Metrics {
        return Metrics(name: "None", unit: "", value: 0)
    }
        
    static func + (lhs: Metrics, rhs: Metrics) -> Metrics {
        // Make sure you're adding metrics with the same name and unit
        assert(lhs.name == rhs.name && lhs.unit == rhs.unit, "Cannot add metrics with different names or units")
            
        return Metrics(name: lhs.name, unit: lhs.unit, value: lhs.value + rhs.value)
    }
    
    static func - (lhs: Metrics, rhs: Metrics) -> Metrics {
        assert(lhs.name == rhs.name && lhs.unit == rhs.unit, "Cannot subtract metrics with different names or units")
        return Metrics(name: lhs.name, unit: lhs.unit, value: lhs.value - rhs.value)
    }
}

struct OrderItem: Codable {
    let id: String
    let quantity: Int
}

struct Order: Codable {
    let id: String
    let dateOrdered: Date
    let products: [Product]
    let status: String
    let storeOwnerId: String
    let totalPrice: Float
    
//    A closure that the function calls when it's done fetching data (successfully or with an error).
//    it's marked as escaping because it will be called later after the fetching is done
    static func fetchUserMetrics(userId: String, startDate: Date?, completion: @escaping (Result<(metrics: [Metrics], itemCount: Int), Error>) -> Void) {
        let db = Firestore.firestore()
        
        // Query orders collection
        var query = db.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isNotEqualTo: "Canceled")
        
        // Add date filtering if startDate is provided
        if let startDate = startDate {
            query = query.whereField("dateOrdered", isGreaterThanOrEqualTo: Timestamp(date: startDate))
        }
        
        var itemCount = 0
        var allMetrics: [Metrics] = []
        let group = DispatchGroup() // Used to wait for all asynchronous queries
        
        // Fetch metrics from orders
        group.enter()
        query.getDocuments { (orderSnapshot, error) in
            if let error = error {
                group.leave()
                completion(.failure(error))
                return
            }
            
            guard let documents = orderSnapshot?.documents else {
                group.leave()
                return
            }
            
            for document in documents {
                let orderData = document.data()
                if let products = orderData["products"] as? [[String: Any]] {
                    for product in products {
                        if let productId = product["id"] as? String,
                            let quantity = product["quantity"] as? Int{
                            // add the quantity to the item count to get how many items included in the calcuation
                            itemCount += quantity
                            group.enter()
                            
                            db.collection("products").document(productId).getDocument { (productSnapshot, error) in
                                defer { group.leave() } // Ensure group.leave is always called
                                
                                if let error = error {
                                    completion(.failure(error))
                                    return
                                }
                                
                                if let productData = productSnapshot?.data(),
                                   let productMetrics = productData["metrics"] as? [[String: Any]] {
                                    for metricData in productMetrics {
                                        if let name = metricData["name"] as? String,
                                           let unit = metricData["unit"] as? String,
                                           let value = metricData["value"] as? Int {
                                            allMetrics.append(Metrics(name: name, unit: unit, value: value * quantity))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            group.leave()
        }
        
        // Fetch metrics from outside_product_metrics collection for that specific user
        group.enter()
        db.collection("outside_product_metrics").whereField("userId", isEqualTo: userId).getDocuments { (outsideMetricsSnapshot, error) in
            defer { group.leave() } // Ensure group.leave is always called
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let outsideMetricsDocs = outsideMetricsSnapshot?.documents else { return }
            
            for document in outsideMetricsDocs {
                let data = document.data()
                if let metricsArray = data["metrics"] as? [[String: Any]],
                    let quantity = data["quantity"] as? Int {
                    itemCount += quantity // Add the quantity to the item count

                    for metricData in metricsArray {
                        if let name = metricData["name"] as? String,
                           let unit = metricData["unit"] as? String,
                           let value = metricData["value"] as? Int {
                            allMetrics.append(Metrics(name: name, unit: unit, value: value * quantity))
                        }
                    }
                }
            }
        }
        
        // Notify after all asynchronous tasks are done
        group.notify(queue: .main) {
            let combinedMetrics = combineMetrics(allMetrics)
            completion(.success((metrics: combinedMetrics, itemCount: itemCount)))
        }
    }


}

private func combineMetrics(_ metrics: [Metrics]) -> [Metrics] {
    var combinedMetrics: [Metrics] = []
    var metricMap: [String: Metrics] = [:]
    
    for metric in metrics {
        if let existingMetric = metricMap[metric.name] {
            let combinedValue = existingMetric.value + metric.value
            metricMap[metric.name] = Metrics(name: existingMetric.name, unit: existingMetric.unit, value: combinedValue)
        } else {
            metricMap[metric.name] = metric
        }
    }
    
    // convert the map back into an array
    combinedMetrics = Array(metricMap.values)
    return combinedMetrics
}

