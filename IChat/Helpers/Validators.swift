//
//  Validators.swift
//  IChat
//
//  Created by Kirill Manvelov on 23.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import Foundation

class Validators {
    
    static func isFilled(email: String?, password: String?, confirmPassword: String?) -> Bool {
        guard let email = email,
        let password = password,
        let confirmPassword = confirmPassword,
        email != "",
        password != "",
        confirmPassword != "" else { return false }
        return true
    }
    
    static func isFilled(email: String?, sex: String?, description: String?) -> Bool {
           guard let email = email,
           let sex = sex,
           let description = description,
           email != "",
           sex != "",
           description != "" else { return false }
           return true
       }
    
    static func isSimpleEmail(_ email: String) -> Bool {
           let emailRegEx = "^.+@.+\\..{2,}$"
           return check(text: email, regEx: emailRegEx)
       }
       
       private static func check(text: String, regEx: String) -> Bool {
           let predicate = NSPredicate(format: "SELF MATCHES %@", regEx)
           return predicate.evaluate(with: text)
       }
}
