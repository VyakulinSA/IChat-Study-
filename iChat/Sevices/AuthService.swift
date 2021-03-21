//
//  AuthService.swift
//  iChat
//
//  Created by Вякулин Сергей on 24.02.2021.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

//P127. Создаем класс по работе с авторизацией
class AuthService {
    
    //используем паттерн singleTon, чтобы удобнее работать
    static let shared = AuthService()
    
    //P128. инициализируем переменную авторизации, чтобы не вызывать связку Auth.auth() из вне каждый раз при обращении
    private let auth = Auth.auth()
    
    
    //P129. Создаем функцию для регистрации
    //один из параметров является сбегающее замыкание с возвращаемым свойством Result<Передаем параметры которые возвращаются>
    //User - возвращается в случае успеха (это внутренний объект Firebase) - лучше свои модели не называть так же, чтобы не было одинаковых. В нем хранится информация о получаемом user (см. документацию - Аутентификация - Начать)
    func register(email: String?, password: String?, confirmPassword: String?, completion: @escaping (Result<User, Error>) -> Void) {
        //P137. до того момента, как вызываем функцию регистрации, мы должны проверить валидность полей
        guard Validators.isFilled(email: email, password: password, confirmPassword: confirmPassword) else {
            completion(.failure(AuthError.notFilled))
            return
        }
        
        //следующая проверка
        guard  password!.lowercased() == confirmPassword!.lowercased() else {
            completion(.failure(AuthError.passwordNotMatched))
            return
        }
        
        guard Validators.isSimpleEmail(email!) else {
            completion(.failure(AuthError.invalidEmail))
            return
        }
        
        //после всех проверок можем проводить регистрацию
        
        auth.createUser(withEmail: email!, password: password!) { (result, error) in
            //раскрываем result и если он есть то идем дальше, если нет, то в Result нашей функции register возвращаем ошибку
            guard let result = result else {
                completion(.failure(error!)) //у нас 2 варианта completion, в данном случае мы передаем ошибку которую получили
                return
            }
            //Если createuser проходит успешно и мы получаем result, то возвращаем в completion нашей функции - успех
            completion(.success(result.user))
        }
    }
    
    //P132. Создаем функцию логирования
    func login(email: String?, password: String?, completion: @escaping (Result<User, Error>) -> Void) {
        //P138. добавим проверку заполненности полей
        guard let email = email, let password = password, !email.isEmpty, !password.isEmpty else {
            completion(.failure(AuthError.notFilled))
            return
        }
        
        guard Validators.isSimpleEmail(email) else {
            completion(.failure(AuthError.invalidEmail))
            return
        }
        
        //после всех проверок можем проводить регистрацию
        auth.signIn(withEmail: email, password: password) { (result, error) in
            guard let result = result else {
                completion(.failure(error!))
                return
            }
            completion(.success(result.user))
        }
    }
    
    //P167. Реализуем дополнительный метод для логирования по кнопке google + испортируем библиотек (см. выше)
    func googleLogin(user: GIDGoogleUser!, error: Error!, completion: @escaping (Result<User,Error>) -> Void) {
        //проверяем есть ли ошибка
        if let error = error {
            completion(.failure(error))
            return
        }
        //проверяем авторизован ли пользователь
        guard let auth = user.authentication else {return}
        //если да, то получаем его креды
        let credential = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        //пытаемся авторизоваться, и записываем в сбегающее замыкание результат
        Auth.auth().signIn(with: credential) { (result, error) in
            guard let result = result else {
                completion(.failure(error!))
                return
            }
            completion(.success(result.user))
        }
    }
    
    
}
