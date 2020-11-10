//
//  StackView + Extension.swift
//  IChat
//
//  Created by Kirill Manvelov on 02.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import UIKit

extension UIStackView {
        
    convenience init(arrangedSubView: [UIView], axis: NSLayoutConstraint.Axis, spacing: CGFloat) {
        self.init(arrangedSubviews: arrangedSubView)
        self.axis = axis
        self.spacing = spacing
    }
}
