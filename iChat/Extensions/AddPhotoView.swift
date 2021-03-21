//
//  AddPhotoView.swift
//  iChat
//
//  Created by Вякулин Сергей on 09.02.2021.
//


//P34. Создаем кастомной view для добавления фото
import Foundation
import UIKit

class AddPhotoView: UIView {
    //P36. Создаем объект UIImageView для расположения иконок на view (куда будет отрисовываться фотография и кнопка добавления новой)
    var circleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "avatar")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 1
        return imageView
    }()
    
    let plusButton: UIButton = {
        let button = UIButton(type: .system) //инициализируем со свойством type .system, чтобы могли видеть когда нажимаем на кнопку.
        button.translatesAutoresizingMaskIntoConstraints = false
        let myImage = #imageLiteral(resourceName: "plus")
        button.setImage(myImage, for: .normal)
        button.tintColor = .buttonDark()
        return button
        
    }()
    
    //P35. Реализуем инициализатор
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(circleImageView)
        addSubview(plusButton)
        //P38. Подключаем констрейнты
        setupConstraints()
        
    }
    
    //P37. Настраиваем Constraints
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            circleImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            circleImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            circleImageView.widthAnchor.constraint(equalToConstant: 100),
            circleImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        NSLayoutConstraint.activate([
            plusButton.leadingAnchor.constraint(equalTo: circleImageView.trailingAnchor, constant: 16),
            plusButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 30),
            plusButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        //даем понять кастомному view, что низ нашей imgageView, это и низ всего View, чтобы оно не сжималось.
        //потому что, view само по себе не понимает где заканчивается, поэтому необходимо делать так
        self.bottomAnchor.constraint(equalTo: circleImageView.bottomAnchor).isActive = true
        //тоже самое с правой границей
        self.trailingAnchor.constraint(equalTo: plusButton.trailingAnchor).isActive = true

    }
    
    //P36.1. Для округления кнопки вызываем специальный метод, не делаем этого в инициализации иконки
    override func layoutSubviews() {
        super.layoutSubviews()
        circleImageView.layer.masksToBounds = true //включаем округление (обрезка слоя)
        circleImageView.layer.cornerRadius = circleImageView.frame.width / 2 //указываем размер закругления слоя
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
