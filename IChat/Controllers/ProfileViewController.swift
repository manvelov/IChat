//
//  ProfileViewController.swift
//  IChat
//
//  Created by Kirill Manvelov on 22.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController {
    
    let containerView = UIView()
    let imageView = UIImageView(image: #imageLiteral(resourceName: "human2"), contentMode: .scaleAspectFill)
    let nameLabel = UILabel(text: "Name placeholder", font: .systemFont(ofSize: 20, weight: .light))
    let aboutMeLabel = UILabel(text: "You have the opportunity to start a new chat!", font: .systemFont(ofSize: 16, weight: .light))
    let textField = InsertableTextField()
    
    private let user: MUser
    
    init(user: MUser) {
        self.user = user
        if let url = URL(string: user.avatarStringURL) {
            imageView.sd_setImage(with: url, completed: nil)
        }
        self.nameLabel.text = user.username
        self.aboutMeLabel.text = user.description
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureElements()
        setupConstraints()
    }
    
    private func configureElements() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutMeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        if let textButton = textField.rightView as? UIButton {
            textButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
        
        containerView.layer.cornerRadius = 30
        containerView.backgroundColor = .mainWhite()
        
        aboutMeLabel.numberOfLines = 0
    }
    
    @objc private func buttonTapped() {
        guard let message = textField.text, textField.text != "" else {
            return
        }
        self.dismiss(animated: true) {
            FirestoreService.shared.saveWaitingChat(message: message, receiver: self.user) { (result) in
                switch result {
                case .success():
                    UIApplication.getTopViewController()?.showAlert(with: "Success", and: "Request is delivered")
                case .failure(let error):
                    UIApplication.getTopViewController()?.showAlert(with: "Ooops", and: error.localizedDescription)
                }
            }
            
        }
    }
}

//MARK: - Setup Constraints
extension ProfileViewController {
    private func setupConstraints() {
        view.addSubview(imageView)
        view.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(aboutMeLabel)
        containerView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 206)
        ])
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: 30)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 35),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
        
        NSLayoutConstraint.activate([
            aboutMeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            aboutMeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            aboutMeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: aboutMeLabel.bottomAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            textField.heightAnchor.constraint(equalToConstant: 48)
        ])
        
    }
}
