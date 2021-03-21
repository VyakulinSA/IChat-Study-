//
//  UIApplication + Extension.swift
//  iChat
//
//  Created by Вякулин Сергей on 02.03.2021.
//


import Foundation
import UIKit
//P175. Создаем расширение для переходов на главный экрн.

extension UIApplication {
    //создаем функцию которая возвращает, самый верхний открытый в данный момент viewController
    //с помощью этой функции мы сможем отображать allert на любом view и соответственно его completion блок использовать на любом контроллере, потому что вызов будет происходить с одной и той же страницы где работает переход
    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
            
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}

