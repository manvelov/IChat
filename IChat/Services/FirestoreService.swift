//
//  FirestoreService.swift
//  IChat
//
//  Created by Kirill Manvelov on 24.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase

class FirestoreService {
    
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    private var userRef: CollectionReference {
        let userRef = db.collection("users")
        return userRef
    }
    
    private var waitingChatRef: CollectionReference {
        let chatRef = db.collection( ["users", currentUser!.id, "waitingChats"].joined(separator: "/"))
        return chatRef
    }
    
    private var activeChatsRef: CollectionReference {
        let chatRef = db.collection( ["users", currentUser!.id, "activeChats"].joined(separator: "/"))
        return chatRef
    }
    
    private var currentUser: MUser?
    
    func getUserData(user: User, completion: @escaping (Result<MUser, Error>) -> Void){
        let docRef = userRef.document(user.uid)
        docRef.getDocument(completion: { (document, error) in
            if let document = document, document.exists {
                guard let muser = MUser(document: document) else {
                    completion(.failure(UserError.userDataCannotBeUnwrap))
                    return
                }
                self.currentUser = muser
                if muser.avatarStringURL != "" {
                    completion(.success(muser))
                } else { completion(.failure(UserError.photoNotExist)) }
            } else {
                completion(.failure(UserError.userDataNotFound))
            }
        })
    }
    
    func saveWaitingChat(message: String, receiver: MUser, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let currentUser = self.currentUser else { return }
        
        // ref to receiver's waiting chat collection
        let chatReference = db.collection(["users",receiver.id,"waitingChats"].joined(separator: "/"))
        // ref to receiver's messages in waiting chat collection from current user
        let messageRef = chatReference.document(currentUser.id).collection("messages")
        
        
        let message = MMessage(user: currentUser, content: message)
        let chat = MChat(friendUsername: currentUser.username,
                         friendImageString: currentUser.avatarStringURL,
                         lastMessageContent: message.content,
                         friendId: currentUser.id)
        
        chatReference.document(currentUser.id).setData(chat.representation) { (error) in
            if let error = error {
                completion(.failure(error))
            }
            messageRef.addDocument(data: message.representation) { (error) in
                if let error = error {
                    completion(.failure(error))
                }
                completion(.success(Void()))
            }
        }
    }
    
    
    func saveProfileWith(id: String, email: String, sex: String?, username: String?, description: String?, avatarImage: UIImage?, completion: @escaping (Result<MUser, Error>) -> Void) {
        
        guard Validators.isFilled(email: email, sex: sex, description: description) else {
            completion(.failure(UserError.notFilled))
            return
        }
        
        var user = MUser(username: username!,
                         avatarStringURL: "",
                         email: email,
                         sex: sex!,
                         description: description!,
                         id: id)
        
        if avatarImage == #imageLiteral(resourceName: "avatar-4") {
            self.userRef.document(user.id).setData(user.representation) { (error) in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(user))
                }
            }
        } else {
            StorageService.shared.uploadPhoto(photo: avatarImage!) { (result) in
                switch result {
                    
                case .success(let url):
                    user.avatarStringURL = url.absoluteString
                    self.userRef.document(user.id).setData(user.representation) { (error) in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(user))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func removeWaitingChat(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        waitingChatRef.document(chat.friendId).delete { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            self.deleteMessages(chat: chat, complition: completion)
        }
    }
    
    func getWaitingChatMessages(chat: MChat, completion: @escaping (Result<[MMessage], Error>) -> Void) {
        let messagesRef = waitingChatRef.document(chat.friendId).collection("messages")
        var messages = [MMessage]()
        messagesRef.getDocuments { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            for doc in snapshot.documents {
                guard let message = MMessage(document: doc) else { return }
                messages.append(message)
            }
            completion(.success(messages))
        }
    }
    
    func deleteMessages(chat: MChat, complition: @escaping (Result<Void, Error>) -> Void) {
        let messagesRef = waitingChatRef.document(chat.friendId).collection("messages")
        
        getWaitingChatMessages(chat: chat) { (result) in
            switch result {
            case .success(let messages):
                for message in messages {
                    guard let documentId = message.id else {
                        return
                    }
                    let messageRef = messagesRef.document(documentId)
                    messageRef.delete { (error) in
                        if let error = error {
                            complition(.failure(error))
                        }
                        complition(.success(Void()))
                    }
                }
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
    
    func createActiveChat(chat: MChat, messages: [MMessage], complition: @escaping (Result<Void, Error>) -> Void){
        let chatRef = activeChatsRef.document(chat.friendId)
        let messagesRef = chatRef.collection("messages")
        
        chatRef.setData(chat.representation) { (error) in
            if let error = error {
                complition(.failure(error))
                return
            }
            for message in messages {
                messagesRef.addDocument(data: message.representation) { (error) in
                    if let error = error {
                        complition(.failure(error))
                        return
                    }
                    complition(.success(Void()))
                }
            }
            
        }
    }
    
    func changeToActive(chat: MChat, complition: @escaping (Result<Void, Error>) -> Void) {
        getWaitingChatMessages(chat: chat) { (getMessagesResult) in
            switch getMessagesResult {
            case .success(let messages):
                self.removeWaitingChat(chat: chat) { (removeChatResult) in
                    switch removeChatResult {
                    case .success():
                        self.createActiveChat(chat: chat, messages: messages) { (createActiveChatResult) in
                            switch createActiveChatResult {
                            case .success():
                                complition(.success(Void()))
                            case .failure(let error):
                                complition(.failure(error))
                            }
                        }
                    case .failure(let error):
                        complition(.failure(error))
                    }
                }
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
    
    func saveMessage(chat: MChat, message: MMessage, complition: @escaping (Result<Void, Error>) -> Void ) {
        let friendChatRef = userRef.document(chat.friendId).collection("activeChats").document(currentUser!.id)
        let firendMessagesRef = friendChatRef.collection("messages")
        let currentUserMessagesRef = userRef.document(currentUser!.id).collection("activeChats").document(chat.friendId).collection("messages")
        
        let chatForFriend = MChat(friendUsername: currentUser!.username,
                                  friendImageString: currentUser!.avatarStringURL,
                                  lastMessageContent: message.content,
                                  friendId: currentUser!.id)
        
        friendChatRef.setData(chatForFriend.representation) { (error) in
            if let error = error {
                complition(.failure(error))
            }
            firendMessagesRef.addDocument(data: message.representation) { (error) in
                if let error = error {
                    complition(.failure(error))
                }
                currentUserMessagesRef.addDocument(data: message.representation) { (error) in
                    if let error = error {
                        complition(.failure(error))
                    }
                    complition(.success(Void()))
                }
            }
        }
    }
}


