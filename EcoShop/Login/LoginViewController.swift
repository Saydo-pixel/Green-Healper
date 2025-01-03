import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {

    // UI elements
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the navigation bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Set up UI elements
        setupUI()
    }

    func setupUI() {
        // Configure UI elements here
        // For example:
        loginButton.layer.cornerRadius = 8
        registerButton.layer.cornerRadius = 8
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.showAlert(title: "Login Failed", message: error.localizedDescription)
                return
            }
            
            guard let user = result?.user else {
                self?.showAlert(title: "Error", message: "User not found")
                return
            }
            
            self?.checkUserType(for: user.uid)
        }
    }

    func checkUserType(for userId: String) {
        let db = Firestore.firestore()
        let usersRef = db.collection("users").document(userId)
        
        usersRef.getDocument { [weak self] document, error in
            if error != nil {
                self?.showAlert(title: "Error", message: "Failed to fetch user data")
                return
            }
            
            guard let document = document, document.exists else {
                self?.showAlert(title: "Error", message: "User data not found")
                return
            }
            
            if let userType = document.get("userType") as? String {
                UserDefaults.standard.set(userId, forKey: "user_uid")
                self?.handleLoginSuccess(for: userType)
            } else {
                self?.showAlert(title: "Error", message: "User type not found")
            }
        }
    }

    func handleLoginSuccess(for userType: String) {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            showAlert(title: "Error", message: "Unable to switch scenes")
            return
        }

        let storyboard: UIStoryboard
        var tabBarController: UITabBarController?

        switch userType {
        case "user":
            storyboard = UIStoryboard(name: "Main", bundle: nil)
            tabBarController = storyboard.instantiateViewController(withIdentifier: "userTabBar") as? UITabBarController

        case "owner":
            storyboard = UIStoryboard(name: "StoreOnwerDashboardStoryboard", bundle: nil)
            tabBarController = storyboard.instantiateViewController(withIdentifier: "StoreOwnerTabBarController") as? UITabBarController

        case "admin":
            storyboard = UIStoryboard(name: "Main", bundle: nil)
            tabBarController = storyboard.instantiateViewController(withIdentifier: "adminTabBar") as? UITabBarController

        default:
            showAlert(title: "Error", message: "Invalid user type")
            return
        }

        if let tabBarController = tabBarController {
            sceneDelegate.window?.rootViewController = tabBarController
            sceneDelegate.window?.makeKeyAndVisible()
        } else {
            showAlert(title: "Error", message: "Failed to load the \(userType) dashboard")
        }
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSignup" {
            if let loginVC = segue.destination as? SignUpViewController {
                loginVC.modalPresentationStyle = .fullScreen
            }
        }
        
        if segue.identifier == "userTabBar" {
            print("Navigating to User Tab Bar Controller")
        }
    }

    
}
