//
//  StorageService.swift
//  IChat
//
//  Created by Kirill Manvelov on 29.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

class StorageService {
    
    static var shared = StorageService()
    
    private let storageRef = Storage.storage().reference()

    private var avatarsRef: StorageReference {
        let avatarRef = storageRef.child("avatars")
        return avatarRef
    }
    
    private var currentUserId: String {
        return Auth.auth().currentUser!.uid
    }
    
    func uploadPhoto(photo: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        
        guard let scaledPhoto = photo.scaledToSafeUploadSize else {
            return
        }
        
        guard let imageData = scaledPhoto.jpegData(compressionQuality: 0.4) else {
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        avatarsRef.child(currentUserId).putData(imageData, metadata: metadata) { (responseMetadata, error) in
            guard let _ = responseMetadata else {
                completion(.failure(error!))
                return
            }
            
            self.avatarsRef.child(self.currentUserId).downloadURL { (url, error) in
            guard let downloadURL = url else {
                completion(.failure(error!))
              return
            }
                completion(.success(downloadURL))
            }
        }
    }
}
