//
//  ActiveChatCell.swift
//  iChat
//
//  Created by Вякулин Сергей on 15.02.2021.
//

import Foundation
import UIKit
import SDWebImage

//P69. Создаем класс для настройки ячейки
class ActiveChatCell: UICollectionViewCell, SelfConfiguringCell {
    
    static var reuseId: String = "ActiveChatCell"
    
    //P71. создаем свойства, которые будет хранить ячейки и настраивать
    let friendImageView = UIImageView()
    let friendName = UILabel(text: "User name", font: .laoSangamMN20())
    let lastMessage = UILabel(text: "How are you?", font: .laoSangamMN18())
    let gradientView = GradientView(from: .topTrailing, to: .bottomLeading, startColor: #colorLiteral(red: 0.7882352941, green: 0.631372549, blue: 0.9411764706, alpha: 1), endColor: #colorLiteral(red: 0.4784313725, green: 0.6980392157, blue: 0.9215686275, alpha: 1))
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        setupConstraints()
        
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
    }
    
    func configure<U>(with value: U) {
        guard let chat: MChat = value as? MChat else {return}
        friendImageView.sd_setImage(with: URL(string: chat.friendAvatarStringURL), completed: nil)
        friendName.text = chat.friendUsername
        lastMessage.text = chat.lastMessageContent
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

//MARK: - setupConstraints
extension ActiveChatCell{
    //P72. Настроим констрейнты элементов внутри ячейки
    private func setupConstraints() {
        friendImageView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        friendName.translatesAutoresizingMaskIntoConstraints = false
        lastMessage.translatesAutoresizingMaskIntoConstraints = false
        
        friendImageView.backgroundColor = .green
        gradientView.backgroundColor = .blue
        
        addSubview(friendImageView)
        addSubview(friendName)
        addSubview(lastMessage)
        addSubview(gradientView)

        
        NSLayoutConstraint.activate([
            friendImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            friendImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            friendImageView.heightAnchor.constraint(equalToConstant: 78),
            friendImageView.widthAnchor.constraint(equalToConstant: 78)
        ])
        
        NSLayoutConstraint.activate([
            friendName.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 16),
            friendName.trailingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 16),
            friendName.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
        ])
        
        NSLayoutConstraint.activate([
            lastMessage.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 16),
            lastMessage.trailingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 16),
            lastMessage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12)
        ])
        
        NSLayoutConstraint.activate([
            gradientView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            gradientView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            gradientView.heightAnchor.constraint(equalTo: self.heightAnchor),
            gradientView.widthAnchor.constraint(equalToConstant: 8)
        ])
 
    }
}

//MARK: SwiftUI
//Импортируем SwiftUI библиотеку
import SwiftUI
//создаем структуру
struct ActiveChatCellVСProvider: PreviewProvider {
    static var previews: some View {
            ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        //создадим объект класса, который хотим показывать в Canvas
        let tabBarVC = MainTabBarController()
        //меняем input параметры в соответствии с образцом
        func makeUIViewController(context: UIViewControllerRepresentableContext<ActiveChatCellVСProvider.ContainerView>) -> MainTabBarController {
            return tabBarVC
        }
        //не пишем никакого кода
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
    }
}

