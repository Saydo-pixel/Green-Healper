//
//  ProductViewController.swift
//  EcoShop
//
//  Created by Sayed Shubbar Qasim on 23/12/2024.
//

import UIKit
import FirebaseFirestore

class ProductViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FilterDelegate {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var featuredImage: UIImageView!
    @IBOutlet weak var featuredName: UILabel!
    @IBOutlet weak var featuredDescription: UILabel!
    @IBOutlet weak var featuredPrice: UILabel!
    @IBOutlet weak var featuredStar1: UIImageView!
    @IBOutlet weak var featuredStar2: UIImageView!
    @IBOutlet weak var featuredStar3: UIImageView!
    @IBOutlet weak var featuredStar4: UIImageView!
    @IBOutlet weak var featuredStar5: UIImageView!
    @IBOutlet weak var featuredView: UIButton!
    
    private var products: [Product] = []
    private var filteredProducts: [Product] = []
    private var searchResults: [Product] = []
    private var reviewsCache: [String: [Review]] = [:]
    private var featuredProduct: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        searchBar.delegate = self
            
        // Method to fetch products and reviews
        Task {
            await fetchProductsAndReviews()
        }
    }
    
    private func updateFeaturedProduct() async {
        var topRatedProduct: Product?
        var topAverageRating: Double = 0.0
        var maxReviewCount: Int = 0

        for product in products {
            if let reviews = reviewsCache[product.id] {
                let averageRating = reviews.isEmpty ? 0.0 : Double(reviews.reduce(0) { $0 + $1.rating }) / Double(reviews.count)
                let reviewCount = reviews.count

                // Priority: Higher average rating > More reviews in case of tie
                if averageRating > topAverageRating || (averageRating == topAverageRating && reviewCount > maxReviewCount) {
                    topRatedProduct = product
                    topAverageRating = averageRating
                    maxReviewCount = reviewCount
                }
            }
        }

        self.featuredProduct = topRatedProduct
        DispatchQueue.main.async {
            self.updateFeaturedProductUI()
        }
    }
    
    private func updateFeaturedProductUI() {
        guard let product = featuredProduct else { return }

        featuredName.text = product.name
        featuredDescription.text = product.description
        featuredPrice.text = String(format: "%.2f BD", product.price)

        if let url = URL(string: product.imageURL) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.featuredImage.image = image
                    }
                }
            }.resume()
        } else {
            featuredImage.image = UIImage(named: "placeholder")
        }

        // Fill empty stars
        let stars = [featuredStar1, featuredStar2, featuredStar3, featuredStar4, featuredStar5]
        if let reviews = reviewsCache[product.id] {
            let averageRating = reviews.isEmpty ? 0.0 : Double(reviews.reduce(0) { $0 + $1.rating }) / Double(reviews.count)
            let roundedRating = Int(round(averageRating))
            for (index, star) in stars.enumerated() {
                star?.image = UIImage(systemName: index < roundedRating ? "star.fill" : "star")
                star?.tintColor = index < roundedRating ? .systemYellow : .gray
            }
        }
    }
    
    @IBAction func featuredViewTapped(_ sender: UIButton) {
        guard let product = featuredProduct else { return }

        let storyboard = UIStoryboard(name: "Ahmed", bundle: nil)
        if let ahmedVC = storyboard.instantiateViewController(withIdentifier: "AhmedViewController") as? AhmedViewController {
            ahmedVC.productId = product.id
            self.navigationController?.pushViewController(ahmedVC, animated: true)
        }
    }

    private func fetchProductsAndReviews() async {
        do {
            let db = Firestore.firestore()
            
            // Fetching all products
            let productSnapshot = try await db.collection("products").getDocuments()
            self.products = productSnapshot.documents.compactMap { doc in
                Product(
                    id: doc.documentID,
                    name: doc["name"] as? String ?? "",
                    price: doc["price"] as? Double ?? 0.0,
                    description: doc["description"] as? String ?? "",
                    imageURL: doc["imageURL"] as? String ?? "",
                    stockQuantity: doc["stockQuantity"] as? Int ?? 0,
                    storeOwnerId: doc["storeOwnerId"] as? String ?? "",
                    metrics: (doc["metrics"] as? [[String: Any]])?.compactMap { metricData in
                        guard let name = metricData["name"] as? String,
                              let unit = metricData["unit"] as? String,
                              let value = metricData["value"] as? Double else { return nil }
                        return Metric(name: name, unit: unit, value: value)
                    } ?? [],
                    isCertified: doc["isCertified"] as? Bool ?? false,
                    category: doc["category"] as? String ?? "Uncategorized"
                )
            }
            
            // Fetching all reviews
            let reviewSnapshot = try await db.collection("reviews").getDocuments()
            for document in reviewSnapshot.documents {
                let review = Review(
                    id: document.documentID,
                    content: document["content"] as? String ?? "",
                    productId: document["productId"] as? String ?? "",
                    rating: document["rating"] as? Int ?? 0,
                    username: document["username"] as? String ?? "Anonymous"
                )
                reviewsCache[review.productId, default: []].append(review)
            }
            
            self.filteredProducts = self.products // Initialize filteredProducts with all products
            self.searchResults = self.filteredProducts // Initialize searchResults with filtered products
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
        
        await updateFeaturedProduct()
    }
    
    // MARK: - FilterDelegate
    func applyFilters(minPrice: Double?, maxPrice: Double?, category: String?, minRating: Int?) {
        filteredProducts = products.filter { product in
            let matchesPrice = (minPrice == nil || product.price >= minPrice!) &&
                               (maxPrice == nil || product.price <= maxPrice!)
            let matchesCategory = (category == nil || product.category.lowercased() == category?.lowercased())
            var matchesRating = true
            
            if let minRating = minRating, let reviews = reviewsCache[product.id] {
                let averageRating = reviews.isEmpty ? 0.0 : Double(reviews.reduce(0) { $0 + $1.rating }) / Double(reviews.count)
                matchesRating = averageRating >= Double(minRating)
            }
            
            return matchesPrice && matchesCategory && matchesRating
        }
        
        searchResults = filteredProducts // Reset searchResults to filtered products
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
    
    func clearFilters() {
        filteredProducts = products
        searchResults = filteredProducts // Reset searchResults to all products
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
    
    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchResults = filteredProducts
        } else {
            searchResults = filteredProducts.filter { product in
                product.name.lowercased().contains(searchText.lowercased()) ||
                product.description.lowercased().contains(searchText.lowercased())
            }
        }
        table.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < searchResults.count else { return UITableViewCell() }
        
        let product = searchResults[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! CustomTableViewCell
        
        cell.productName.text = product.name
        cell.productDesc.text = product.description
        cell.productPrice.text = String(format: "%.2f BD", product.price)
        
        if let url = URL(string: product.imageURL) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.productImageView.image = image
                    }
                }
            }.resume()
        } else {
            cell.productImageView.image = UIImage(named: "placeholder")
        }
        
        cell.viewButton.tag = indexPath.row
        cell.viewButton.addTarget(self, action: #selector(viewButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc private func viewButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        let selectedProduct = searchResults[index]
        
        let storyboard = UIStoryboard(name: "Ahmed", bundle: nil)
        if let ahmedVC = storyboard.instantiateViewController(withIdentifier: "AhmedViewController") as? AhmedViewController {
            ahmedVC.productId = selectedProduct.id
            self.navigationController?.pushViewController(ahmedVC, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFilter",
           let filterVC = segue.destination as? FilterViewController {
            filterVC.delegate = self
        }
    }
}
