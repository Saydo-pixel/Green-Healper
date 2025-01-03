//
//  ProductDetailTableViewController.swift
//  EcoShop
//
//  Created by user244986 on 12/6/24.
//

import UIKit
import FirebaseStorage
import FirebaseCore

class StoreProductDetailTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var storeProduct: StoreProduct? = nil
    
    var imageURL: URL? = nil
    
    @IBOutlet var productIamgeView: UIImageView!
    @IBOutlet var descriptionTextView: UITextView!
    
    @IBOutlet var stockTextField: UITextField!
    @IBOutlet var plasticReducedTextField: UITextField!
    @IBOutlet var waterConsumedTextField: UITextField!
    @IBOutlet var co2SavedTextField: UITextField!
    @IBOutlet var priceTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var energySavedTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.layer.borderWidth = 1.0
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        
        productIamgeView.layer.cornerRadius = 5
        
        if let storeProduct = storeProduct {
            navigationItem.title = "Edit Product Details"
            
            descriptionTextView.text = storeProduct.description
            stockTextField.text = String(storeProduct.stockQuantity)
            nameTextField.text = storeProduct.name
            priceTextField.text = String(storeProduct.price)
            
            plasticReducedTextField.text = String(storeProduct.getMetricValue(name: "Plastic Waste Reduced"))
            waterConsumedTextField.text = String(storeProduct.getMetricValue(name: "Water Conserved"))
            co2SavedTextField.text = String(storeProduct.getMetricValue(name: "CO2 Emissions Saved"))
            energySavedTextField.text = String(storeProduct.getMetricValue(name: "Energy Saved"))
            
            imageURL = URL(string: storeProduct.imageURL)
            
            if let url = URL(string: storeProduct.imageURL) {
                URLSession.shared.dataTask(with: url) { (data, respnose, error) in
                    guard let imageData = data else { return }
                    DispatchQueue.main.async {
                        self.productIamgeView.image = UIImage(data: imageData)
                    }
                }.resume()
            }
        }
    }
    
    @IBAction func incrementQuantity(_ sender: UIButton) {
        if let int = Int(stockTextField.text ?? "") {
            stockTextField.text = "\(int + 1)"
        }
    }
    
    @IBAction func decrementQuantity(_ sender: UIButton) {
        if let int = Int(stockTextField.text ?? "") {
            guard int <= 0 else {
                stockTextField.text = "\(int - 1)"
                return
            }
        }
    }

    
    @IBAction func uploadImage(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage,
               let imageData = image.jpegData(compressionQuality: 0.8) {
                
                // Firebase upload
                let secondaryApp = FirebaseApp.app(name: "secondary")
                let storageRef = Storage.storage(app: secondaryApp!).reference()
                let imageRef = storageRef.child("images/\(UUID().uuidString).jpg")
                
                imageRef.putData(imageData) { metadata, error in
                    if let error = error {
                        print("Error uploading: \(error)")
                        return
                    }
                    
                    // Get download URL and set image
                    imageRef.downloadURL { url, error in
                        if let error = error {
                            print("Error uploading: \(error)")
                            return
                        }
                        
                        self.imageURL = url
                        
                        DispatchQueue.main.async {
                            self.productIamgeView.image = image
                            picker.dismiss(animated: true)
                        }
                    }
                }
            }
        }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let name = nameTextField.text, let price = Double(priceTextField.text ?? "0"), let stock = Int(stockTextField.text ?? "0"), let imageURL = self.imageURL, let description = descriptionTextView.text else {
            return
        }
        
        let co2Saved = Int(co2SavedTextField.text ?? "0") ?? 0
        let waterConserved = Int(waterConsumedTextField.text ?? "0") ?? 0
        let plasticReduced = Int(plasticReducedTextField.text ?? "0") ?? 0
        let energySaved = Int(energySavedTextField.text ?? "0") ?? 0
        
        if storeProduct != nil {
            storeProduct?.name = name
            storeProduct?.price = price
            storeProduct?.description = description
            storeProduct?.stockQuantity = stock
            storeProduct?.imageURL = imageURL.absoluteString
            storeProduct?.setMetricValue(name: "Plastic Waste Reduced", newValue: plasticReduced)
            storeProduct?.setMetricValue(name: "Water Conserved", newValue: waterConserved)
            storeProduct?.setMetricValue(name: "CO2 Emissions Saved", newValue: co2Saved)
            storeProduct?.setMetricValue(name: "Energy Saved", newValue: energySaved)
            
        } else {
            storeProduct = StoreProduct(storeOwnerId: "owner1", name: name, imageURL: imageURL.absoluteString, stockQuantity: stock, price: price, description: description, co2Saved: co2Saved, waterConserved: waterConserved, plasticReduced: plasticReduced, enerygySaved: energySaved)
        }
    }


}
