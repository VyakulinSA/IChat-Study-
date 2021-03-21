//
//  AuthNavigatingDelegate.swift
//  iChat
//
//  Created by Вякулин Сергей on 27.02.2021.
//

import Foundation

//P140. добавим протокол для реализации работы делегата, будем осуществлять переходы между экранами через делегата
//чтобы когда у нас закрывается один экран, другой открывался именно делегатом другого экрана
protocol AuthNavigatingDelegate: class {
    func toLoginVC()
    func toSignUpVC()
}
