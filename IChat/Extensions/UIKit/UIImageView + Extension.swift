//
//  UIImageView + Extension.swift
//  IChat
//
//  Created by Kirill Manvelov on 02.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import UIKit

extension UIImageView {
    convenience init(image: UIImage?, contentMode: UIView.ContentMode) {
        self.init(image: image)
        self.contentMode = contentMode
    }
}

extension UIImageView {
  func setupColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}
