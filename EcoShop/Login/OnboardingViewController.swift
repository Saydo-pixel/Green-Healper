import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginBtn.layer.cornerRadius = 8
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        // Present the login view controller full screen
        if let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true, completion: nil)
        }
    }
}
