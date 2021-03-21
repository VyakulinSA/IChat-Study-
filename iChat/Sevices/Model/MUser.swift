//
//  MUser.swift
//  iChat
//
//  Created by Вякулин Сергей on 17.02.2021.
//

import Foundation
import FirebaseFirestore

//P93. Создадим структуру модели данных для user
//ВАЖНО: чтобы мы могли декодировать JSON у нас должны поля структуры данных совпадать со структурой JSON
struct MUser: Hashable, Decodable {
    //указываем, по какому параметру будут группироваться объекты внутри diffableDataSource
    var username: String
    var avatarStringURL: String
//    var id: Int
    //P149. Переделаем модель данных, расширим кол-во полей
    var email: String
    var description: String
    var sex: String
    var id: String
    
    init(username: String, avatarStringURL: String, email: String, description: String, sex: String, id: String) {
        self.username = username
        self.avatarStringURL = avatarStringURL
        self.email = email
        self.description = description
        self.sex = sex
        self.id = id
    }
    
    //P155. Создадим инициализатор, который будет получать инфо из документа (проваливающийся инициализатор init?)
    init?(document: DocumentSnapshot){
        //пытаемся получить data
        guard let data = document.data() else {return nil}
        //пытаемся получить данные о пользователе из data
        guard let username = data["username"] as? String,
              let avatarStringURL = data["avatarStringURL"] as? String,
              let email = data["email"] as? String,
              let description = data["description"] as? String,
              let sex = data["sex"] as? String,
              let id = data["uid"] as? String else {return nil}
        
        self.username = username
        self.avatarStringURL = avatarStringURL
        self.email = email
        self.description = description
        self.sex = sex
        self.id = id
    }
    
    //P197. Создадим инициализатор, который будет получать инфо из документа полученного от слушателя БД (проваливающийся инициализатор init?)
    init?(document: QueryDocumentSnapshot){
        //пытаемся получить data
        let data = document.data()
        //пытаемся получить данные о пользователе из data
        guard let username = data["username"] as? String,
              let avatarStringURL = data["avatarStringURL"] as? String,
              let email = data["email"] as? String,
              let description = data["description"] as? String,
              let sex = data["sex"] as? String,
              let id = data["uid"] as? String else {return nil}
        
        self.username = username
        self.avatarStringURL = avatarStringURL
        self.email = email
        self.description = description
        self.sex = sex
        self.id = id
    }
    
    //P150. Создадим вычисляемое свойство в модели данных, для превращения в словарь, чтобы потом можно было записывать в коллекцию Firestore
    var representation: [String: Any] {
        var rep = ["username": username]
        rep["sex"] = sex
        rep["avatarStringURL"] = avatarStringURL
        rep["email"] = email
        rep["description"] = description
        rep["uid"] = id
        return rep
    }
    
    //P112. Создадим метод для поиска значений по ключу
    func contains(filter: String?) -> Bool {
        guard let filter = filter else {return true} //проверяем nil
        if filter.isEmpty {return true} //проверяем пустоту
        let lowercasedFilter = filter.lowercased() //приводим к нижнему регистру
        return username.lowercased().contains(lowercasedFilter) //возвращает true или false при нахождении знаечния
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    //понимать по какому критерию будет идти сортировка
    static func == (lhs: MUser, rhs: MUser) -> Bool {
        return lhs.id == rhs.id
    }
}
