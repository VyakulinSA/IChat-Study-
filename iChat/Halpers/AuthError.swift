//
//  AuthError.swift
//  iChat
//
//  Created by Вякулин Сергей on 25.02.2021.
//

import Foundation
//P135. Создадим enum для различных вариантов ошибок, чтобы использовать его в функциях а не хардкодить какойто текст
enum AuthError {
    case notFilled
    case invalidEmail
    case passwordNotMatched
    case unknownError
    case serverError
}

//P136. Делаем расширение для enum чтобы описать сами кейсы, подписываем под протокол LocalizedError, чтобы можно было использовать там где ожидается тип Error
extension AuthError: LocalizedError {
    //создадим переменную для описания
    var errorDescription: String? {
        switch self {
        case .notFilled:
            return NSLocalizedString("Заполните все поля", comment: "")
        case .invalidEmail:
            return NSLocalizedString("Формат почты не является допустимым", comment: "")
        case .passwordNotMatched:
            return NSLocalizedString("Пароли не совпадают", comment: "")
        case .unknownError:
            return NSLocalizedString("Неизвестная ошибка", comment: "")
        case .serverError:
            return NSLocalizedString("Ошибка сервера", comment: "")
        }
    }
}
