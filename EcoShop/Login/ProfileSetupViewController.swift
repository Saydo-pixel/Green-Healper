import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileSetupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var mobileField: UITextField!
    @IBOutlet weak var dobPicker: UIDatePicker!
    @IBOutlet weak var genderSegment: UISegmentedControl!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var letterButton: UIButton!

    var currentUser: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        createAccountButton.layer.cornerRadius = 8
        letterButton.layer.cornerRadius = 8
        
        // Make the image view tappable
        profileImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        profileImageView.addGestureRecognizer(tapGesture)
    }

    @objc func imageTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }

    @IBAction func createAccountButtonTapped(_ sender: UIButton) {
        guard let mobile = mobileField.text, !mobile.isEmpty,
              let gender = genderSegment.titleForSegment(at: genderSegment.selectedSegmentIndex) else {
            showAlert(title: "Error", message: "Please fill in all fields")
            return
        }
        
        guard let currentUser = currentUser else {
            showAlert(title: "Error", message: "User not found")
            return
        }
        
        let dob = dobPicker.date
        
        updateUserProfile(for: currentUser, withMobile: mobile, gender: gender, dateOfBirth: dob)
    }

    func updateUserProfile(for user: User, withMobile mobile: String, gender: String, dateOfBirth: Date) {
        let db = Firestore.firestore()
        let usersRef = db.collection("users").document(user.uid)
        
        let userData: [String: Any] = [
            "mobile": mobile,
            "gender": gender,
            "dateOfBirth": dateOfBirth,
            "profileImage": profileImageView.image?.jpegData(compressionQuality: 0) ?? ""
        ]
        
        usersRef.updateData(userData) { [weak self] error in
            if error != nil {
                self?.showAlert(title: "Error", message: "Failed to update user profile")
                return
            }
            
            self?.showAlert(title: "Success", message: "Profile updated successfully") {
                self?.navigateToDashboard(for: "user")
            }
        }
    }

    func navigateToDashboard(for userType: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var viewController: UIViewController?

        switch userType {
        case "user":
            // Navigate to user tab bar controller
            viewController = storyboard.instantiateViewController(withIdentifier: "userTabBar") as? UITabBarController
        case "owner":
            // Navigate to owner tab bar controller
            viewController = storyboard.instantiateViewController(withIdentifier: "ownerTabBar") as? UITabBarController
        case "admin":
            // Navigate to admin tab bar controller
            viewController = storyboard.instantiateViewController(withIdentifier: "adminTabBar") as? UITabBarController
        default:
            showAlert(title: "Error", message: "Invalid user type")
            return
        }

        if let viewController = viewController {
            viewController.modalPresentationStyle = .fullScreen
            present(viewController, animated: true, completion: nil)
        }
    }

    @IBAction func laterBtnClicked(_ sender: Any) {
        // Navigate directly to the user dashboard
        navigateToDashboard(for: "user")
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        DispatchQueue.main.async {
            if let pickedImage = info[.originalImage] as? UIImage {
                self.profileImageView.contentMode = .scaleAspectFill
                self.profileImageView.image = pickedImage
            }
            self.dismiss(animated: true, completion: nil)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }
}
