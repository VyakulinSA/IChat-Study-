//
//  ListenerService.swift
//  iChat
//
//  Created by Вякулин Сергей on 07.03.2021.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

//P196. создадим сервис для работы со слушателем БД
class ListenerService {
    
    static let shared = ListenerService()
    //создаем ссылку на БД
    private let db = Firestore.firestore()
    //создаем ссылку на users
    private var usersRef : CollectionReference {
        return db.collection("users")
    }
    //создадим свойство текущего user
    private var currentUserId: String {
        return Auth.auth().currentUser!.uid
    }
    
    //функция для отслеживания пользователей в firebase
    func usersObserve(users: [MUser], completion: @escaping (Result<[MUser],Error>) -> Void) -> ListenerRegistration? {
        var users = users
        //создадим объект слушателя
        let usersListener = usersRef.addSnapshotListener { (quarySnapshot, error) in
            //проверим, что можем получить снимок всех юзеров
            guard let snapshot = quarySnapshot else {
                completion(.failure(error!))
                return
            }
            //получаем измененные документы и перебираем их
            snapshot.documentChanges.forEach { (diff) in
                //Добавляем инициализатор для MUser см 197
                guard let muser = MUser(document: diff.document) else {return}
                //получаем все варианты изменений которые могли произойти
                switch diff.type{
                case .added:
                    //если добавлен новый пользователь, проверяем, что такого нет в данный момент
                    guard !users.contains(muser), muser.id != self.currentUserId else { return }
                    //добавляем
                    users.append(muser)
                case .modified:
                    //пытаемся получить index измененного user
                    guard let index = users.firstIndex(of: muser) else {return}
                    //меняем user по индексу на user с изменениями
                    users[index] = muser
                case .removed:
                    //пытаемся получить index измененного user
                    guard let index = users.firstIndex(of: muser) else {return}
                    //удаляем user
                    users.remove(at: index)
                }
            }
            completion(.success(users))
        }
        return usersListener
    }
    
    //P213. Создаем сервис для слушателя, чтобы он следил за ожидающими чатами в firebase
    func waitingChatsObserve(chats: [MChat], completion: @escaping (Result<[MChat],Error>) -> Void) -> ListenerRegistration? {
        var chats = chats
        let chatsRef = db.collection(["users", currentUserId, "waitingChats"].joined(separator: "/"))
        let chatsListener = chatsRef.addSnapshotListener { (quarySnapshot, error) in
            //проверим, что можем получить снимок всех юзеров
            guard let snapshot = quarySnapshot else {
                completion(.failure(error!))
                return
            }
            //получаем измененные документы и перебираем их
            snapshot.documentChanges.forEach { (diff) in
                //в 204 пункте создаем инициализатор для MChat из документа слушателя
                guard let chat = MChat(document: diff.document) else {return}
                
                switch diff.type{
                case .added:
                    //если добавлен новый чат, проверяем, что такого нет в данный момент
                    guard !chats.contains(chat) else { return }
                    //добавляем
                    chats.append(chat)
                case .modified:
                    //пытаемся получить index измененного chat
                    guard let index = chats.firstIndex(of: chat) else {return}
                    //меняем chat по индексу на chat с изменениями
                    chats[index] = chat
                case .removed:
                    //пытаемся получить index измененного chat
                    guard let index = chats.firstIndex(of: chat) else {return}
                    //удаляем chat
                    chats.remove(at: index)
                }
                
            }
            completion(.success(chats))
        }
        return chatsListener
    }
    
    //P230. Создадим сервис для слушателя, чтобы он следил за активными чатами в БД
    func activeChatsObserve(chats: [MChat], completion: @escaping (Result<[MChat],Error>) -> Void) -> ListenerRegistration? {
        var chats = chats
        let chatsRef = db.collection(["users", currentUserId, "activeChats"].joined(separator: "/"))
        let chatsListener = chatsRef.addSnapshotListener { (quarySnapshot, error) in
            //проверим, что можем получить снимок всех юзеров
            guard let snapshot = quarySnapshot else {
                completion(.failure(error!))
                return
            }
            //получаем измененные документы и перебираем их
            snapshot.documentChanges.forEach { (diff) in
                //в 204 пункте создаем инициализатор для MChat из документа слушателя
                guard let chat = MChat(document: diff.document) else {return}
                
                switch diff.type{
                case .added:
                    //если добавлен новый чат, проверяем, что такого нет в данный момент
                    guard !chats.contains(chat) else { return }
                    //добавляем
                    chats.append(chat)
                case .modified:
                    //пытаемся получить index измененного chat
                    guard let index = chats.firstIndex(of: chat) else {return}
                    //меняем chat по индексу на chat с изменениями
                    chats[index] = chat
                case .removed:
                    //пытаемся получить index измененного chat
                    guard let index = chats.firstIndex(of: chat) else {return}
                    //удаляем chat
                    chats.remove(at: index)
                }
                
            }
            completion(.success(chats))
        }
        return chatsListener
    }
    
    //P253. Создадим метод для слушателя только одного сообщения
    func messagesObserve(chat: MChat, completion: @escaping (Result<Mmessage,Error>) -> Void) -> ListenerRegistration? {
        let ref = usersRef.document(currentUserId).collection("activeChats").document(chat.friendId).collection("messages")
        let messageListener = ref.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            snapshot.documentChanges.forEach { (diff) in
                guard let message = Mmessage(document: diff.document) else {return}
                switch diff.type {
                case .added:
                    //просто возвращаем сообщение
                    completion(.success(message))
                case .modified:
                    break
                case .removed:
                    break
                }
            }
            
        }
        return messageListener
    }
    
}
