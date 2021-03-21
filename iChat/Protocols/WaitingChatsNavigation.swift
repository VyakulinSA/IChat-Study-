//
//  WaitingChatsNavigation.swift
//  iChat
//
//  Created by Вякулин Сергей on 14.03.2021.
//

import Foundation

//P222.Создадим протокол, для реализации функционала по согласию или отлонению ожидающего чата в контроллере ListViewController через делегирование
protocol WaitingChatsNavigation: class{
    func removeWaitingChat(chat: MChat)
    func chatToActive(chat: MChat)
}
