//
//  SelfConfigureCell.swift
//  IChat
//
//  Created by Kirill Manvelov on 15.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import Foundation

protocol SelfConfigureCell {
    static var reuseId: String { get }
    
    func configure<U: Hashable>(with value: U)
}
