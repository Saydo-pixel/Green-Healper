import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import GoogleSignIn

// Service Layer for User Profile Management
class UserService {
    static func createUserProfile(uid: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
        Firestore.firestore().collection("users").document(uid).setData(data, completion: completion)
    }
}

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var googleBtn: UIButton!

    var loadingIndicator: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
    }

    func setupUI() {
        signUpButton.layer.cornerRadius = 8
        loginButton.layer.cornerRadius = 8
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator?.center = view.center
        if let indicator = loadingIndicator {
            view.addSubview(indicator)
        }
    }

    func toggleLoadingIndicator(_ show: Bool) {
        DispatchQueue.main.async {
            if show {
                self.loadingIndicator?.startAnimating()
                self.view.isUserInteractionEnabled = false
            } else {
                self.loadingIndicator?.stopAnimating()
                self.view.isUserInteractionEnabled = true
            }
        }
    }

    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        // Validate fields
        guard let name = nameField.text, !name.trimmingCharacters(in: .whitespaces).isEmpty,
              let email = emailField.text, !email.trimmingCharacters(in: .whitespaces).isEmpty,
              let password = passwordField.text, !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }

        if !isValidEmail(email) {
            showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
            return
        }

        if password.count < 6 {
            showAlert(title: "Weak Password", message: "Password must be at least 6 characters.")
            return
        }

        // Start loading
        toggleLoadingIndicator(true)

        // Firebase Signup
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            self?.toggleLoadingIndicator(false)

            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .emailAlreadyInUse:
                    self?.showAlert(title: "Error", message: "The email is already in use.")
                case .weakPassword:
                    self?.showAlert(title: "Error", message: "The password is too weak.")
                default:
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                }
                return
            }

            guard let user = result?.user else {
                self?.showAlert(title: "Error", message: "User not created.")
                return
            }

            // Create user profile
            self?.createUserProfile(for: user, withName: name, email: email)
        }
    }

    func createUserProfile(for user: User, withName name: String, email: String) {
        let userData: [String: Any] = [
            "name": name,
            "email": email,
            "userType": "user"
        ]

        UserService.createUserProfile(uid: user.uid, data: userData) { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Error", message: "Failed to create user profile: \(error.localizedDescription)")
                return
            }

            self?.showAlert(title: "Success", message: "User registered successfully.") {
                self?.performSegue(withIdentifier: SegueIdentifiers.toProfileSetup, sender: nil)
            }
        }
    }
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.toProfileSetup {
            if let profileSetupVC = segue.destination as? ProfileSetupViewController {
                UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "user_uid")
                profileSetupVC.currentUser = Auth.auth().currentUser
            }
        } else if segue.identifier == SegueIdentifiers.toLogin {
            if let loginVC = segue.destination as? LoginViewController {
                loginVC.modalPresentationStyle = .fullScreen
            }
        }
    }

    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }

    @IBAction func googleButtonTapped(_ sender: UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("Client ID not found. Please ensure GoogleService-Info.plist is included.")
        }

        let configuration = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }

            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                self.showAlert(title: "Error", message: "Failed to get user data")
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            self.toggleLoadingIndicator(true)
            Auth.auth().signIn(with: credential) { [weak self] result, error in
                self?.toggleLoadingIndicator(false)

                if let error = error {
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                    return
                }

                guard let firebaseUser = result?.user else { return }

                self?.createUserProfile(
                    for: firebaseUser,
                    withName: user.profile?.name ?? "",
                    email: user.profile?.email ?? ""
                )
            }
        }
    }
}

// Constants for Segue Identifiers
struct SegueIdentifiers {
    static let toProfileSetup = "toProfileSetup"
    static let toLogin = "toLogin"
}
