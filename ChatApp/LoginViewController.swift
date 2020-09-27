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

    
    //MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTextFieldDelegate()
    }
    
    
    //MARK: - IBAction
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func resendEmailButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        
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
