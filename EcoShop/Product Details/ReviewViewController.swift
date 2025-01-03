import UIKit
import FirebaseFirestore

class ReviewViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private weak var reviewTableView: UITableView!
    @IBOutlet private weak var newReviewTextView: UITextView!
    @IBOutlet private weak var submitReviewButton: UIButton!
    @IBOutlet private weak var ratingStarButton1: UIButton!
    @IBOutlet private weak var ratingStarButton2: UIButton!
    @IBOutlet private weak var ratingStarButton3: UIButton!
    @IBOutlet private weak var ratingStarButton4: UIButton!
    @IBOutlet private weak var ratingStarButton5: UIButton!
    
    // MARK: - Properties
    var productId: String?
    private var reviews: [Review] = []
    private var selectedRating: Int = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ReviewViewController loaded")
        setupUI()
        fetchReviews()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        print("Setting up UI")
        
        // TableView setup
        reviewTableView.dataSource = self
        reviewTableView.delegate = self
        reviewTableView.rowHeight = UITableView.automaticDimension
        reviewTableView.estimatedRowHeight = 150
        
        // Register cell nib
        print("Attempting to register ReviewCell nib")
        let nib = UINib(nibName: "ReviewCell", bundle: Bundle.main)
        reviewTableView.register(nib, forCellReuseIdentifier: "ReviewCell")
        print("Successfully registered ReviewCell nib")
        
        // Review input setup
        newReviewTextView.delegate = self
        newReviewTextView.layer.borderWidth = 1
        newReviewTextView.layer.borderColor = UIColor.lightGray.cgColor
        newReviewTextView.layer.cornerRadius = 5
        newReviewTextView.text = "Write your review here..."
        newReviewTextView.textColor = .lightGray
        
        // Configure star buttons
        [ratingStarButton1, ratingStarButton2, ratingStarButton3, ratingStarButton4, ratingStarButton5].enumerated().forEach { index, button in
            button?.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            button?.tag = index + 1
        }
        
        // Style submit button
        submitReviewButton.backgroundColor = .systemGreen
        submitReviewButton.setTitleColor(.white, for: .normal)
        submitReviewButton.layer.cornerRadius = 8
    }
    
    // MARK: - Actions
    @objc private func starTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        updateStars()
    }
    
    private func updateStars() {
        [ratingStarButton1, ratingStarButton2, ratingStarButton3, ratingStarButton4, ratingStarButton5].enumerated().forEach { index, button in
            guard let button = button else { return }
            let filledStar = UIImage(systemName: "star.fill")
            let emptyStar = UIImage(systemName: "star")
            button.setImage(index < selectedRating ? filledStar : emptyStar, for: .normal)
            button.tintColor = index < selectedRating ? .systemYellow : .gray
        }
    }
    
    @IBAction private func submitReviewTapped(_ sender: Any) {
        guard let content = newReviewTextView.text, !content.isEmpty else {
            showAlert(title: "Error", message: "Please write a review")
            return
        }
        
        guard selectedRating > 0 else {
            showAlert(title: "Error", message: "Please select a rating")
            return
        }
        
        guard let productId = productId else {
            print("No productId found")
            return
        }
        
        print("Submitting review for productId: \(productId)")
        print("Content: \(content)")
        print("Rating: \(selectedRating)")
        
        Task {
            do {
                // Submit the review
                let newReview = try await Review.submitReview(
                    content: content,
                    productId: productId,
                    rating: selectedRating,
                    username: "Anonymous"
                )
                print("Review submitted successfully")
                
                // Add to local array and update UI
                DispatchQueue.main.async {
                    self.reviews.insert(newReview, at: 0)  // Add to beginning of array
                    self.reviewTableView.reloadData()
                    
                    // Clear input fields
                    self.newReviewTextView.text = ""
                    self.selectedRating = 0
                    self.updateStars()
                    
                    // Show success message
                    self.showAlert(title: "Success", message: "Your review has been submitted!")
                }
            } catch {
                print("Error submitting review: \(error)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to submit review. Please try again.")
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Firebase Operations
    private func fetchReviews() {
        guard let productId = productId else {
            print("No productId found")
            return
        }
        print("🔍 Fetching reviews for productId: \(productId)")
        
        Task {
            do {
                let fetchedReviews = try await Review.fetchReviews(for: productId)
                print("Found \(fetchedReviews.count) reviews")
                
                DispatchQueue.main.async {
                    self.reviews = fetchedReviews
                    self.reviewTableView.reloadData()
                }
            } catch {
                print("Error fetching reviews: \(error)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to load reviews. Please try again.")
                }
            }
        }
    }
}

// MARK: - TableView DataSource & Delegate
extension ReviewViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of reviews: \(reviews.count)")
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("🔄 Configuring cell at index: \(indexPath.row)")
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as? ReviewCell else {
            print("Failed to dequeue ReviewCell")
            return UITableViewCell()
        }
        
        let review = reviews[indexPath.row]
        print("Configuring cell with review: \(review)")
        cell.configure(with: review)
        
        // Configure cell appearance
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        return cell
    }
}

// MARK: - UITextView Delegate
extension ReviewViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write your review here..."
            textView.textColor = .lightGray
        }
    }
}
