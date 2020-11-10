//
//  UIButton + Extension.swift
//  IChat
//
//  Created by Kirill Manvelov on 02.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import UIKit

extension UIButton {
    
    convenience init(title: String,
                     titleColor: UIColor,
                     font: UIFont? = .avenir20(),
                     backgroudColor: UIColor,
                     isShadow: Bool = false,
                     cornerRadius: CGFloat = 4){
        
        self.init(type: .system)
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.backgroundColor = backgroudColor
        self.titleLabel?.font = font
        self.layer.cornerRadius = cornerRadius
        
        
        if isShadow {
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowRadius = 4
            self.layer.shadowOpacity = 0.2
            self.layer.shadowOffset = CGSize(width: 0, height: 4)
            
        }
        
    }
    
    func customizeGoogleButton() {
        let googleLogo = UIImageView(image: #imageLiteral(resourceName: "googleLogo"), contentMode: .scaleAspectFit)
        googleLogo.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(googleLogo)
        NSLayoutConstraint.activate([
            googleLogo.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            googleLogo.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        
    }
}
 
