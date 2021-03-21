//
//  Validators.swift
//  iChat
//
//  Created by Вякулин Сергей on 25.02.2021.
//

import Foundation
//P134. Создаем отдельный класс для проведения валидации
class Validators {
    
    //проверка на пустоту полей для ввода
    static func isFilled(email: String?, password: String?, confirmPassword: String?) -> Bool {
        guard let password = password,
              let confirmPassword = confirmPassword,
              let email = email,
              !password.isEmpty,
              !confirmPassword.isEmpty,
              !email.isEmpty else {return false}
        return true
    }
    
    
    //проверка валидного email - функции берутся из интернета, при вводе запроса по проверке емэйла
    static func isSimpleEmail(_ email: String) -> Bool {
        let emailRegEx = "^.+@.+\\..{2,}$"
        return check(text: email, regEx: emailRegEx)
    }
    
    private static func check(text: String, regEx: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regEx)
        return predicate.evaluate(with: text)
    }
    
    //P147. Добавляем проверку на заполненность полей перед сохранение в БД
    static func isFilled(username: String?, description: String?, sex: String?) -> Bool {
        guard let description = description,
              let sex = sex,
              let username = username,
              !description.isEmpty,
              !sex.isEmpty,
              !username.isEmpty else {return false}
        return true
    }
    
    
}
