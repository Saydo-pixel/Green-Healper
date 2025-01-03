//
//  AhmedViewController.swift
//  EcoShop
//
//  Created by BP-36-201-06 on 02/12/2024.
//

import UIKit
import FirebaseFirestore

class AhmedViewController: UIViewController {
    let userId = "b89889f7-6593-48f5-987e-8b459f45fcf2"
    // MARK: - Outlets
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var environmentalImpactTextView: UITextView!
    @IBOutlet weak var quantityStepper: UIStepper!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star5: UIButton!
    
    @IBOutlet var addToCartBtn: UIButton!
    @IBOutlet private weak var topRatedImage1: UIImageView!
    @IBOutlet private weak var topRatedImage2: UIImageView!
    @IBOutlet private weak var topRatedImage3: UIImageView!
    @IBOutlet weak var certificationImageView: UIImageView!
    @IBOutlet weak var storeOwnerLabel: UILabel!
    
    // MARK: - Properties
    var productId: String?
    private var product: Product?
    private var selectedQuantity: Int = 1
    private var topRatedProducts: [Product] = []
    private var storeOwnerName: String = "EcoShop" // Default value
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Set a default product ID for testing if none is provided
        if productId == nil {
            productId = "02a3c9b2-6c12-40d5-8d4c-218a8ddd5d27"
        }
        
        fetchTopRatedProducts()
        if let productId = productId {
            fetchProductDetails(for: productId)
        }
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        // Initial UI setup
        quantityStepper.value = Double(selectedQuantity)
        quantityLabel.text = "\(selectedQuantity)"
        
        // Configure text views
        descriptionTextView.isEditable = false
        environmentalImpactTextView.isEditable = false
        
        // Add stepper value changed action
        quantityStepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
        
