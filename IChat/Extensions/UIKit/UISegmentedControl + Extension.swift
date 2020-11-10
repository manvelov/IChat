//
//  UISegmentedControl + Extension.swift
//  IChat
//
//  Created by Kirill Manvelov on 10.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import UIKit


extension UISegmentedControl {
    
    convenience init(first: String, second: String) {
        self.init()
        self.insertSegment(withTitle: first, at: 0, animated: true)
        self.insertSegment(withTitle: second, at: 1, animated: true)
        self.selectedSegmentIndex = 0
    }
}
