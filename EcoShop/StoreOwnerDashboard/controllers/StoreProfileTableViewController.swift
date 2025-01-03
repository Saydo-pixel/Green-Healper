//
//  StoreProfileTableViewController.swift
//  EcoShop
//
//  Created by Hasan Khesro on 12/26/24.
//

import UIKit
import FirebaseStorage
import FirebaseCore

class StoreProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var storeProfile: StoreProfile?
    
    @IBOutlet var descriptionTextField: UITextView!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var profileImageView: UIImageView!
    
    var imageURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = nil
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0

        descriptionTextField.layer.borderWidth = 1.0
        descriptionTextField.layer.borderColor = UIColor.black.cgColor
        
        profileImageView.layer.cornerRadius = 5
        
        Task {
            do {
                let storeOwnerId = "1drs5vwpmK5aY84zUbse"
                storeProfile = try await StoreProfile.fetchProfile(withId: storeOwnerId)
                
                nameTextField.text = storeProfile?.name
                emailTextField.text = storeProfile?.email
                descriptionTextField.text = storeProfile?.description
                
                if let profileImageURL = storeProfile?.profileImageURL, let url = URL(string: profileImageURL) {
                    URLSession.shared.dataTask(with: url) { (data, respnose, error) in
                        guard let imageData = data else { return }
                        DispatchQueue.main.async {
                            self.profileImageView.image = UIImage(data: imageData)
                        }
                    }.resume()
                }
            } catch {
                print("Error Fetching Store Profile \(error)")
            }
        }
    }

    // MARK: - Table view data source

    @IBAction func changeProfileImage(_ sender: UIButton) {
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
                            self.profileImageView.image = image
                            picker.dismiss(animated: true)
                        }
                    }
                }
            }
        }
    
    @IBAction func updateProfile(_ sender: UIButton) {
        guard let name = nameTextField.text, let email = emailTextField.text else {
            let alert = UIAlertController(
                title: "Missing Fields",
                message: "Please fill in the name and email fields since they are required.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        storeProfile?.name = name
        storeProfile?.email = email
        storeProfile?.description = descriptionTextField.text
        
        if let imageURL = self.imageURL {
            storeProfile?.profileImageURL = imageURL.absoluteString
        }
      
        Task {
            do {
                try await storeProfile?.updateProfile()
                let alert = UIAlertController(
                    title: "Update Successfull",
                    message: "Your profile details have been successfully updated.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            } catch {
                let alert = UIAlertController(
                    title: "Error",
                    message: "An error occured while updating your profile please try gain",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 6
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
