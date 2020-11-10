//
//  AuthError.swift
//  IChat
//
//  Created by Kirill Manvelov on 23.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import Foundation

enum AuthError {
    case notFilled
    case invalidEmail
    case passwordsNotMatched
    case serverError
}

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
 
        case .notFilled:
            return NSLocalizedString("All field are required", comment: "")
        case .invalidEmail:
            return NSLocalizedString("Invalid Email format", comment: "")
        case .passwordsNotMatched:
            return NSLocalizedString("Password not matched", comment: "")
        case .serverError:
             return NSLocalizedString("Server error", comment: "")
        }
    }
}
