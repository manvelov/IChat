//
//  ChatNavigationDelegate.swift
//  IChat
//
//  Created by Kirill Manvelov on 06.10.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import Foundation

protocol ChatNavigationDelegate: class {

    func removeWaitingСhat(chat: MChat)
    
    func changeToActive(chat: MChat)
}
