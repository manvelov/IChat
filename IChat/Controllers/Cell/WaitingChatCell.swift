//
//  WaitingChatCell.swift
//  IChat
//
//  Created by Kirill Manvelov on 15.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import UIKit
import SDWebImage

class WaitingChatCell: UICollectionViewCell, SelfConfigureCell {
    static var reuseId: String = "WaitingChatCell"
    
    func configure<U>(with value: U) where U : Hashable {
        guard let chat = value as? MChat else {
            fatalError("Unexpected type")
        }
       // friendImageView.image = UIImage(named: chat.userImageString)
        friendImageView.sd_setImage(with: URL(string: chat.friendImageString), completed: nil)
    }
    
    private let friendImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContraints()
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
    }
    
    private func setupContraints() {
        friendImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(friendImageView)
        NSLayoutConstraint.activate([
                 friendImageView.topAnchor.constraint(equalTo: self.topAnchor),
                 friendImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                 friendImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                 friendImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
             ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
