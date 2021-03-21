//
//  StorageService.swift
//  iChat
//
//  Created by Вякулин Сергей on 07.03.2021.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseStorage

//P178. Создаем сервис для работы со Storage
class StorageService {
    
    static let shared = StorageService()
    
    //P182. В FireBase в меню Storage создаем папку для хранения аватаров пользователей
    //P183. Создаем ссылку на storage в firebase (см. документацию - загрузка файла (Storage))
    let storageRef = Storage.storage().reference()
    //P184. Создаем ссылку папку с фотками в storage в firebase
    private var avatarRef: StorageReference {
        return storageRef.child("avatars")
    }
    
    private var chatsRef: StorageReference {
        return storageRef.child("chats")
    }
    
    //P186. добавим свойство для хранения id пользователя
    private var currentUserId: String {
        return Auth.auth().currentUser!.uid
    }
    
    //P187. Создадим метод для загрузки фото (в сбегающем замыкании мы получаем в случае успеха, ссылку на изображение)
    func upload(photo: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        //сначала уменьшим изображения
        //scaledImage - пытаемся получить уменьшенное изображение
        //imageData - уменьшаем качество изображения jpegData до 40%
        guard let scaledImage = photo.scaledToSafeUploadSize,
              let imageData = scaledImage.jpegData(compressionQuality: 0.4) else { return }
        
        //создадим метадату для хранения информации о загружаемом файле
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        //загружаем изображение в БД и получаем ссылку на изображение
        avatarRef.child(currentUserId).putData(imageData, metadata: metadata) { (metadata, error) in
            //проверяем что в замыкании нам возвращается metadata - значит удалось загрузить изображение
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            //если все хорошо получаем ссылку на изображение
            self.avatarRef.child(self.currentUserId).downloadURL { (url, error) in
                guard let downloadURL = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(downloadURL))
            }
        }
        
    }
    
    //P260. реализуем метод по отправке фото в БД
    func uploadImageMessage(photo: UIImage, to chat: MChat, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let scaledImage = photo.scaledToSafeUploadSize,
              let imageData = scaledImage.jpegData(compressionQuality: 0.4) else { return }
        //создадим метадату для хранения информации о загружаемом файле
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        //создаем уникальный ключ для хранения изображения
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        //
        let uid: String = Auth.auth().currentUser!.uid
        //создаем уникальный ключ для имени чата
        let chatName = [chat.friendUsername, uid].joined()
        //кладем изображение по пути chatsRef.child(chatName).child(imageName)
        self.chatsRef.child(chatName).child(imageName).putData(imageData, metadata: metadata) { (metadata, error) in
            //проверяем что в замыкании нам возвращается metadata - значит удалось загрузить изображение
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            //если все хорошо получаем ссылку на изображение
            self.chatsRef.child(chatName).child(imageName).downloadURL { (url, error) in
                guard let downloadURL = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(downloadURL))
            }
        }
        
    }
    
    //P262. реализуем метод downloadImage в StorageService
    func downloadImage(url: URL, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        let ref = Storage.storage().reference(forURL: url.absoluteString)
        let megaByte = Int64(1*1024*1024)
        ref.getData(maxSize: megaByte) { (data, error) in
            guard let imageData = data else {
                completion(.failure(error!))
                return
            }
            completion(.success(UIImage(data: imageData)))
        }
    }
    
    
}
