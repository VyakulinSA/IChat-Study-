//
//  UIButton + Extentsion.swift
//  iChat
//
//  Created by Вякулин Сергей on 02.02.2021.
//

//P4. Создаем данный файл для инициализации кнопок через конвинианс для UIKit
import Foundation
import UIKit

//P5. Добавляем экстеншин для UIButton
extension UIButton {
    
    //P6. Создаем convenience init в который можем передавать все что угодно (создаем собственный инициализатор для кнопки, чтобы потом проще было создавать кнопку на вьюхе)
    //При желании указываем предустановленные параметры, чтобы меньше указывать при инициализации, если они будут стандартными
    convenience init(title: String, titleColor: UIColor, backgtoundColor: UIColor, font: UIFont? = .avenir20(), isShdow: Bool = false, corrnerRadius: CGFloat = 4)  {
        self.init(type: .system) //переопределяем настоящий инициализатор
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.backgroundColor = backgtoundColor
        self.titleLabel?.font = font
        
        self.layer.cornerRadius = corrnerRadius
        //если нужны тени
        if isShdow {
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowRadius = 4
            self.layer.shadowOpacity = 0.2 //блики тени
            self.layer.shadowOffset = CGSize(width: 0, height: 4) //куда будет уходить
        }
        
    }
    
    //P31. Настройка лого на кнопку гугл
    func customizeGoogleButton() {
        //определяем объект UIImageView
        let googleLogo = UIImageView(image: #imageLiteral(resourceName: "googleLogo"), contentMode: .scaleAspectFit)
        googleLogo.translatesAutoresizingMaskIntoConstraints = false //отключаем автоконстрейнты
        self.addSubview(googleLogo) //добавляем сабвью на кнопку self - является UIButton
        
        NSLayoutConstraint.activate([
            googleLogo.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            googleLogo.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        
        ])
    }
}

