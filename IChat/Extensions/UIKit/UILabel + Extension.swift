//
//  UILabel + Extension.swift
//  IChat
//
//  Created by Kirill Manvelov on 02.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import UIKit

extension UILabel {
    
    convenience init(text: String, font: UIFont? = .avenir20()){
        self.init()
        self.text = text
        self.font = font
    }
    
}
