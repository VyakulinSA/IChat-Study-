//
//  InsertableTextField.swift
//  iChat
//
//  Created by Вякулин Сергей on 22.02.2021.
//

import Foundation
import UIKit


//P115. создаем кастомный текстфилд, для дальнейшего его использования в SetupProfile
class InsertableTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //P116. Производим настройку textField
        backgroundColor = .white
        placeholder = "Write something here ..."
        font = UIFont.systemFont(ofSize: 14)
        clearButtonMode = .whileEditing
        borderStyle = .none
        layer.cornerRadius = 18
        layer.masksToBounds = true
        
        //размещаем изображение на левой границе textField
        let image = UIImage(systemName: "smiley")
        let imageView = UIImageView(image: image)
        imageView.setupColor(color: .lightGray)
        leftView = imageView
        leftView?.frame = CGRect(x: 0, y: 0, width: 19, height: 19)
        leftViewMode = .always
        
        //размещаем кнопку на левой границе textField
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "Sent"), for: .normal)
        //P119. добавим градиент цвет на кнопку
        button.applayGradients(cornerRadius: 10)
        rightView = button
        rightView?.frame = CGRect(x: 0, y: 0, width: 19, height: 19)
        rightViewMode = .always
    }
    
    //P117. двигаем элементы внутри textField
    //Двигаем текст (вызываем уже усществующую функцию, переопределяя ее)
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 36, dy: 0)
    }
    
    //Двигаем placeholder (вызываем уже усществующую функцию, переопределяя ее)
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 36, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 36, dy: 0)
    }
    
    
    //Двигаем leftView (вызываем уже усществующую функцию, переопределяя ее)
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x += 12
        return rect
    }
    
    //Двигаем rightView (вызываем уже усществующую функцию, переопределяя ее)
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x -= 12
        return rect
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}





////MARK: SwiftUI
////Импортируем SwiftUI библиотеку
//import SwiftUI
////создаем структуру
//struct InsTextFieldVCProvider: PreviewProvider {
//    static var previews: some View {
//            ContainerView().edgesIgnoringSafeArea(.all)
//    }
//    
//    struct ContainerView: UIViewControllerRepresentable {
//        //создадим объект класса, который хотим показывать в Canvas
//        let profileVC = ProfileViewController()
//        //меняем input параметры в соответствии с образцом
//        func makeUIViewController(context: UIViewControllerRepresentableContext<InsTextFieldVCProvider.ContainerView>) -> ProfileViewController {
//            return profileVC
//        }
//        //не пишем никакого кода
//        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
//        }
//    }
//}
