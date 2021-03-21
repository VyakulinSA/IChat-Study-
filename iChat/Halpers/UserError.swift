//
//  UserError.swift
//  iChat
//
//  Created by Вякулин Сергей on 27.02.2021.
//

import Foundation

//P148. создадим еще один enum ошибок для работы с пользователем
enum UserError {
    case notFilled
    case photoNotExists
    case canNotGetUserInfo
    case canNotUnwrapToMUser
}

extension UserError: LocalizedError {
    var errorDescription: String?{
        switch self {
        case .notFilled:
            return NSLocalizedString("Заполните все поля", comment: "")
        case .photoNotExists:
            return NSLocalizedString("Пользователь не выбрал фотографию", comment: "")
        case .canNotGetUserInfo:
            return NSLocalizedString("Невозможно загрузить информацию о User из Firebase", comment: "")
        case .canNotUnwrapToMUser:
            return NSLocalizedString("Невозможно конвертировать MUser", comment: "")
        }
    }

}
