//
//  ButtonFromView.swift
//  iChat
//
//  Created by Вякулин Сергей on 06.02.2021.
//

//P16. Создаем фалй + класс для размещения кнопки и лэйбла в stackView (создавая кастомный view)
import Foundation
import UIKit

class ButtonFromView: UIView {
    
    init(label: UILabel, button: UIButton) {
        super.init(frame: .zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(label)
        self.addSubview(button)
        //для того, чтобы не активировать каждый констрейнт, мы можем поместить их в массив активации констрейнтов
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor)
            //так как лэйбл расширяется по размеру текста, то нам для него не нужно указывать размер
        ])
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            button.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            //для кнопки необходимо указать размеры, именно она и растянет наш стэквью
            button.heightAnchor.constraint(equalToConstant: 60)
            
        ])
        
        //даем понять кастомному stackView, что низ нашей кнопки, это и низ всего View, чтобы оно не сжималось.
        //потому что, view само по себе не понимает где заканчивается, поэтому необходимо делать так
        bottomAnchor.constraint(equalTo: button.bottomAnchor).isActive = true
        

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
