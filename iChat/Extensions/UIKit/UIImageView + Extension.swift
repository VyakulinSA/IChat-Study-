//
//  UIImageView + Extension.swift
//  iChat
//
//  Created by Вякулин Сергей on 02.02.2021.
//

//P15.
import Foundation
import UIKit

extension UIImageView {
    
    convenience init(image: UIImage?, contentMode: UIView.ContentMode) {
        self.init()
        
        self.image = image
        self.contentMode = contentMode
    }
    
    //P120. Добавим расширение для UIImageView, чтобы была возможность изменять цвет картинки
    func setupColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}
