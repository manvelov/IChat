//
//  MUser.swift
//  IChat
//
//  Created by Kirill Manvelov on 17.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import UIKit
import FirebaseFirestore

struct MUser: Hashable, Decodable {
    var username: String
    var avatarStringURL: String
    var email: String
    var sex: String
    var description: String
    var id: String
        
    var representation: [String:Any] {
        var rep = ["username": username]
        rep["email"] = email
        rep["sex"] = sex
        rep["description"] = description
        rep["uid"] = id
        rep["avatarStringURL"] = avatarStringURL
        return rep
    }
    
    init(username: String, avatarStringURL: String, email: String, sex: String, description: String, id: String) {
        self.username = username
              self.avatarStringURL = avatarStringURL
              self.email = email
              self.sex = sex
              self.description = description
              self.id = id
    }
    
    init? (document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        
        guard let username = data["username"] as? String,
        let email = data["email"] as? String,
        let sex = data["sex"] as? String,
        let description = data["description"] as? String,
        let uid = data["uid"] as? String,
        let avatarStringURL = data["avatarStringURL"] as? String else { return nil }
        
        self.username = username
        self.avatarStringURL = avatarStringURL
        self.email = email
        self.sex = sex
        self.description = description
        self.id = uid
    }
    
    init? (document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let username = data["username"] as? String,
        let email = data["email"] as? String,
        let sex = data["sex"] as? String,
        let description = data["description"] as? String,
        let uid = data["uid"] as? String,
        let avatarStringURL = data["avatarStringURL"] as? String else { return nil }
        
        self.username = username
        self.avatarStringURL = avatarStringURL
        self.email = email
        self.sex = sex
        self.description = description
        self.id = uid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MUser, rhs: MUser) -> Bool {
        return lhs.id == rhs.id
    }
    
    func contains(filter: String?) -> Bool {
        guard let filter = filter else { return true}
        if filter.isEmpty { return true }
        let lowercasedFilter = filter.lowercased()
        return username.lowercased().contains(lowercasedFilter)
    }
    
}
