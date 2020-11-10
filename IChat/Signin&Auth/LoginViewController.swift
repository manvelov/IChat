//
//  LoginViewController.swift
//  IChat
//
//  Created by Kirill Manvelov on 08.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController {
    
    let welcomeLabel = UILabel(text: "Welcome back!", font: .avenir26())
    
    let loginWithGoogleLabel = UILabel(text: "Login with")
    let orLabel = UILabel(text: "or")
    let emailLabel = UILabel(text: "Email")
    let passwordLabel = UILabel(text: "Password")
    let needAnAccountLabel = UILabel(text: "Need an account?")
    
    let googleButton = UIButton(title: "Google", titleColor: .black, backgroudColor: .white, isShadow: true)
    let loginButton = UIButton(title: "Login", titleColor: .mainWhite(), backgroudColor: .buttonDark())
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SignUp", for: .normal)
        button.setTitleColor( .buttonRed(), for: .normal)
        button.titleLabel?.font = .avenir20()
        return button
    }()
    
    let emailTextField = OneLineTextField(font: .avenir20())
    let passwordTextField = OneLineTextField(font: .avenir20())
    
    weak var delegate: AuthNavigatingDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        googleButton.customizeGoogleButton()
        setupConstraints()
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(googleButtonTapped), for: .touchUpInside)
        
        passwordTextField.isSecureTextEntry = true
    }
    
    @objc private func loginButtonTapped() {
        AuthService.shared.login(email: emailTextField.text, password: passwordTextField.text) { (result) in
            switch result {
                
            case .success(let user):
                FirestoreService.shared.getUserData(user: user) { (result) in
                    switch result {
                        
                    case .success(let muser):
                        self.showAlert(with: "Success", and: "Welcome back!") {
                            let mainTabBarVC = MainTabBarController(currentUser: muser)
                            mainTabBarVC.modalPresentationStyle = .fullScreen
                            self.present(mainTabBarVC, animated: true, completion: nil)
                        }
                    case .failure(let error):
                        if let error = error as? UserError {
                            switch error {
                                
                            case .notFilled:
                                self.showAlert(with: "Try again", and: error.localizedDescription)
                            case .photoNotExist:
                                self.showAlert(with: "Try again", and: "Please, add photo to your profile", complition: {
                                    self.present(SetupProfileViewController(currentUser: user), animated: true, completion: nil)
                                })
                            case .userDataNotFound:
                                self.showAlert(with: "Try again", and: "Please, complite your profile", complition: {
                                    self.present(SetupProfileViewController(currentUser: user), animated: true, completion: nil)
                                })
                            case .userDataCannotBeUnwrap:
                                self.showAlert(with: "Try again", and: "Sorry, try later")
                            }
                        } else {
                            self.showAlert(with: "Try again", and: error.localizedDescription)
                        }
                        
                        self.showAlert(with: "Try again", and: error.localizedDescription)
                    }
                }
            case .failure(let error):
                self.showAlert(with: "Try again", and: error.localizedDescription)
            }
        }
    }
    
    @objc private func signUpButtonTapped() {
        dismiss(animated: true) {
            self.delegate?.toSignUpVC()
        }
    }
    @objc private func googleButtonTapped() {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
    }
    
}

// MARK: - Setup Constraints
extension LoginViewController {
    private func setupConstraints() {
        let loginWithGoogleView = ButtonFromView(label: loginWithGoogleLabel, button: googleButton)
        let emailStackView = UIStackView(arrangedSubView: [emailLabel, emailTextField], axis: .vertical, spacing: 0)
        let passwordStackView = UIStackView(arrangedSubView: [passwordLabel, passwordTextField], axis: .vertical, spacing: 0)
        loginButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        let centetStackView = UIStackView(arrangedSubView: [loginWithGoogleView, orLabel, emailStackView, passwordStackView, loginButton],
                                          axis: .vertical,
                                          spacing: 40)
        
        signUpButton.contentHorizontalAlignment = .leading
        let bottomStackView = UIStackView(arrangedSubView: [needAnAccountLabel, signUpButton],
                                          axis: .horizontal,
                                          spacing: 10)
        bottomStackView.alignment = .firstBaseline
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        centetStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(welcomeLabel)
        view.addSubview(centetStackView)
        view.addSubview(bottomStackView)
        
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 160),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            centetStackView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant:  60),
            centetStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  40),
            centetStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -40)
        ])
        
        NSLayoutConstraint.activate([
            bottomStackView.topAnchor.constraint(equalTo: centetStackView.bottomAnchor, constant:  40),
            bottomStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  40),
            bottomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -40)
        ])
    }
}

// MARK: -Preview Provider
import SwiftUI

struct LoginVCProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable  {
        let viewController = LoginViewController()
        
        func makeUIViewController(context: Context) -> LoginViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: LoginVCProvider.ContainerView.UIViewControllerType, context: Context) {
        }
    }
}
