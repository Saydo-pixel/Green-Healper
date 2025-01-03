//
//  FilterViewController.swift
//  EcoShop
//
//  Created by Sayed Shubbar Qasim on 23/12/2024.
//

import UIKit

protocol FilterDelegate: AnyObject {
    func applyFilters(minPrice: Double?, maxPrice: Double?, category: String?, minRating: Int?)
    func clearFilters() // Add this protocol method for clearing filters
}

class FilterViewController: UIViewController {
    
    @IBOutlet weak var minPriceTextField: UITextField!
    @IBOutlet weak var maxPriceTextField: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star5: UIButton!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    weak var delegate: FilterDelegate?
    
    private var selectedRating: Int = 0
    private let categories = ["Any", "Clothing", "Electronics", "Personal Care"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        setupStarButtons()
    }
    
    private func setupStarButtons() {
        [star1, star2, star3, star4, star5].enumerated().forEach { index, button in
            button?.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            button?.tag = index + 1
        }
        updateStarButtons()
    }
    
    @objc private func starTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        updateStarButtons()
    }
    
    private func updateStarButtons() {
        let stars = [star1, star2, star3, star4, star5]
        for (index, button) in stars.enumerated() {
            button?.setImage(UIImage(systemName: index < selectedRating ? "star.fill" : "star"), for: .normal)
            button?.tintColor = index < selectedRating ? .systemYellow : .gray
        }
    }
    
    @IBAction func applyFiltersTapped(_ sender: UIButton) {
        let minPrice = Double(minPriceTextField.text ?? "")
        let maxPrice = Double(maxPriceTextField.text ?? "")
        let selectedCategoryIndex = categoryPicker.selectedRow(inComponent: 0)
        let selectedCategory = categories[selectedCategoryIndex] == "Any" ? nil : categories[selectedCategoryIndex]
        
        delegate?.applyFilters(
            minPrice: minPrice,
            maxPrice: maxPrice,
            category: selectedCategory,
            minRating: selectedRating
        )
        self.dismiss(animated: true)
    }
    
    @IBAction func clearFiltersTapped(_ sender: UIButton) {
        // Clear all filter inputs
        minPriceTextField.text = nil
        maxPriceTextField.text = nil
        categoryPicker.selectRow(0, inComponent: 0, animated: true)
        selectedRating = 0
        updateStarButtons()
        
        // Notify the delegate to clear filters
        delegate?.clearFilters()
        self.dismiss(animated: true)
    }
}

extension FilterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
}
