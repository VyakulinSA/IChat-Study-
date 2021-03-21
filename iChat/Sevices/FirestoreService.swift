//
//  FirestoreService.swift
//  iChat
//
//  Created by Вякулин Сергей on 27.02.2021.
//

import Firebase
//P145. Установим Firestore через podFile и импортируем FireSstore
import FirebaseFirestore

//P146. Создаем вспомогательный класс для работы с Firestore Firebase
class FirestoreService {
    //делаем синглтон
    static let shared = FirestoreService()
    //делаем ссылку на базу данных (как в документации)
    let db = Firestore.firestore()
    
    //свойство для хранения ссылки на коллекцию
    private var usersRef: CollectionReference {
        return db.collection("users")
    }
    
    //указываем ссылку на ожидающие чаты, чтобы она инициализировалась по умолчанию всегда
    private var waitingChatsRef: CollectionReference {
        return db.collection(["users",currentUser.id,"waitingChats"].joined(separator: "/"))
    }
    //P228.2 добавим ссылку на активные чаты (создается сама если не существует)
    private var activeChatsRef: CollectionReference {
        return db.collection(["users",currentUser.id,"activeChats"].joined(separator: "/"))
    }
    
    
    
    //P206.Создаем текущего пользователя
    var currentUser: MUser!
    
    //P154. Добавляем проверку, что у пользователя заполнен профиль, и если да, то переходим к чатам, если нет, то переходим на заполнение профиля
    func getUserData(user: User, completion: @escaping (Result<MUser,Error>) -> Void) {
        //добираемся до документа определенного юзера в коллекции users
        let docRef = usersRef.document(user.uid)
        //получаем информацию из документа getDocument(completion)
        docRef.getDocument { (document, error) in
            //проверяем наличие докуммента
            if let document = document, document.exists {
                //пытаемся получить информацию о пользователе, через инициализатор созданный в P155
                guard let muser = MUser(document: document) else {
                    completion(.failure(UserError.canNotUnwrapToMUser))
                    return
                }
                //если все хорошо
                //P207. если успешно дополнительно инициализируем текущего пользователя
                self.currentUser = muser
                completion(.success(muser))
            } else {
                completion(.failure(UserError.canNotGetUserInfo))
            }
        }
    }
    
    //функция для записи информации в коллекцию
    //P179. Корректируем функцию и для изображения пишем не String а UIImage
    func saveProfileWith(id: String, email: String, username: String?, avatarImage: UIImage?,
                         description: String?, sex: String?, completion: @escaping (Result<MUser, Error>) -> Void) {
        //P147. Добавляем еще проверку в файл Validators (см. Validators)
        //делаем проверку на заполненность полей
        guard Validators.isFilled(username: username, description: description, sex: sex) else {
            //P148. создадим еще один обработчик ошибок для работы с пользователем (см. UsersError) и возвращаем ошибку, ели требуется
            completion(.failure(UserError.notFilled))
            return
        }
        
        //P181.Добавляем проверку на наличие изображения
        guard avatarImage != #imageLiteral(resourceName: "avatar") else {
            completion(.failure(UserError.photoNotExists))
            return
        }
        //P149. Переделаем модель данных, расширим кол-во полей (см. MUser)
        //инициализируем объект модели данных, который наполняем данными передаваемыми в функцию, которые поступают из полей с экрана (см.SetupProfile)
        var muser = MUser(username: username!,
                          avatarStringURL: "not exists",
                          email: email,
                          description: description!,
                          sex: sex!,
                          id: id)
        
