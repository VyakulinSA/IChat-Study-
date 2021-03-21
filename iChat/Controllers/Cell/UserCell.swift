//
//  UserCell.swift
//  iChat
//
//  Created by Вякулин Сергей on 22.02.2021.
//

import Foundation
import UIKit
//P199. через под файл подключаем библиотеку для работы с изображениями и имортируемм в проект
import SDWebImage

//P104. Создаем контроллер кастомной ячейки
class UserCell: UICollectionViewCell, SelfConfiguringCell {
    
    let userImageView = UIImageView()
    let userName = UILabel(text: "userName", font: .laoSangamMN20())
    let containerView = UIView() //создаем отдельный контейнер для изображения и лейбла (и уже его округляем) а к самой ячейки добавляем тени, иначе тени не сработают, когда мы будем делать clipToBounds обрежется ячейка и соответственно пропадут тени
    
    
    static var reuseId: String = "UserCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        //P109
        setupConstraints()
        
        self.layer.shadowColor = #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 1)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 4 //округляем ячейку(округлится только ферхняя часть)
        containerView.layer.cornerRadius = 4
        containerView.clipsToBounds = true
    }
    
    //P201. Делаем так, чтобы мы ячейки переиспользовались и изображения обновлялись
    override func prepareForReuse() {
        userImageView.image = nil
    }
    
    //P108
    private func setupConstraints() {
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        userName.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.backgroundColor = .red
        
        addSubview(containerView)
        containerView.addSubview(userImageView)
        containerView.addSubview(userName)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
        ])
        
        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            userImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            userImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
//            userImageView.bottomAnchor.constraint(equalTo: userName.topAnchor),
            userImageView.heightAnchor.constraint(equalTo: containerView.widthAnchor) //делаем ширину равную высоте(квадрат)
            
        ])
        
        NSLayoutConstraint.activate([
            userName.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            userName.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            userName.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            userName.topAnchor.constraint(equalTo: userImageView.bottomAnchor)
        ])
        
    }
    
    //P110
    func configure<U>(with value: U) {
        guard let user: MUser = value as? MUser else {return}
//        userImageView.image = UIImage(named: user.avatarStringURL)
        //P200. модернизируем отображение картинки с помощью новой библиотеки
        guard let URL = URL(string: user.avatarStringURL) else {return}
        userImageView.sd_setImage(with: URL, completed: nil)
        userName.text = user.username

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: SwiftUI
//Импортируем SwiftUI библиотеку
import SwiftUI
//создаем структуру
struct UserCellСProvider: PreviewProvider {
    static var previews: some View {
            ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        //создадим объект класса, который хотим показывать в Canvas
        let tabBarVC = MainTabBarController()
        //меняем input параметры в соответствии с образцом
        func makeUIViewController(context: UIViewControllerRepresentableContext<UserCellСProvider.ContainerView>) -> MainTabBarController {
            return tabBarVC
        }
        //не пишем никакого кода
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
    }
}