        // Setup tap gestures for top rated product images
        [topRatedImage1, topRatedImage2, topRatedImage3].enumerated().forEach { index, imageView in
            guard let imageView = imageView else { return }
            imageView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(topRatedImageTapped(_:)))
            imageView.tag = index
            imageView.addGestureRecognizer(tapGesture)
        }
    }
    
    private func setupStarRatingView() {
        // Create a horizontal stack view for stars
        let starStackView = UIStackView()
        starStackView.axis = .horizontal
        starStackView.distribution = .fillEqually
        starStackView.spacing = 8
        starStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add existing star buttons to the stack view
        [star1, star2, star3, star4, star5].forEach { button in
            if let button = button {
                starStackView.addArrangedSubview(button)
                
                // Configure each star button
                button.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    button.widthAnchor.constraint(equalToConstant: 40),
                    button.heightAnchor.constraint(equalToConstant: 40)
                ])
            }
        }
        
        // Add stack view to the view hierarchy (assuming it should be below the product name)
        if let firstStar = star1 {
            view.addSubview(starStackView)
            
            // Position the stack view
            NSLayoutConstraint.activate([
                starStackView.topAnchor.constraint(equalTo: firstStar.topAnchor),
                starStackView.leadingAnchor.constraint(equalTo: firstStar.leadingAnchor),
                starStackView.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
    }
    
    private func fetchTopRatedProducts() {
        Task {
            do {
                print("🔄 Fetching top rated products")
                let products = try await Product.fetchTopRatedProducts()
                self.topRatedProducts = products
                
                // Update UI with top rated products
                await MainActor.run {
                    updateTopRatedProductsUI()
                }
            } catch {
                print("Error fetching top rated products: \(error)")
            }
        }
    }
    
    private func updateTopRatedProductsUI() {
        let imageViews = [topRatedImage1, topRatedImage2, topRatedImage3]
        
        // Load images for top rated products
        for (index, product) in topRatedProducts.enumerated() {
            guard index < imageViews.count,
                  let imageView = imageViews[index],
                  let url = URL(string: product.imageURL) else { continue }
            
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard self != nil else { return }
                
                if let error = error {
                    print("Error loading image: \(error)")
                    return
                }
                
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
            }.resume()
        }
    }
    
    @objc private func topRatedImageTapped(_ gesture: UITapGestureRecognizer) {
        print("🔵 Image tapped")
        
        guard let index = gesture.view?.tag else {
            print("Could not get tag from tapped view")
            return
        }
        
        print("📍 Tapped image index: \(index)")
        
        guard index < topRatedProducts.count else {
            print("Index out of bounds. Index: \(index), Products count: \(topRatedProducts.count)")
            return
        }
        
        let product = topRatedProducts[index]
        print("Found product: \(product.name) with ID: \(product.id)")
        
        // Navigate to product details
        let storyboard = UIStoryboard(name: "Ahmed", bundle: nil)
        print("📱 Got storyboard reference")
        
        if let detailsVC = storyboard.instantiateViewController(withIdentifier: "AhmedViewController") as? AhmedViewController {
            print("Successfully created details view controller")
            detailsVC.productId = product.id
            print("➡️ Attempting navigation push")
            navigationController?.pushViewController(detailsVC, animated: true)
        } else {
            print("Failed to create details view controller")
        }
    }
    
    private func fetchProductDetails(for productId: String) {
        let db = Firestore.firestore()
        db.collection("products").document(productId).getDocument { [weak self] (document, error) in
            guard let self = self,
                  let document = document,
                  document.exists,
                  let data = document.data() else {
                print("Error fetching product details: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Get store owner name directly from product data
            if let ownerName = data["storeOwnerName"] as? String {
                DispatchQueue.main.async {
                    self.storeOwnerName = ownerName
                    self.storeOwnerLabel.text = "By \(ownerName)"
                }
            }
            
            // Create metrics array from data
            let metricsData = data["metrics"] as? [[String: Any]] ?? []
            let metrics = metricsData.compactMap { metricData -> Metric? in
                guard let name = metricData["name"] as? String,
                      let unit = metricData["unit"] as? String,
                      let value = metricData["value"] as? Double else { return nil }
                return Metric(name: name, unit: unit, value: value)
            }
            
            // Create product instance
            let product = Product(
                id: document.documentID,
                name: data["name"] as? String ?? "",
                price: data["price"] as? Double ?? 0.0,
                description: data["description"] as? String ?? "",
                imageURL: data["imageURL"] as? String ?? "",
                stockQuantity: data["stockQuantity"] as? Int ?? 0,
                storeOwnerId: data["storeOwnerId"] as? String ?? "",
                metrics: metrics,
                isCertified: data["isCertified"] as? Bool ?? false,
                category: data["category"] as? String ?? "Uncategorized"
            )
            
            print("Successfully fetched product: \(product.name)")
            self.product = product
            DispatchQueue.main.async {
                self.updateUI(with: product)
            }
        }
    }
    
    private func updateUI(with product: Product) {
        productNameLabel.text = product.name
        priceLabel.text = String(format: "%.2f", product.price)
        descriptionTextView.text = product.description
        environmentalImpactTextView.text = product.environmentalImpactSummary
        
        // Update certification image visibility based on isCertified value
        certificationImageView.isHidden = !product.isCertified
        
        // Update quantity stepper max value
        quantityStepper.maximumValue = Double(product.stockQuantity)
        
        // Load average rating asynchronously
        Task {
            do {
                print("🔄 Starting average rating calculation for product: \(product.name)")
                let avgRating = try await product.averageRating
                print("Final average rating: \(avgRating)")
                await MainActor.run {
                    print("Updating UI with rounded rating: \(Int(round(avgRating)))")
                    self.updateRatingStars(rating: Int(round(avgRating)))
                }
            } catch {
                print("Error calculating average rating: \(error)")
            }
        }
        
        // Load image if URL is valid
        if let url = URL(string: product.imageURL) {
            loadImage(from: url)
        }
    }
    
    private func updateRatingStars(rating: Int) {
        let starButtons = [star1, star2, star3, star4, star5]
        starButtons.enumerated().forEach { index, button in
            guard let button = button else { return }
            
            // Create star images
            let filledStar = UIImage(systemName: "star.fill")
            let emptyStar = UIImage(systemName: "star")
            
            // Set image and color based on rating
            button.setImage(index < rating ? filledStar : emptyStar, for: .normal)
            button.tintColor = index < rating ? .systemYellow : .gray
        }
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error loading image: \(error)")
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.productImageView.image = image
                }
            }
        }.resume()
    }
    
    private func showAlert(title: String, message: String, preferredStyle: UIAlertController.Style = .alert, actions: [UIAlertAction] = [UIAlertAction(title: "OK", style: .default)]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc private func stepperValueChanged() {
        selectedQuantity = Int(quantityStepper.value)
        quantityLabel.text = "\(selectedQuantity)"
    }
    
    @IBAction func addToCartTapped(_ sender: Any) {
        guard let product = product else { return }
        // TODO: Implement cart functionality
        addToCartBtn.isEnabled.toggle()
        Task {
            do {
                try await Cart.addProductToCart(userId: userId, productId: product.id, quantity: selectedQuantity)
                let cartStoryboard = UIStoryboard(name: "ShoppingCart", bundle: nil)
                if let cartVC = cartStoryboard.instantiateViewController(withIdentifier: "CartTableViewController") as? CartTableViewController {
                    navigationController?.pushViewController(cartVC, animated: true)
                }
                DispatchQueue.main.async{
                    self.addToCartBtn.isEnabled.toggle()
                }

            } catch {
                showAlert(title: "Error", message: "An error occured while adding the product to your cart.")
                DispatchQueue.main.async{
                    self.addToCartBtn.isEnabled.toggle()
                }
            }
        }
    }
    
    @IBAction func viewRatingsTapped(_ sender: Any) {
        // Handled by storyboard segue
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("AhmedViewController - Preparing for segue")
        if let reviewVC = segue.destination as? ReviewViewController {
            print("AhmedViewController - Found ReviewViewController")
            reviewVC.productId = self.productId
            print("AhmedViewController - Set productId: \(String(describing: self.productId))")
        } else {
            print("AhmedViewController - Failed to cast to ReviewViewController")
        }
    }
}
