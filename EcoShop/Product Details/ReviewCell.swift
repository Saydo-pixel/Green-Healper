//
//  ReviewCell.swift
//  EcoShop
//
//  Created by Ahmed Mohammed on 04/12/2024.
//

import UIKit

class ReviewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet weak var reviewContentTextView: UITextView!
    @IBOutlet weak var reviewerNameLabel: UILabel!
    @IBOutlet weak var ratingStarButton1: UIButton!
    @IBOutlet weak var ratingStarButton2: UIButton!
    @IBOutlet weak var ratingStarButton3: UIButton!
    @IBOutlet weak var ratingStarButton4: UIButton!
    @IBOutlet weak var ratingStarButton5: UIButton!
    
    // MARK: - Properties
    private var starButtons: [UIButton] {
        [ratingStarButton1, ratingStarButton2, ratingStarButton3, ratingStarButton4, ratingStarButton5]
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Configure text view
        reviewContentTextView.isEditable = false
        reviewContentTextView.isScrollEnabled = false
        reviewContentTextView.textContainer.lineFragmentPadding = 0
        reviewContentTextView.textContainerInset = .zero
        
        // Configure star buttons
        starButtons.forEach { button in
            button.isUserInteractionEnabled = false
            button.setImage(UIImage(systemName: "star"), for: .normal)
            button.tintColor = .systemYellow
        }
    }
    
    func configure(with review: Review) {
        reviewContentTextView.text = review.content
        reviewerNameLabel.text = review.username
        updateStars(rating: review.rating)
    }
    
    private func updateStars(rating: Int) {
        starButtons.enumerated().forEach { index, button in
            let imageName = index < rating ? "star.fill" : "star"
            button.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reviewContentTextView.text = nil
        reviewerNameLabel.text = nil
        updateStars(rating: 0)
    }
}
