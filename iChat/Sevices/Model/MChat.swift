//
//  MChat.swift
//  iChat
//
//  Created by Вякулин Сергей on 17.02.2021.
//

import Foundation
import FirebaseFirestore

//P56. реализуем ItemIdentifierType - идентификатор item для использования в diffableDataSourse
struct MChat: Hashable, Decodable {
    //указываем, по какому параметру будут группироваться объекты внутри diffableDataSource
    var friendUsername: String
    var friendAvatarStringURL: String
    var lastMessageContent: String
    var friendId: String //просят каждой модели данных приписывать id
    
    
    //P216. Создаем стандартный инициализатор, чтобы не было ошибок
    internal init(friendUsername: String, friendAvatarStringURL: String, lastMessageContent: String, friendId: String) {
        self.friendUsername = friendUsername
        self.friendAvatarStringURL = friendAvatarStringURL
        self.lastMessageContent = lastMessageContent
        self.friendId = friendId
    }
    //P214. Создадим инициализатор, который будет получать инфо из документа полученного от слушателя БД (проваливающийся инициализатор init?)
    init?(document: QueryDocumentSnapshot){
        //пытаемся получить data
        let data = document.data()
        //пытаемся получить данные о пользователе из data
        guard let friendUsername = data["friendUsername"] as? String,
              let friendAvatarStringURL = data["friendAvatarStringURL"] as? String,
              let lastMessageContent = data["lastMessage"] as? String,
              let friendId = data["friendId"] as? String else {return nil}
        
        self.friendUsername = friendUsername
        self.friendAvatarStringURL = friendAvatarStringURL
        self.lastMessageContent = lastMessageContent
        self.friendId = friendId

    }
    
    //P209. Создадим вычисляемое свойство в модели данных, для превращения в словарь, чтобы потом можно было записывать в коллекцию Firestore
    var representation: [String: Any] {
        var rep = ["friendUsername": friendUsername]
        rep["friendAvatarStringURL"] = friendAvatarStringURL
        rep["lastMessage"] = lastMessageContent
        rep["friendId"] = friendId
        return rep
    }
    

    //функция берется с сайта эпл, которые настоятельно рекомендуют реализовывать функцию hash
    func hash(into hasher: inout Hasher) {
        hasher.combine(friendId)
    }
    //понимать по какому критерию будет идти сортировка
    static func == (lhs: MChat, rhs: MChat) -> Bool {
        return lhs.friendId == rhs.friendId
    }

}
