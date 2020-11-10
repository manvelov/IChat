//
//  ActiveChatCell.swift
//  IChat
//
//  Created by Kirill Manvelov on 14.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import UIKit
import SDWebImage

class ActiveChatCell: UICollectionViewCell, SelfConfigureCell {
    
    static var reuseId: String = "ActiveChatCell"
    
    let friendImageView = UIImageView()
    let friendName = UILabel(text: "Name placeholder", font: .laoSangamMN20())
    let lastMessage = UILabel(text: "Message placeholder", font: .laoSangamMN18())
    
    let gradientView = GradientView(from: .topTrailing, to: .bottomLeading, startColor: #colorLiteral(red: 0.7882352941, green: 0.631372549, blue: 0.9411764706, alpha: 1), endColor: #colorLiteral(red: 0.4784313725, green: 0.6980392157, blue: 0.9215686275, alpha: 1))
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure<U>(with value: U) where U : Hashable {
        guard let value = value as? MChat else {
            fatalError("Unexpected type")
        }
        friendImageView.sd_setImage(with: URL(string: value.friendImageString), completed: nil)
        friendName.text = value.friendUsername
        lastMessage.text = value.lastMessageContent
    }
    
}

//MARK: -Setup Constraints
extension ActiveChatCell {
    private func setupConstraints() {
        friendImageView.translatesAutoresizingMaskIntoConstraints = false
        friendName.translatesAutoresizingMaskIntoConstraints = false
        lastMessage.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        
        friendImageView.backgroundColor = .systemRed
        
        self.addSubview(friendImageView)
        self.addSubview(friendName)
        self.addSubview(lastMessage)
        self.addSubview(gradientView)
        
        NSLayoutConstraint.activate([
            friendImageView.topAnchor.constraint(equalTo: self.topAnchor),
            friendImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            friendImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            friendImageView.widthAnchor.constraint(equalToConstant: 78),
            friendImageView.heightAnchor.constraint(equalToConstant: 78)
        ])
        
        NSLayoutConstraint.activate([
            friendName.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            friendName.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 16),
            friendName.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: 16)
        ])
        
        NSLayoutConstraint.activate([
            lastMessage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
            lastMessage.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 16),
            lastMessage.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: 16)
        ])
        
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: self.topAnchor),
            gradientView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            gradientView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            gradientView.widthAnchor.constraint(equalToConstant: 8),
            gradientView.heightAnchor.constraint(equalToConstant: 78)
        ])
    }
}
