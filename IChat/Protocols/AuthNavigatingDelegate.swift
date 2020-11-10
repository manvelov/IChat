//
//  AuthNavigatingDelegate.swift
//  IChat
//
//  Created by Kirill Manvelov on 23.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import Foundation

protocol AuthNavigatingDelegate: class {
    
    func toLoginVC()
    
    func toSignUpVC()
}
