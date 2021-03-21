//
//  UILabel + Extension.swift
//  iChat
//
//  Created by Вякулин Сергей on 02.02.2021.
//


//P12. Создаем данный файл для инициализации фона через конвинианс для UIKit (удобно тем, что потом можно внести одинаковые изменения в разных местах одновременно)
import Foundation
import UIKit

extension UILabel {
    
    convenience init(text: String, font: UIFont? = .avenir20()) {
        self.init()
        
        self.text = text
        self.font = font
    }
    
}
