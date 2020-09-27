//
//  ViewController.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 9/26/20.
//

import UIKit

class LoginViewController: UIViewController {

    
    //MARK: - IBOutlets
    
    
    // Labels
    @IBOutlet weak var emailLabelOutlet: UILabel!
    @IBOutlet weak var passwordLabelOutlet: UILabel!
    @IBOutlet weak var repeatPasswordOutlet: UILabel!
    @IBOutlet weak var signUpLabelOutlet: UILabel!
    
    // TextFields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    // Buttons
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var signUpButtonOutlet: UIButton!
    @IBOutlet weak var resentEmailButtonOutlet: UIButton!
    
    // Views
    @IBOutlet weak var repeatPasswordLineView: UIView!
    
    
    //MARK: - Variables
    
    var isLogin = true

    
    
    //MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUIFor(login: true)
        setUpTextFieldDelegate()
    }
    
    
    //MARK: - IBAction
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func resendEmailButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        updateUIFor(login: sender.titleLabel?.text == "Login")
        isLogin.toggle()
    }
    
    
    //MARK: - Set Up Text Field
    
    func setUpTextFieldDelegate() {
        emailTextField.addTarget(self, action: #selector(textfieldDidChanged(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textfieldDidChanged(_:)), for: .editingChanged)
        repeatPasswordTextField.addTarget(self, action: #selector(textfieldDidChanged(_:)), for: .editingChanged)
    }
    
    @objc func textfieldDidChanged(_ textField: UITextField) {
        updatePlaceHolderLabels(textfield: textField)
    }
    
    
    //MARK: -  Animations
    
    private func updateUIFor(login: Bool) {
        // UI like toggle changes
        loginButtonOutlet.setImage(UIImage(named: login ? "loginButton" : "registerButton"), for: .normal)
        signUpButtonOutlet.setTitle(login ? "Sign up!" : "Login", for: .normal)
        

        signUpLabelOutlet.text = login ? "Don't have an account?" : "Have an account?"
        
        // Repeat password animation
        UIView.animate(withDuration: 0.4) {
            self.repeatPasswordTextField.isHidden = login
            self.repeatPasswordOutlet.isHidden = login
            self.repeatPasswordLineView.isHidden = login
        }
    }
    
    
    //MARK: - Update placeholders
    
    private func updatePlaceHolderLabels(textfield: UITextField) {
        
        switch textfield {
        
        case emailTextField:
            emailLabelOutlet.text = textfield.hasText ? "Email" : ""
            
        case passwordTextField:
            passwordLabelOutlet.text = textfield.hasText ? "Password" : ""
          
        default:
            repeatPasswordOutlet.text = textfield.hasText ? "Repeat password" : ""
        }
    }
}
