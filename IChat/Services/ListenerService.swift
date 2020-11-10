//
//  ListenerService.swift
//  IChat
//
//  Created by Kirill Manvelov on 30.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore


class ListenerService {
    static let shared = ListenerService()
    
    private let db = Firestore.firestore()
    
    private var userRef: CollectionReference {
        return db.collection("users")
    }
    
    private var waitingChatRef: CollectionReference {
        return db.collection(["users", currentUserId, "waitingChats"].joined(separator: "/"))
    }
    
    private var activeChatRef: CollectionReference {
        return db.collection(["users", currentUserId, "activeChats"].joined(separator: "/"))
    }
    
    private var currentUserId: String {
        return Auth.auth().currentUser!.uid
    }
    
    func usersObserve(users:[MUser], completion: @escaping (Result<[MUser], Error>) -> Void) -> ListenerRegistration? {
        var users = users
        let listener = userRef.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            snapshot.documentChanges.forEach { diff in
                guard let newUser = MUser(document: diff.document) else {
                    completion(.failure(error!))
                    return
                }
                switch diff.type {
                case .added:
                    guard !users.contains(newUser) else { return }
                    guard newUser.id != self.currentUserId else { return }
                    users.append(newUser)
                case .modified:
                    guard let index = users.firstIndex(of: newUser) else {return}
                    users[index] = newUser
                case .removed:
                    guard let index = users.firstIndex(of: newUser) else {return}
                    users.remove(at: index)
                }
            }
            completion(.success(users))
        }
        return listener
    }
    
    func waitingChatObserve(chats:[MChat], completion: @escaping (Result<[MChat], Error>) -> Void) -> ListenerRegistration? {
        var chats = chats
        let listener = waitingChatRef.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            snapshot.documentChanges.forEach { diff in
                guard let newChat = MChat(document: diff.document) else {
                    completion(.failure(error!))
                    return
                }
                switch diff.type {
                case .added:
                    guard !chats.contains(newChat) else { return }
                    chats.append(newChat)
                case .modified:
                    guard let index = chats.firstIndex(of: newChat) else {return}
                    chats[index] = newChat
                case .removed:
                    guard let index = chats.firstIndex(of: newChat) else {return}
                    chats.remove(at: index)
                }
            }
            completion(.success(chats))
        }
        
        return listener
    }
    
    
    func activeChatObserve(chats:[MChat], completion: @escaping (Result<[MChat], Error>) -> Void) -> ListenerRegistration? {
        var chats = chats
        let listener = activeChatRef.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            snapshot.documentChanges.forEach { diff in
                guard let newChat = MChat(document: diff.document) else {
                    completion(.failure(error!))
                    return
                }
                switch diff.type {
                case .added:
                    guard !chats.contains(newChat) else { return }
                    chats.append(newChat)
                case .modified:
                    guard let index = chats.firstIndex(of: newChat) else {return}
                    chats[index] = newChat
                case .removed:
                    guard let index = chats.firstIndex(of: newChat) else {return}
                    chats.remove(at: index)
                }
            }
            completion(.success(chats))
        }
        return listener
    }
    
    func messageObserve(chat: MChat, completion: @escaping (Result<MMessage, Error>) -> Void) -> ListenerRegistration? {
        let ref = activeChatRef.document(chat.friendId).collection("messages")
        
        let listener = ref.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            
            snapshot.documentChanges.forEach { (diff) in
                guard let message = MMessage(document: diff.document) else {return}
                switch diff.type {
                case .added:
                    completion(.success(message))
                case .modified:
                    break
                case .removed:
                    break
                }
            }
        }
        return listener
    }
}