            //P188. после создания объекта пользователя, надо загрузить его изображение в БД
        StorageService.shared.upload(photo: avatarImage!) { (result) in
            switch result {
            case .success(let url):
                //присваиваем ссылку на изображение только что созданному пользователю
                muser.avatarStringURL = url.absoluteString
                //P189. Переносим логику сохранения пользователя в базу, только тогда когда он установил изображение (это не совсем правильно, но в этом приложении так)
            
                //P150. Создадим вычисляемое свойство в модели данных, для превращения в словарь, чтобы потом можно было записывать в коллекцию Firestore (см. MUser)
                //добавляем документ в коллекцию, через метод document, т.к. можем ему указать параметр ключа (через addDocument так не получится) + Setdata(передаем словарь значений + замыкание)
                self.usersRef.document(muser.id).setData(muser.representation) { (error) in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(muser))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        } //StorageService
        
//        //P150. Создадим вычисляемое свойство в модели данных, для превращения в словарь, чтобы потом можно было записывать в коллекцию Firestore (см. MUser)
//        //добавляем документ в коллекцию, через метод document, т.к. можем ему указать параметр ключа (через addDocument так не получится) + Setdata(передаем словарь значений + замыкание)
//        self.usersRef.document(muser.id).setData(muser.representation) { (error) in
//            if let error = error {
//                completion(.failure(error))
//            } else {
//                completion(.success(muser))
//            }
//        }
    } //saveProfileWith
    
    //P205. Создаем метод для отправки сообщения и запроса чата в firestore
    /// createWaitingChat
    /// - Parameters:
    ///   - message: сообщение
    ///   - receiver: получатель
    ///   - completion: возвращаем в замыкании то что получаем
    func createWaitingChat(message: String, receiver: MUser, completion: @escaping (Result<Void, Error>) -> Void) {
        //Создаем ссылку(тем самым создаем коллекцию ожидающих чатов(если первый раз)) у пользователя
        //в массиве мы через запятую пишем путь до нужной коллекции и объединяем все через "/" - типо "users/id/waitingChat"
        let reference = db.collection(["users", receiver.id, "waitingChats"].joined(separator: "/")) //у получателя(receiver.id) создали коллекцию waitingChats
        //по ссылке на коллекцию waitingChat мы создаем новый документ c id совпадающий с айди пользователя который пишет сообщение + в документе создаем коллекцию messages
        //создаем нужные нам свойства для инициализации ссылки на коллекцию messages ( см 206-207 )
        let messageRef = reference.document(self.currentUser.id).collection("messages")
        
        //создадим объект сообщения который объявили в пункте 208
        let message = Mmessage(user: currentUser, content: message)
        //создадим объект чата, с заполненными данными
        // в нашем случае, мы сохраняем свои текущие данные, для другого пользователя.
        let chat = MChat(friendUsername: currentUser.username,
                         friendAvatarStringURL: currentUser.avatarStringURL,
                         lastMessageContent: message.content,
                         friendId: currentUser.id)
        //добавим свойства representation в модели данных MChat и Mmmesage, чтобы была возможность превращать модель в словарь для Firestore см P209 и P209.1
        
        //сохраняем данные waitingChats для пользователя с id пользователя, который отправляет запрос
        reference.document(currentUser.id).setData(chat.representation) { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            //если нет ошибки по созданию waitingChats, то добавляем документ в коллекцию messages
            messageRef.addDocument(data: message.representation) { (error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(Void()))
            }
        }
    }
    
    //P226. Создадим сервис по удалению ожидающих чатов из БД
    func deleteWaitingChat(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        waitingChatsRef.document(chat.friendId).delete { (error) in
            if let error = error {
                completion(.failure(error ))
                return
            }
            completion(.success(Void()))
            self.deleteMessages(chat: chat, completion: completion)
        }
    }
    
