//
//  SelfConfiguringCell.swift
//  iChat
//
//  Created by Вякулин Сергей on 16.02.2021.
//

import Foundation

//P70. Так как у нас для обоих чатов (ожидающих и активных) будут общие параметры да и вид в целом, создадим протокол с постоянными свойставми и методами
protocol SelfConfiguringCell {
    static var reuseId: String {get} //id ячейки
    func configure<U: Hashable>(with value:U) //функция настройки (используем дженерик, чтобы была возможность передавать любой параметр(хэшируемый)
}
