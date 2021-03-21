//
//  OneLineTextField.swift
//  iChat
//
//  Created by Вякулин Сергей on 06.02.2021.
//

import Foundation
import UIKit

//P23. Создаем кастомный текстфилд, для отображения на экране регистрации SignUpViewController
class OneLineTextField: UITextField {
    
    convenience init(font: UIFont? = .avenir20()) {
        self.init()
        
        self.font = font //текст в текстфилде
        self.borderStyle = .none //убираем рамки вокруг текстфилда
        self.translatesAutoresizingMaskIntoConstraints = false
        
        //создадим view ввиде полоски, чтобы отображалась снизу под textField
        var bottomView = UIView()
        bottomView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        bottomView.backgroundColor = .textFieldLight()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        //добавим на view текстфилда
        self.addSubview(bottomView)
        
        //закрепим снизу
        NSLayoutConstraint.activate([
            bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 5),
            bottomView.heightAnchor.constraint(equalToConstant: 1)
        ])

        
    }
}
