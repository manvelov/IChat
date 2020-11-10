//
//  AuthViewController.swift
//  IChat
//
//  Created by Kirill Manvelov on 02.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import UIKit
import GoogleSignIn


class AuthViewController: UIViewController {
    
    // MARK: ui elements
    
    let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Logo"), contentMode: .scaleAspectFit)
    
    let googleLabel = UILabel(text: "Get started with")
    let signUpLabel = UILabel(text: "Or sign up with")
    let alreadyOnboardLabel = UILabel(text: "Already onboard?")
    
    let googleButton = UIButton(title: "Google", titleColor: .black, backgroudColor: .white, isShadow: true)
    let emailButton = UIButton(title: "Email", titleColor: .mainWhite(), backgroudColor: .buttonDark())
    let loginButton = UIButton(title: "Login", titleColor: .buttonRed(), backgroudColor: .white, isShadow: true)
    
    let loginVC = LoginViewController()
    let signUpVC = SignUpViewController()
    
    // MARK: view lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureElements()
        setupConstraints()
    }
    
    @objc private func emailButtonTapped() {
        present(signUpVC, animated: true, completion: nil)
    }
    
    @objc private func loginButtonTapped() {
        present(loginVC, animated: true, completion: nil)
    }
    
    @objc private func googleButtonTapped() {
       GIDSignIn.sharedInstance()?.presentingViewController = self
       GIDSignIn.sharedInstance().signIn()
    }
    
    private func configureElements() {
        view.backgroundColor = .white
        googleButton.customizeGoogleButton()
        
        emailButton.addTarget(self, action: #selector(emailButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(googleButtonTapped), for: .touchUpInside)
        
        loginVC.delegate = self
        signUpVC.delegate = self
        
        GIDSignIn.sharedInstance().delegate = self
    }
    
    
}
// MARK: Setup Constraints
extension AuthViewController {
    private func setupConstraints() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        let googleView = ButtonFromView(label: googleLabel, button: googleButton)
        let loginView = ButtonFromView(label: alreadyOnboardLabel, button: loginButton)
        let emailView = ButtonFromView(label: signUpLabel, button: emailButton)
        let stackView = UIStackView(arrangedSubView: [googleView,emailView,loginView], axis: .vertical, spacing: 40)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(logoImageView)
        view.addSubview(stackView)
        
        logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 160).isActive = true
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        stackView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 160).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        
    }
}

// MARK: Auth Navigating Delegate
extension AuthViewController: AuthNavigatingDelegate {
    func toLoginVC() {
        self.present(loginVC, animated: true, completion: nil)
    }
    
    func toSignUpVC() {
        self.present(signUpVC, animated: true, completion: nil)
    }
    
    
}

// MARK: GID SignIn Delegate
extension AuthViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        AuthService.shared.googleLogin(user: user, error: error) { (result) in
            switch result{
                
            case .success(let user):
                FirestoreService.shared.getUserData(user: user) { (resultFromFirebase) in
                    switch resultFromFirebase {
                        
                    case .success(let muser):
                        UIApplication.getTopViewController()?.showAlert(with: "Success", and: "Welcome back!") {
                            let mainTabBarVC = MainTabBarController(currentUser: muser)
                            mainTabBarVC.modalPresentationStyle = .fullScreen
                             UIApplication.getTopViewController()?.present(mainTabBarVC, animated: true, completion: nil)}
                        
                    case .failure(_):
                         UIApplication.getTopViewController()?.showAlert(with: "Succes", and: "Please, complete your profile") {
                             UIApplication.getTopViewController()?.present(SetupProfileViewController(currentUser: user), animated: true, completion: nil)
                        }
                    }
                }
            case .failure(let authError):
                self.showAlert(with: "Try again", and: authError.localizedDescription)
            }
        }
        
    }
}

// MARK: Preview Provider
import SwiftUI

struct ViewControllerProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable  {
        let viewController = AuthViewController()
        
        func makeUIViewController(context: Context) -> AuthViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: ViewControllerProvider.ContainerView.UIViewControllerType, context: Context) {
        }
    }
}

