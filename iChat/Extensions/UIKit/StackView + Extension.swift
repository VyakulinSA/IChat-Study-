//
//  StackView + Extension.swift
//  iChat
//
//  Created by Вякулин Сергей on 06.02.2021.
//

//P18. создаем кастомный инициализатор для stackView, чтобы небыло громоздких функций в коде контроллера
import Foundation
import UIKit

extension UIStackView {
    
    convenience init(arrangedSubviews: [UIView], axis: NSLayoutConstraint.Axis, spacing: CGFloat) {
        self.init(arrangedSubviews: arrangedSubviews)
        self.axis = axis
        self.spacing = spacing
    }
}
