//
//  UIFont + Extension.swift
//  iChat
//
//  Created by Вякулин Сергей on 02.02.2021.
//

//P8. Создаем данный файл для инициализации фона через конвинианс для UIKit (удобно тем, что потом можно внести одинаковые изменения в разных местах одновременно)
import Foundation
import UIKit


extension UIFont {
    
    //добавляем метод, который будет возвращать нужный нам Font с настройками
    static func avenir20() -> UIFont? {
        return UIFont.init(name: "avenir", size: 20)
        
    }
    
    static func avenir26() -> UIFont? {
        return UIFont.init(name: "avenir", size: 26)
        
    }
    
    static func laoSangamMN20() -> UIFont? {
        return UIFont.init(name: "Lao Sangam MN", size: 20)
    }
    
    static func laoSangamMN18() -> UIFont? {
        return UIFont.init(name: "Lao Sangam MN", size: 18)
    }
}
