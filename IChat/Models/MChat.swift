//
//  MChat.swift
//  IChat
//
//  Created by Kirill Manvelov on 17.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import UIKit
import FirebaseFirestore

struct MChat: Hashable, Decodable {
    var friendUsername: String
    var friendImageString: String
    var lastMessageContent: String
    var friendId: String
    
    var representation: [String:Any] {
        var rep = ["friendUsername": friendUsername]
        rep["friendImageString"] = friendImageString
        rep["lastMessage"] = lastMessageContent
        rep["friendId"] = friendId
        return rep
    }
    
    init(friendUsername: String,
         friendImageString: String,
         lastMessageContent: String,
         friendId: String) {
        
        self.friendUsername = friendUsername
        self.friendImageString = friendImageString
        self.lastMessageContent = lastMessageContent
        self.friendId = friendId
    }
    
    init? (document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let friendUsername = data["friendUsername"] as? String,
            let friendImageString = data["friendImageString"] as? String,
            let lastMessageContent = data["lastMessage"] as? String,
            let friendId = data["friendId"] as? String else { return nil }
        
        self.friendUsername = friendUsername
        self.friendImageString = friendImageString
        self.lastMessageContent = lastMessageContent
        self.friendId = friendId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(friendId)
    }
    
    static func == (lhs: MChat, rhs: MChat) -> Bool {
        return lhs.friendId == rhs.friendId
    }
    
}
