//
//  WaitingChatCell.swift
//  iChat
//
//  Created by Вякулин Сергей on 16.02.2021.
//

import Foundation
import UIKit
import SDWebImage

//P80. Создаем класс для настройки ячейки
class WaitingChatCell: UICollectionViewCell, SelfConfiguringCell {
    static var reuseId: String = "WaitingChatCell"
    
    var friendImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupConstraints()
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        
    }
    
    func configure<U>(with value: U) {
        guard let chat: MChat = value as? MChat else {return}
//        friendImageView.image = UIImage(named: chat.friendAvatarStringURL)
        friendImageView.sd_setImage(with: URL(string: chat.friendAvatarStringURL), completed: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension WaitingChatCell {
    
    private func setupConstraints() {
        friendImageView.translatesAutoresizingMaskIntoConstraints = false
        friendImageView.backgroundColor = .black
        
        addSubview(friendImageView)
        
        NSLayoutConstraint.activate([
            friendImageView.topAnchor.constraint(equalTo: self.topAnchor),
            friendImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            friendImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            friendImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            
        ])
    }
}


//MARK: SwiftUI
//Импортируем SwiftUI библиотеку
import SwiftUI
//создаем структуру
struct WaitingChatCellСProvider: PreviewProvider {
    static var previews: some View {
            ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        //создадим объект класса, который хотим показывать в Canvas
        let tabBarVC = MainTabBarController()
        //меняем input параметры в соответствии с образцом
        func makeUIViewController(context: UIViewControllerRepresentableContext<WaitingChatCellСProvider.ContainerView>) -> MainTabBarController {
            return tabBarVC
        }
        //не пишем никакого кода
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
    }
}
