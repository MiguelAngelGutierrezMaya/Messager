//
//  ViewController.swift
//  Messenger
//
//  Created by Keybe on 1/09/23.
//

import UIKit
import ProgressHUD

class LoginViewController: UIViewController {
    
    // MARK: - IBOutlets
    // Labels
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var repeatPasswordLabel: UILabel!
    
    @IBOutlet weak var signUpLabel: UILabel!
    
    // text fields
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    // Buttons
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var resendEmailButton: UIButton!
    
    // Views
    @IBOutlet weak var repeatPasswordLineView: UIView!
    
    // MARK: - Properties
    var isLogin: Bool = true
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateUIFor(login: true)
        setupTextFieldDelegates()
        setupBackgroundTap()
    }
    
    // MARK: - IBActions
    @IBAction func loginButtonPressed(_ sender: Any) {
        if isDataInputedFor(type: isLogin ? "login" : "register") {
            // login or register
            isLogin ? loginUser() : registerUser()
        } else {
            // show error message
            ProgressHUD.failed("All fields are required!")
        }
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        if isDataInputedFor(type: "forgot-password") {
            // forgot password
           resetPassword()
        } else {
            // show error message
            ProgressHUD.failed("Email is required!")
        }
    }
    
    @IBAction func resendEmailButtonPressed(_ sender: Any) {
        if isDataInputedFor(type: "reset-password") {
            // resend email
            resendVerificationEmail()
        } else {
            // show error message
            ProgressHUD.failed("Email is required!")
        }
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        updateUIFor(login: sender.titleLabel?.text == "Login")
        isLogin.toggle()
    }
    
    // MARK: - Setup UI
    private func setupTextFieldDelegates() {
        emailTextField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
        passwordTextField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
        repeatPasswordTextField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        updatePlaceholderLabels(textField: textField)
    }
    
    private func setupBackgroundTap() {
        let tapGesture = UITapGestureRecognizer(
            target: self, 
            action: #selector(backgroundTap)
        )
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func backgroundTap() {
        view.endEditing(false)
    }
    
    // MARK: - Animations
    private func updateUIFor(login: Bool) {
        loginButton.setImage(
            UIImage(named: login ? "loginBtn" : "registerBtn"),
            for: .normal
        )
        
        signUpButton.setTitle(login ? "SignUp" : "Login", for: .normal)
        signUpLabel.text = login ? "Don't have an account?" : "Already have an account?"
        
        UIView.animate(withDuration: 0.5) {
            self.repeatPasswordTextField.isHidden = login
            self.repeatPasswordLabel.isHidden = login
            self.repeatPasswordLineView.isHidden = login
        }
    }
    
    private func updatePlaceholderLabels(textField: UITextField) {
        switch textField {
        case emailTextField:
            emailLabel.text = textField.hasText ? "Email" : ""
        case passwordTextField:
            passwordLabel.text = textField.hasText ? "Password" : ""
        default:
            repeatPasswordLabel.text = textField.hasText ? "Repeat Password" : ""
        }
    }
    
    // MARK: - Helpers
    private func isDataInputedFor(type: String) -> Bool {
        switch type {
        case "login":
            return emailTextField.text != "" && passwordTextField.text != ""
        case "register":
            return emailTextField.text != "" && passwordTextField.text != "" && repeatPasswordTextField.text != ""
        default:
            return emailTextField.text != ""
        }
    }
    
    private func loginUser() {
        FirebaseUserListener.shared.loginUserWithEmail(email: emailTextField.text ?? "", password: passwordTextField.text ?? "") { error, isEmailVerified in
            if let error = error {
                ProgressHUD.failed(error.localizedDescription)
                return
            }
            
            if isEmailVerified {
                // redirect to app
                self.goToApp()
            } else {
                ProgressHUD.failed("Please verify email.")
                self.resendEmailButton.isHidden = false
            }
        }
    }
    
    private func registerUser() {
        if passwordTextField.text == repeatPasswordTextField.text {
            // register
            FirebaseUserListener.shared.registerUserWith(
                email: emailTextField.text ?? "",
                password: passwordTextField.text ?? ""
            ) { error in
                if error == nil {
                    ProgressHUD.success("Verification email sent!")
                    self.resendEmailButton.isHidden = false
                } else {
                    ProgressHUD.failed(error!.localizedDescription)
                }
            }
        } else {
            ProgressHUD.failed("Passwords don't match!")
        }
    }
    
    private func resetPassword() {
        FirebaseUserListener.shared.resetPassword(
            email: emailTextField.text ?? ""
        ) { error in
            if let error = error {
                ProgressHUD.failed(error.localizedDescription)
            } else {
                ProgressHUD.failed("Reset link sent to email.")
            }
        }
    }
    
    private func resendVerificationEmail() {
        FirebaseUserListener.shared.resendVerificationEmail(
            email: emailTextField.text ?? ""
        ) { error in
            if let error = error {
                ProgressHUD.failed(error.localizedDescription)
            } else {
                ProgressHUD.success("Verification email sent!")
            }
        }
    }
    
    // MARK: - Navigation
    private func goToApp() {
        let storyBoard = UIStoryboard(
            name: "Main",
            bundle: nil
        ).instantiateViewController(identifier: "MainView") as UITabBarController?
        
        if let mainView = storyBoard {
            mainView.modalPresentationStyle = .fullScreen
            self.present(mainView, animated: true, completion: nil)
        }
    }
    
}

