//
//  UserError.swift
//  IChat
//
//  Created by Kirill Manvelov on 24.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import Foundation

enum UserError {
    case notFilled
    case photoNotExist
    case userDataNotFound
    case userDataCannotBeUnwrap
}

extension UserError: LocalizedError {
    var errorDescription: String? {
        switch self {
 
        case .notFilled:
            return NSLocalizedString("All field are required", comment: "")
        case .photoNotExist:
            return NSLocalizedString("Photo not exist", comment: "")
        case .userDataNotFound:
             return NSLocalizedString("User data not found", comment: "")
        case .userDataCannotBeUnwrap:
            return NSLocalizedString("User data cannot be unwrap from Firebase", comment: "")
        }
    }
}
