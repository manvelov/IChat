//
//  MMessage.swift
//  IChat
//
//  Created by Kirill Manvelov on 30.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import UIKit
import FirebaseFirestore
import MessageKit

struct MMessage: Hashable, MessageType {
    
    var sender: SenderType
    let content: String
    var sentDate: Date
    let id: String?
    
    var messageId: String {
        return self.id ?? UUID().uuidString
    }
    
    var kind: MessageKind {
        return .text(content)
    }
    
    
    init(user: MUser, content: String) {
        self.sender = Sender(senderId: user.id, displayName: user.username)
        self.content = content
        self.sentDate = Date()
        self.id = nil
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let senderId = data["senderId"] as? String,
            let content = data["content"] as? String,
            let sentDate = data["created"] as? Timestamp,
            let senderUsername = data["senderUsername"] as? String else { return nil }
        
        self.content = content
        self.sentDate = sentDate.dateValue()
        self.sender = Sender(senderId: senderId, displayName: senderUsername)
        self.id = document.documentID
    }
    
    var representation: [String: Any] {
        let rep: [String: Any] = [
            "senderId": sender.senderId,
            "content": content,
            "created": sentDate,
            "senderUsername": sender.displayName]
        return rep
    }
    
    static func == (lhs: MMessage, rhs: MMessage) -> Bool {
        return lhs.messageId == rhs.messageId
    }
    
    func hash(into hasher: inout Hasher) {
          hasher.combine(messageId)
      }
}

extension MMessage: Comparable {
    static func < (lhs: MMessage, rhs: MMessage) -> Bool {
        lhs.sentDate < rhs.sentDate
    }
    
    
    
}
