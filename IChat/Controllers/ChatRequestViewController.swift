//
//  ChatRequestViewController.swift
//  IChat
//
//  Created by Kirill Manvelov on 22.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import UIKit

class ChatRequestViewController: UIViewController {
    
    let containerView = UIView()
    let imageView = UIImageView(image: #imageLiteral(resourceName: "human2"), contentMode: .scaleAspectFill)
    let nameLabel = UILabel(text: "Name placeholder", font: .systemFont(ofSize: 20, weight: .light))
    let aboutMeLabel = UILabel(text: "You have the opportunity to start a new chat!", font: .systemFont(ofSize: 16, weight: .light))
    
    let acceptButton = UIButton(title: "ACCEPT", titleColor: .white, font: .laoSangamMN20(), backgroudColor: .black, isShadow: false, cornerRadius: 10)
    let denyButton = UIButton(title: "DENY", titleColor: #colorLiteral(red: 0.8352941176, green: 0.2, blue: 0.2, alpha: 1), font: .laoSangamMN20(), backgroudColor: .white, isShadow: false, cornerRadius: 10)
    
    private let chat: MChat
    weak var delegate: ChatNavigationDelegate?
    
    init(chat: MChat) {
        self.chat = chat
        self.imageView.sd_setImage(with: URL(string: chat.friendImageString), completed: nil)
        self.nameLabel.text = chat.friendUsername
        self.aboutMeLabel.text = chat.lastMessageContent
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureElements()
        setupConstraints()
        
        denyButton.addTarget(self, action: #selector(denyButtonTapped), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        acceptButton.applyGradients(cornerRadius: 10)
    }
    
        
    private func configureElements() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutMeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.layer.cornerRadius = 30
        containerView.backgroundColor = .mainWhite()
        
        aboutMeLabel.numberOfLines = 0
        
        denyButton.layer.borderWidth = 1.2
        denyButton.layer.borderColor = #colorLiteral(red: 0.8352941176, green: 0.2, blue: 0.2, alpha: 1)
        
    }
}

//MARK: -Actions
extension ChatRequestViewController {
    @objc private func denyButtonTapped() {
        self.dismiss(animated: true) {
            self.delegate?.removeWaitingСhat(chat: self.chat)
        }
    }
    
    @objc private func acceptButtonTapped() {
        self.dismiss(animated: true) {
            self.delegate?.changeToActive(chat: self.chat)
        }
    }
}

extension ChatRequestViewController {
    private func setupConstraints() {
        view.addSubview(imageView)
        view.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(aboutMeLabel)
        
        let buttonsStackView = UIStackView(arrangedSubView: [acceptButton,denyButton], axis: .horizontal, spacing: 7)
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(buttonsStackView)
        
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
            buttonsStackView.topAnchor.constraint(equalTo: aboutMeLabel.bottomAnchor, constant: 25),
            buttonsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 48)
        ])
        
    }
    
}
