import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var darkModeContainer: UIView!
    
    // MARK: - Properties
    private let defaults = UserDefaults.standard
    private let darkModeKey = "isDarkMode"
    private let db = Firestore.firestore()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        loadUserData()
        setupDarkMode()
        setupNavigationBar()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Setup profile image
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.isUserInteractionEnabled = true
        
        // Setup containers and buttons
        darkModeContainer.layer.cornerRadius = 12
        aboutButton.layer.cornerRadius = 12
        contactButton.layer.cornerRadius = 12
        
        
        
        // Profile Image
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.label.cgColor

        // Background Colors
        view.backgroundColor = .systemBackground
        darkModeContainer.backgroundColor = .secondarySystemBackground

        // Text Colors
        nameLabel.textColor = .label
        emailLabel.textColor = .secondaryLabel
        mobileLabel.textColor = .secondaryLabel
        dobLabel.textColor = .secondaryLabel
        genderLabel.textColor = .secondaryLabel

        // Button Styling
        aboutButton.backgroundColor = .secondarySystemBackground
        aboutButton.setTitleColor(.label, for: .normal)
        contactButton.backgroundColor = .secondarySystemBackground
        contactButton.setTitleColor(.label, for: .normal)
        
        
        // Set dark mode switch state
        darkModeSwitch.isOn = defaults.bool(forKey: darkModeKey)
        
        
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editProfileTapped)
        )
        
        // Add Logout button on the left
        let logoutButton = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
        logoutButton.tintColor = .red
        navigationItem.leftBarButtonItem = logoutButton
    }
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { _ in
            self.performLogout()
        })
        present(alert, animated: true)
    }

    private func performLogout() {
        do {
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Hasan", bundle: nil)
            if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                loginVC.modalPresentationStyle = .fullScreen
                present(loginVC, animated: true, completion: nil)
            }
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    
    private func setupGestures() {
        // Profile Image Tap
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(changeProfileImage))
        profileImageView.addGestureRecognizer(imageTap)
        
        // Name Label Tap
        let nameTap = UITapGestureRecognizer(target: self, action: #selector(changeNameTapped))
        nameLabel.isUserInteractionEnabled = true
        nameLabel.addGestureRecognizer(nameTap)
        
        // Mobile Label Tap
        let mobileTap = UITapGestureRecognizer(target: self, action: #selector(changeMobileTapped))
        mobileLabel.isUserInteractionEnabled = true
        mobileLabel.addGestureRecognizer(mobileTap)
        
        // DOB Label Tap
        let dobTap = UITapGestureRecognizer(target: self, action: #selector(changeDOBTapped))
        dobLabel.isUserInteractionEnabled = true
        dobLabel.addGestureRecognizer(dobTap)
        
        // Gender Label Tap
        let genderTap = UITapGestureRecognizer(target: self, action: #selector(changeGenderTapped))
        genderLabel.isUserInteractionEnabled = true
        genderLabel.addGestureRecognizer(genderTap)
    }
    
    private func setupDarkMode() {
        let isDarkMode = defaults.bool(forKey: darkModeKey)
        overrideUserInterfaceStyle = isDarkMode ? .dark : .light
    }
    
    // MARK: - Data Loading
    private func loadUserData() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        db.collection("users").document(currentUser.uid).getDocument { [weak self] snapshot, error in
            guard let self = self,
                  let data = snapshot?.data(),
                  error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                self.nameLabel.text = data["name"] as? String ?? "User"
                self.emailLabel.text = currentUser.email
                self.mobileLabel.text = "Mobile: \(data["mobile"] as? String ?? "Not Set")"
                
                if let dobTimestamp = data["dateOfBirth"] as? Timestamp {
                    let dobDate = dobTimestamp.dateValue()
                    self.dobLabel.text = "DOB: \(self.dateFormatter.string(from: dobDate))"
                } else {
                    self.dobLabel.text = "DOB: Not Set"
                }
                
                self.genderLabel.text = "Gender: \(data["gender"] as? String ?? "Not Set")"
                
                // Load profile image using the new structure
                if let profileImage = data["profileImage"] as? [String: Any],
                   let byteString = profileImage["_byteString"] as? String {
                    self.loadProfileImage(from: byteString)
                }
            }
        }
    }
    
    func loadProfileImage(from byteString: String) {
        // Convert the base64 encoded string to Data
        guard let imageData = Data(base64Encoded: byteString) else {
            print("Failed to convert byte string to Data")
            return
        }
        
        // Create a UIImage from the Data
        guard let image = UIImage(data: imageData) else {
            print("Failed to create UIImage from Data")
            return
        }
        
        // Assuming you have an UIImageView to display the image
        DispatchQueue.main.async {
            self.profileImageView.image = image
        }
    }
    
    // MARK: - Edit Actions
    @objc private func editProfileTapped() {
        let alert = UIAlertController(title: "Edit Profile", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Change Photo", style: .default) { [weak self] _ in
            self?.changeProfileImage()
        })
        
        alert.addAction(UIAlertAction(title: "Change Name", style: .default) { [weak self] _ in
            self?.changeNameTapped()
        })
        
        alert.addAction(UIAlertAction(title: "Change Mobile", style: .default) { [weak self] _ in
            self?.changeMobileTapped()
        })
        
        alert.addAction(UIAlertAction(title: "Change Date of Birth", style: .default) { [weak self] _ in
            self?.changeDOBTapped()
        })
        
        alert.addAction(UIAlertAction(title: "Change Gender", style: .default) { [weak self] _ in
            self?.changeGenderTapped()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func changeProfileImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    @objc private func changeNameTapped() {
        let alert = UIAlertController(title: "Change Name", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Enter new name"
            textField.text = self.nameLabel.text
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let newName = alert.textFields?.first?.text,
                  !newName.isEmpty else { return }
            self?.updateField("name", value: newName)
        })
        
        present(alert, animated: true)
    }
    
    @objc private func changeMobileTapped() {
        let alert = UIAlertController(title: "Change Mobile", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Enter mobile number"
            textField.keyboardType = .phonePad
            let currentMobile = self.mobileLabel.text?.replacingOccurrences(of: "Mobile: ", with: "")
            textField.text = currentMobile != "Not Set" ? currentMobile : ""
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let mobile = alert.textFields?.first?.text,
                  !mobile.isEmpty else { return }
            self?.updateField("mobile", value: mobile)
        })
        
        present(alert, animated: true)
    }
    
    @objc private func changeDOBTapped() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        let alert = UIAlertController(title: "Select Date of Birth", message: nil, preferredStyle: .actionSheet)
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250, height: 300)
        datePicker.frame = CGRect(x: 0, y: 0, width: 250, height: 300)
        vc.view.addSubview(datePicker)
        alert.setValue(vc, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            self?.updateField("dateOfBirth", value: Timestamp(date: datePicker.date))
        })
        
        present(alert, animated: true)
    }
    
    @objc private func changeGenderTapped() {
        let alert = UIAlertController(title: "Select Gender", message: nil, preferredStyle: .actionSheet)
        
        ["Male", "Female"].forEach { gender in
            alert.addAction(UIAlertAction(title: gender, style: .default) { [weak self] _ in
                self?.updateField("gender", value: gender ?? "Male")
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Update Methods
    private func updateField(_ field: String, value: Any) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).updateData([
            field: value
        ]) { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                switch field {
                case "name":
                    self?.nameLabel.text = value as? String
                case "mobile":
                    self?.mobileLabel.text = "Mobile: \(value as? String ?? "")"
                case "dateOfBirth":
                    if let timestamp = value as? Timestamp {
                        self?.dobLabel.text = "DOB: \(self?.dateFormatter.string(from: timestamp.dateValue()) ?? "")"
                    }
                case "gender":
                    self?.genderLabel.text = "Gender: \(value as? String ?? "")"
                default:
                    break
                }
                self?.showAlert(title: "Success", message: "\(field.capitalized) updated successfully")
            }
        }
    }
    
    private func uploadProfileImage(_ image: UIImage) {
        guard let userId = Auth.auth().currentUser?.uid,
              let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        // Show loading indicator
        let loadingAlert = UIAlertController(title: nil, message: "Updating profile image...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        loadingAlert.view.addSubview(loadingIndicator)
        present(loadingAlert, animated: true)
        
        // Convert image data to base64 string
        let base64String = imageData.base64EncodedString()
        
        // Update Firestore with the base64 string
        db.collection("users").document(userId).updateData([
            "profileImage": [
                "_byteString": base64String
            ]
        ]) { [weak self] error in
            guard let self = self else { return }
            
            self.dismiss(animated: true) {
                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                    return
                }
                self.showAlert(title: "Success", message: "Profile image updated successfully")
            }
        }
    }

    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else {
            return
        }
        
        profileImageView.image = image
        uploadProfileImage(image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // MARK: - Dark Mode Actions
    @IBAction func darkModeToggled(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: darkModeKey)
        
        UIView.animate(withDuration: 0.3) {
            self.overrideUserInterfaceStyle = sender.isOn ? .dark : .light
        }
        
        NotificationCenter.default.post(
            name: .darkModeChanged,
            object: nil,
            userInfo: ["isDarkMode": sender.isOn]
        )
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Dark Mode Notification Extension
extension Notification.Name {
    static let darkModeChanged = Notification.Name("DarkModeChanged")
}
