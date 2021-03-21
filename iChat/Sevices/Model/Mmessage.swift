//
//  Mmessage.swift
//  iChat
//
//  Created by Вякулин Сергей on 10.03.2021.
//

import Foundation
import UIKit
import FirebaseFirestore
import MessageKit

struct ImageItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct senderType: SenderType {
    var senderId: String
    var displayName: String
}

//P208. Создаем модель данных для message

struct Mmessage: Hashable, MessageType {
    //P238. Возвращаемся к модели сообщения и подписываем под протокол MessageType для работы с библиотекой + реализуем свойства протокола
    var sender: SenderType //отправителль
    let content: String
//    let senderId: String
//    let senderUsername: String //удаляем данные свойства, они теперь будут содержаться внутри sender от протокола MessageType
    var sentDate: Date
    let id: String?
    
    var messageId: String {
        return id ?? UUID().uuidString
    }
    //атрибуты сообщения (текст фото и тд)
    var kind: MessageKind {
        //проверяем какой тип сообщения мы возвращаем
        if let image = image{
            let mediaItem = ImageItem(url: nil, image: nil, placeholderImage: image, size: image.size)
            return .photo(mediaItem)
        } else {
            return .text(content)
        }
    }
    
    var image: UIImage? = nil
    var downloadURL: URL? = nil
    
    
    
    init(user: MUser, content: String) {
        self.content = content
//        senderId = user.id
//        senderUsername = user.username
        self.sender = senderType(senderId: user.id, displayName: user.username)
        sentDate = Date()
        id = nil
    }
    
    //инициализатор для отображения изображения
    init(user: MUser, image: UIImage){
        sender = senderType(senderId: user.id, displayName: user.username)
        self.image = image
        content = ""
        sentDate = Date()
        id = nil
    }
    
    init?(document: QueryDocumentSnapshot){
        let data = document.data()
        guard let sentDate = data["created"] as? Timestamp else {return nil}
        guard let senderID = data["senderID"] as? String else {return nil}
        guard let senderName = data["senderName"] as? String else {return nil}
//        guard let content = data["content"] as? String else {return nil}
        
        
        
        self.id = document.documentID
        self.sentDate = sentDate.dateValue()
//        self.senderId = senderID
//        self.senderUsername = senderName
        self.sender = senderType(senderId: senderID, displayName: senderName)
        
        if let content = data["content"] as? String {
            self.content = content
            downloadURL = nil
        } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            downloadURL = url
            self.content = ""
        } else {
            return nil
        }
    }
    
    //P209.1 Создадим вычисляемое свойство в модели данных, для превращения в словарь, чтобы потом можно было записывать в коллекцию Firestore
    var representation: [String: Any] {
        var rep: [String: Any] = [
            "created": sentDate,
            "senderID": sender.senderId,
            "senderName": sender.displayName,
        ]
        
        if let url = downloadURL {
            rep["url"] = url.absoluteString
        } else {
            rep["content"] = content
        }
        
        return rep
    }
    
    //добавляем функции для реализации протоколов
    func hash(into hasher: inout Hasher) {
        hasher.combine(messageId)
    }
    
    static func == (lhs: Mmessage, rhs: Mmessage) -> Bool {
        return lhs.messageId == rhs.messageId
    }
}

//P245. Для возможности сортировки сообщений модель должна быть подписана под протокол Comperable
extension Mmessage: Comparable {
    static func < (lhs: Mmessage, rhs: Mmessage) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
    
    
}