    //P226.2. вспомогательная функция для удаленния коллекции messages из waitingChats
    private func deleteMessages(chat:MChat, completion: @escaping (Result<Void, Error>) -> Void){
        let reference = waitingChatsRef.document(chat.friendId).collection("messages")
        //получаем все сообщения и в замыкании в случае успеха удаляем каждое сообщение
        getWaitingChatMessages(chat: chat) { (result) in
            switch result{
            case .success(let messages):
                for message in messages {
                    //получаем ссылку на документ
                    guard let documentId = message.id else {return}
                    let messageRef = reference.document(documentId)
                    messageRef.delete { (error) in
                        if let error = error {
                            completion(.failure(error ))
                            return
                        }
                        completion(.success(Void()))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
                
            }
        }
    }
    
    //P226.1. добавим вспомогательную функцию, для получения коллекции с сообщениями из ожидающего чата
    private func getWaitingChatMessages(chat: MChat, completion: @escaping (Result<[Mmessage], Error>) -> Void) {
        //создаем ссылку на сообщения
        let reference = waitingChatsRef.document(chat.friendId).collection("messages")
        var messages = [Mmessage]()
        //получаем все документы из коллекции messages
        reference.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error ))
                return
            }
            for document in querySnapshot!.documents {
                guard let message = Mmessage(document: document) else {return}
                messages.append(message)
            }
            completion(.success(messages))
        }
    }
    
    //P228. Функция смены чата с ожидающего на активный
    func changeToActive(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void){
        //получаем все сообщения из ожидающего чата
        getWaitingChatMessages(chat: chat) { (result) in
            switch result {
            //если смогли получть, удаляем чат
            case .success(let messages):
                self.deleteWaitingChat(chat: chat) { (result) in
                    switch result{
                    case .success():
                        //если удалось удалить ожидающий чат, создаем активный
                        self.createActiveChat(chat: chat, messages: messages) { (result) in
                            switch result {
                            case .success():
                                completion(.success(Void()))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    //P228.1 Вспомогательная функция для создания активных чатов
    private func createActiveChat(chat: MChat, messages: [Mmessage], completion: @escaping (Result<Void, Error>) -> Void) {
        //добавим ссылку на коллекцию сообщений в активном чате (создается сама если не существует)
        let messageRef = activeChatsRef.document(chat.friendId).collection("messages")
        
        //создадим новый документ в коллекции активных чатов, кладем в него словарь(chat.representation) с данными о чате
        activeChatsRef.document(chat.friendId).setData(chat.representation) { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            //пробегаемся по массиву сообщений и складываем каждое
            for message in messages {
                messageRef.addDocument(data: message.representation) { (error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(Void()))
                }
            }
        }
    }
    
    //P250. Создаем функцию для отправки сообщений в БД
    func sendMessage(chat: MChat, message: Mmessage, completion: @escaping (Result<Void, Error>) -> Void) {
        //ссылка на час со мной у друга
        let friendRef = usersRef.document(chat.friendId).collection("activeChats").document(currentUser.id)
        //ссыдка на сообщения у друга
        let friendMessageRef = friendRef.collection("messages")
        //ссылка на мои сообщения
        let myMessageRef = usersRef.document(currentUser.id).collection("activeChats").document(chat.friendId).collection("messages")
        
        //создаем чат для друга (то есть складываем инфу о нас самих)
        let chatForFriend = MChat(friendUsername: currentUser.username, friendAvatarStringURL: currentUser.avatarStringURL, lastMessageContent: message.content, friendId: currentUser.id)
        //добавляем чат для друга
        friendRef.setData(chatForFriend.representation) { (error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            //если успешно то кладем туда сообщение
            friendMessageRef.addDocument(data: message.representation) { (error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                //если успешно кладем сообщение к нам
                myMessageRef.addDocument(data: message.representation) { (error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    //если успешно, то в комплишин возвращаем succes
                    completion(.success(Void()))
                }
            }
        }
    }
    
    
    
    //test
    
    func haveActiveChats(user: MUser, completion: @escaping (Result<MChat, Error>) -> Void){
        var chat: MChat?
        activeChatsRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            for document in querySnapshot!.documents {
                let data = document.data()
                //пытаемся получить данные о пользователе из data
                guard let friendUsername = data["friendUsername"] as? String,
                      let friendAvatarStringURL = data["friendAvatarStringURL"] as? String,
                      let lastMessageContent = data["lastMessage"] as? String,
                      let friendId = data["friendId"] as? String else {
                    return
                }
                if user.id == friendId {
                    chat = MChat(friendUsername: friendUsername, friendAvatarStringURL: friendAvatarStringURL, lastMessageContent: lastMessageContent, friendId: friendId)
                }
            }
            if chat == nil {
                completion(.failure(UserError.canNotGetUserInfo))
            } else {
                completion(.success(chat!))
            }
            
        }
    }
}
